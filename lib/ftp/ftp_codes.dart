/// FTP Response Codes
class FtpCodes {
  FtpCodes._();

  // 1xx - Positive Preliminary replies
  static const int dataConnectionAlreadyOpen = 125;
  static const int openingDataConnection = 150;

  // 2xx - Positive Completion replies
  static const int ok = 200;
  static const int systemStatus = 211;
  static const int directoryStatus = 212;
  static const int fileStatus = 213;
  static const int helpMessage = 214;
  static const int systemType = 215;
  static const int serviceReady = 220;
  static const int closingTransmissionChannel = 221;
  static const int dataConnectionOpen = 225;
  static const int closingDataConnection = 226;
  static const int enteringPassiveMode = 227;
  static const int loggedIn = 230;
  static const int fileActionOk = 250;
  static const int pathCreated = 257;

  // 3xx - Positive Intermediate replies
  static const int needPassword = 331;
  static const int needAccount = 332;

  // 4xx - Transient Negative Completion replies
  static const int localError = 450;
  static const int actionAborted = 451;
  static const int cannotOpenDataConnection = 425;
  static const int connectionClosed = 426;

  // 5xx - Permanent Negative Completion replies
  static const int syntaxError = 500;
  static const int syntaxErrorInParameters = 501;
  static const int notImplemented = 502;
  static const int badCommandSequence = 503;
  static const int parameterNotImplemented = 504;
  static const int notLoggedIn = 530;
  static const int fileUnavailable = 550;
  static const int pageTypeUnknown = 551;
  static const int quotaExceeded = 552;
  static const int fileNameNotAllowed = 553;
}

/// FTP Command Codes
class FtpCommands {
  FtpCommands._();

  static const String user = 'USER';
  static const String pass = 'PASS';
  static const String syst = 'SYST';
  static const String type = 'TYPE';
  static const String pasv = 'PASV';
  static const String stor = 'STOR';
  static const String list = 'LIST';
  static const String pwd = 'PWD';
  static const String cwd = 'CWD';
  static const String mkd = 'MKD';
  static const String quit = 'QUIT';
  static const String noop = 'NOOP';
  static const String retr = 'RETR';
  static const String dele = 'DELE';
  static const String rmd = 'RMD';
  static const String rename = 'RENAME';
}

/// FTP Response Messages
class FtpMessages {
  FtpMessages._();

  static String getWelcomeMessage() => 'FTP Photo Server Ready';
  static String getGoodbyeMessage() => 'Goodbye';
  static String getNeedPassword() => 'Need password';
  static String getLoggedIn() => 'User logged in';
  static String getNotLoggedIn() => 'Not logged in';
  static String getSystemType() => 'FTP Photo Server';
  static String getEnteringPassiveMode(String host, int port) {
    final hostParts = host.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    if (hostParts.length != 4) return 'Entering Passive Mode (127,0,0,1,${port ~/ 256},${port % 256})';
    return 'Entering Passive Mode (${hostParts[0]},${hostParts[1]},${hostParts[2]},${hostParts[3]},${port ~/ 256},${port % 256})';
  }
  static String getFileActionOk(String filename) => 'File action ok: $filename';
  static String getPathCreated(String path) => '"$path" created';
  static String getDirectoryStatus() => 'Directory status';
  static String getFileStatus() => 'File status';
  static String getHelpMessage() => 'Help message';
  static String getSyntaxError() => 'Syntax error';
  static String getBadCommandSequence() => 'Bad command sequence';
  static String getFileUnavailable() => 'File unavailable';
  static String getNotImplemented() => 'Command not implemented';
  static String getConnectionClosed() => 'Connection closed';
}
