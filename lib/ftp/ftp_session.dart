import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:ftp_photo_server/core/constants.dart';
import 'package:ftp_photo_server/ftp/ftp_codes.dart';
import 'package:ftp_photo_server/ftp/ftp_passive_data.dart';
import 'package:ftp_photo_server/storage/photo_saver.dart';
import 'package:ftp_photo_server/storage/temp_manager.dart';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/core/device_info.dart';

/// Handles a single FTP client session
class FtpSession {
  final Socket client;
  final Function(String) onLog;
  final Function(List<int>, String) onFileReceived;
  final AppState appState;

  bool _isAuthenticated = false;
  String _currentDirectory = '/';
  String? _username;

  // Data connection state
  FtpPassiveData? _dataConnection;

  FtpSession({
    required this.client,
    required this.onLog,
    required this.onFileReceived,
    required this.appState,
  });

  /// Handle the FTP session
  Future<void> handle() async {
    try {
      // Send welcome message
      await _sendResponse('${FtpCodes.serviceReady} ${FtpMessages.getWelcomeMessage()}');

      // Use decoder to handle partial characters across chunks
      await for (var line in client.transform(utf8.decoder).transform(const LineSplitter())) {
        // LineSplitter handles both \n and \r\n and gives us clean lines
        final commandLine = line.trim();
        if (commandLine.isEmpty) continue;

        onLog('Command: $commandLine');

        final parts = commandLine.split(' ');
        final command = parts[0].toUpperCase();
        final argument = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        switch (command) {
          case FtpCommands.user:
            await _handleUser(argument);
            break;

          case FtpCommands.pass:
            await _handlePass(argument);
            break;

          case FtpCommands.syst:
            await _sendResponse('${FtpCodes.systemType} ${FtpMessages.getSystemType()}');
            break;

          case FtpCommands.type:
            await _handleType(argument);
            break;

          case FtpCommands.pasv:
            await _handlePasv();
            break;

          case FtpCommands.stor:
            await _handleStor(argument);
            break;

          case FtpCommands.list:
            await _handleList();
            break;

          case FtpCommands.pwd:
            if (!_isAuthenticated) {
              await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
            } else {
              await _sendResponse('${FtpCodes.pathCreated} "$_currentDirectory" is current directory');
            }
            break;

          case FtpCommands.cwd:
            await _handleCwd(argument);
            break;

          case FtpCommands.mkd:
            await _handleMkd(argument);
            break;

          case FtpCommands.quit:
            await _handleQuit();
            return;

          case FtpCommands.noop:
            await _sendResponse('${FtpCodes.ok} OK');
            break;

          default:
            await _sendResponse('${FtpCodes.notImplemented} ${FtpMessages.getNotImplemented()}');
            break;
        }
      }
    } catch (e) {
      onLog('Session error: $e');
    } finally {
      await _cleanupDataConnection();
      await client.close();
    }
  }

  /// Handle USER command
  Future<void> _handleUser(String username) async {
    _username = username;
    await _sendResponse('${FtpCodes.needPassword} ${FtpMessages.getNeedPassword()}');
  }

  /// Handle PASS command
  Future<void> _handlePass(String password) async {
    if (_username == AppConstants.ftpUsername && password == AppConstants.ftpPassword) {
      _isAuthenticated = true;
      await _sendResponse('${FtpCodes.loggedIn} ${FtpMessages.getLoggedIn()}');
    } else {
      await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
    }
  }

  /// Handle TYPE command
  Future<void> _handleType(String type) async {
    if (type.toUpperCase() == 'I' || type.toUpperCase() == 'IMAGE') {
      await _sendResponse('${FtpCodes.ok} Type set to I');
    } else {
      await _sendResponse('${FtpCodes.ok} Type set to A');
    }
  }

  /// Handle PASV command
  Future<void> _handlePasv() async {
    if (!_isAuthenticated) {
      await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
      return;
    }

    try {
      // Close any existing data connection
      await _cleanupDataConnection();

      // Create a new data server socket
      _dataConnection = FtpPassiveData();
      await _dataConnection!.start();
      
      final hostParts = await _dataConnection!.getFormattedIp();
      final int dataPort = _dataConnection!.port;

      final pasvResponse = '${FtpCodes.enteringPassiveMode} ${FtpMessages.getEnteringPassiveMode(await DeviceInfo.getLocalIP(), dataPort)}';

      await _sendResponse(pasvResponse);
    } catch (e) {
      await _sendResponse('${FtpCodes.localError} Error: $e');
    }
  }

