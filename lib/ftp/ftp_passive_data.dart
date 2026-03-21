import 'dart:io';
import 'dart:async';
import 'package:ftp_photo_server/core/device_info.dart';

/// Managed passive mode data connection
class FtpPassiveData {
  ServerSocket? _server;
  Socket? _client;
  final Completer<Socket> _connectionCompleter = Completer<Socket>();

  int? _port;
  int get port => _port!;

  /// Initialize the data server and get a port
  Future<void> start() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    _port = _server!.port;
    
    // Listen for the first connection
    _server!.first.then((socket) {
      _client = socket;
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.complete(socket);
      }
    }).catchError((e) {
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.completeError(e);
      }
    });
  }

  /// Wait for the client to connect to the data port
  Future<Socket> waitForConnection(Duration timeout) {
    return _connectionCompleter.future.timeout(timeout);
  }

  /// Get the local IP formatted for PASV response
  Future<List<int>> getFormattedIp() async {
    final host = await DeviceInfo.getLocalIP();
    return host.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// Clean up resources
  Future<void> close() async {
    await _client?.close();
    await _server?.close();
    if (!_connectionCompleter.isCompleted) {
      _connectionCompleter.completeError(Exception('Connection closed'));
    }
  }
}
