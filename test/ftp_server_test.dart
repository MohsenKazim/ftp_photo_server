import 'package:flutter_test/flutter_test.dart';
import 'package:ftp_photo_server/ftp/ftp_codes.dart';

void main() {
  group('FTP Protocol Tests', () {
    test('PASV response format test', () {
      final response = FtpMessages.getEnteringPassiveMode('1.2.3.4', 2121);
      expect(response, contains('1,2,3,4'));
      expect(response, contains('8,73')); // 2121 = 8*256 + 73
    });

    test('Path creation format test', () {
      final response = FtpMessages.getPathCreated('/test');
      expect(response, equals('"/test" created')); // Must include quotes for most clients
    });
  });
}