  /// Handle STOR command
  Future<void> _handleStor(String filename) async {
    if (!_isAuthenticated) {
      await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
      return;
    }

    onLog('STOR command: $filename');

    if (!TempManager.isValidImageExtension(filename)) {
      await _sendResponse('${FtpCodes.fileNameNotAllowed} File type not allowed');
      return;
    }

    if (_dataConnection == null) {
      await _sendResponse('${FtpCodes.cannotOpenDataConnection} No data connection - send PASV first');
      return;
    }

    // Wait for data connection to be established (with timeout)
    Socket? dataSocket;
    try {
      dataSocket = await _dataConnection!.waitForConnection(Duration(seconds: 30));
    } on TimeoutException {
      await _sendResponse('${FtpCodes.cannotOpenDataConnection} Data connection timeout');
      return;
    } catch (e) {
      await _sendResponse('${FtpCodes.cannotOpenDataConnection} Error: $e');
      return;
    }

    try {
      await _sendResponse('${FtpCodes.openingDataConnection} Opening data connection');

      // Receive the file data
      final bytes = await _receiveFileData(dataSocket);

      // Save the image to camera roll
      try {
        final savedPath = await PhotoSaver.saveImageToGallery(
          Uint8List.fromList(bytes),
          filename: filename,
          appState: appState,
        );
        onLog('Image saved to: $savedPath');

        // Update app log
        appState.addLog('Received: $filename (${bytes.length} bytes)');
      } catch (e) {
        onLog('Error saving image: $e');
      }

      // Notify about received file
      onFileReceived(bytes, filename);

      await _sendResponse('${FtpCodes.fileActionOk} ${FtpMessages.getFileActionOk(filename)}');
    } catch (e) {
      await _sendResponse('${FtpCodes.localError} Error receiving file: $e');
    } finally {
      await _cleanupDataConnection();
    }
  }

  /// Receive file data from the data connection
  Future<Uint8List> _receiveFileData(Socket dataSocket) async {
    final builder = BytesBuilder(copy: false);

    await for (var chunk in dataSocket) {
      // Check if we've received too much data BEFORE adding
      if (builder.length + chunk.length > AppConstants.maxFileSize) {
        throw Exception('File too large');
      }
      builder.add(chunk);
    }

    return builder.takeBytes();
  }

  /// Clean up data connection
  Future<void> _cleanupDataConnection() async {
    try {
      await _dataConnection?.close();
      _dataConnection = null;
    } catch (e) {
      onLog('Error cleaning up data connection: $e');
    }
  }

  /// Handle LIST command
  Future<void> _handleList() async {
    if (!_isAuthenticated) {
      await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
      return;
    }

    // Check if data connection exists
    if (_dataConnection == null) {
      await _sendResponse('${FtpCodes.cannotOpenDataConnection} Data connection not initialized');
      return;
    }

    // Wait for data connection to be established (with timeout)
    Socket? dataSocket;
    try {
      dataSocket = await _dataConnection!.waitForConnection(Duration(seconds: 10));
    } on TimeoutException {
      await _sendResponse('${FtpCodes.cannotOpenDataConnection} Data connection timeout');
      return;
    } catch (e) {
      await _sendResponse('${FtpCodes.cannotOpenDataConnection} Error: $e');
      return;
    }

    // Return directory listing through data connection
    final listing = '-rw-r--r-- 1 user group 0 Jan 01 00:00 .\r\n'
        '-rw-r--r-- 1 user group 0 Jan 01 00:00 ..\r\n';

    await _sendResponse('${FtpCodes.openingDataConnection} Opening data connection');
    
    dataSocket.add(utf8.encode(listing));
    await dataSocket.close();
    
    await _sendResponse('${FtpCodes.closingDataConnection} Done');
    await _cleanupDataConnection();
  }

  /// Handle CWD command
  Future<void> _handleCwd(String path) async {
    if (!_isAuthenticated) {
      await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
      return;
    }

    if (path == '..') {
      _currentDirectory = '/';
    } else if (path == '/') {
      _currentDirectory = '/';
    } else {
      _currentDirectory = '/$path';
    }

    await _sendResponse('${FtpCodes.fileActionOk} Directory changed');
  }

  /// Handle MKD command
  Future<void> _handleMkd(String dirname) async {
    if (!_isAuthenticated) {
      await _sendResponse('${FtpCodes.notLoggedIn} ${FtpMessages.getNotLoggedIn()}');
      return;
    }

    await _sendResponse('${FtpCodes.pathCreated} ${FtpMessages.getPathCreated(dirname)}');
  }

  /// Handle QUIT command
  Future<void> _handleQuit() async {
    // Cleanup data connection before closing client
    await _cleanupDataConnection();
    await _sendResponse('${FtpCodes.closingTransmissionChannel} ${FtpMessages.getGoodbyeMessage()}');
  }

  /// Send response to client
  Future<void> _sendResponse(String response) async {
    onLog('Response: $response');
    client.add(utf8.encode('$response\r\n'));
  }
}
