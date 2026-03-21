import 'dart:io';
import 'package:ftp_photo_server/core/app_state.dart';
import 'package:ftp_photo_server/ftp/ftp_session.dart';
import 'package:ftp_photo_server/core/constants.dart';

/// FTP Server - Main entry point for FTP functionality
class FtpServer {
  final AppState appState;
  final Function(String) onLog;

  ServerSocket? _serverSocket;
  bool _isRunning = false;

  FtpServer({
    required this.appState,
    required this.onLog,
  });

  /// Start the FTP server
  Future<void> start() async {
    if (_isRunning) {
      onLog('FTP server is already running');
      return;
    }

    try {
      onLog('Starting FTP server on port ${AppConstants.ftpPort}...');

      _serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        AppConstants.ftpPort,
      );

      _serverSocket?.listen((client) {
        onLog('New connection from ${client.remoteAddress.address}');
        final session = FtpSession(
          client: client,
          onLog: onLog,
          onFileReceived: (bytes, filename) {
            appState.incrementImagesReceived();
            appState.addLog('Received: $filename (${bytes.length} bytes)');
          },
          appState: appState,
        );
        session.handle();
      });

      _isRunning = true;
      appState.setServerRunning(true);
      onLog('FTP server started successfully');

    } catch (e) {
      onLog('Failed to start FTP server: $e');
      _isRunning = false;
      appState.setServerRunning(false);
      rethrow;
    }
  }

  /// Stop the FTP server
  Future<void> stop() async {
    if (!_isRunning) {
      onLog('FTP server is not running');
      return;
    }

    try {
      onLog('Stopping FTP server...');
      await _serverSocket?.close();
      _isRunning = false;
      appState.setServerRunning(false);
      onLog('FTP server stopped');
    } catch (e) {
      onLog('Error stopping FTP server: $e');
      rethrow;
    }
  }

  /// Check if server is running
  bool isRunning() => _isRunning;
}
