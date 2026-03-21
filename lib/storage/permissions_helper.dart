import 'package:permission_handler/permission_handler.dart' as ph;

/// Helper class for managing iOS permissions
class PermissionsHelper {
  PermissionsHelper._();

  // Request all required permissions
  static Future<Map<ph.Permission, ph.PermissionStatus>> requestAllPermissions() async {
    final permissions = [
      ph.Permission.photos,
    ];

    final Map<ph.Permission, ph.PermissionStatus> statuses = {};

    for (var permission in permissions) {
      statuses[permission] = await permission.request();
    }

    return statuses;
  }

  // Check if all permissions are granted
    static Future<bool> areAllPermissionsGranted() async {
      final photoStatus = await ph.Permission.photos.status;
      return photoStatus.isGranted;
    }

    // Get permission status
    static Future<ph.PermissionStatus> getPhotoPermissionStatus() async {
      return await ph.Permission.photos.status;
    }

  // Open app settings
  static Future<bool> openAppSettings() async {
    try {
      // Call the top-level function from permission_handler package
      return await ph.openAppSettings();
    } catch (e) {
      return false;
    }
  }

  // Check if should show permission rationale
  static Future<bool> shouldShowRequestPermissionRationale() async {
    // In permission_handler 11.x, this method doesn't exist on Permission
    // Return false as a safe default
    return false;
  }
}
