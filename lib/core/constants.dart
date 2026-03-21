/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FTP Photo Server';
  static const String appVersion = '1.0.0';

  // FTP Server Settings
  static const int ftpPort = 2121;
  static const String ftpUsername = 'user_ftp_982';
  static const String ftpPassword = 'Secure@Pass!2024';

  // Supported image formats
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.heic',
    '.gif',
    '.bmp',
  ];

  // Max file size (100MB)
  static const int maxFileSize = 100 * 1024 * 1024;

  // Log settings
  static const int maxLogEntries = 100;
}
