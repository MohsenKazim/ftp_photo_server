import 'package:network_info_plus/network_info_plus.dart';

/// Utility class to get device information
class DeviceInfo {
  /// Get local IP address of the device
  static Future<String> getLocalIP() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      if (wifiIP != null) {
        return wifiIP;
      }
      return '127.0.0.1';
    } catch (e) {
      // If there's an error, return localhost as fallback
      return '127.0.0.1';
    }
  }
}