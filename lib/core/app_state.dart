import 'package:flutter/foundation.dart';
import 'package:ftp_photo_server/core/constants.dart';

/// Application state management using Provider pattern
class AppState with ChangeNotifier {
  bool _isServerRunning = false;
  String _localIP = 'Unknown';
  int _imagesReceived = 0;
  List<String> _logs = [];
  List<ReceivedImageInfo> _receivedImages = [];

  bool get isServerRunning => _isServerRunning;
  String get localIP => _localIP;
  int get imagesReceived => _imagesReceived;
  List<String> get logs => _logs;
  List<ReceivedImageInfo> get receivedImages => _receivedImages;

  void setServerRunning(bool value) {
    _isServerRunning = value;
    notifyListeners();
  }

  void setLocalIP(String ip) {
    _localIP = ip;
    notifyListeners();
  }

  void incrementImagesReceived() {
    _imagesReceived++;
    notifyListeners();
  }

  void addLog(String log) {
    _logs.insert(0, '[${DateTime.now().toLocal()}] $log');
    if (_logs.length > AppConstants.maxLogEntries) {
      _logs.removeLast();
    }
    notifyListeners();
  }

  void addReceivedImage(ReceivedImageInfo info) {
    _receivedImages.insert(0, info);
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void clearReceivedImages() {
    _receivedImages.clear();
    notifyListeners();
  }
}

/// Information about a received image
class ReceivedImageInfo {
  final String filename;
  final DateTime receivedAt;
  final int sizeBytes;
  final String? path;

  ReceivedImageInfo({
    required this.filename,
    required this.receivedAt,
    required this.sizeBytes,
    this.path,
  });

}
