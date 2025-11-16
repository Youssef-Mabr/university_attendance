import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WifiService {
  static const String allowedWifiName =
      "Student WiFi"; // your campus Wi-Fi name (case-sensitive)

  static Future<bool> checkWifiConnection() async {
    // Request location permission (required for WiFi SSID access on Android)
    final locationStatus = await Permission.location.request();

    print('DEBUG: Location permission status: ${locationStatus.name}');

    if (!locationStatus.isGranted) {
      print(
        'DEBUG: Location permission not granted. Status: ${locationStatus.name}',
      );
      // Try to open app settings if permission was permanently denied
      if (locationStatus.isPermanentlyDenied) {
        print(
          'DEBUG: Permission permanently denied. Please enable in settings.',
        );
      }
      return false;
    }

    print('DEBUG: Location permission GRANTED');

    final info = NetworkInfo();
    try {
      final wifiName = await info.getWifiName();
      print('DEBUG: Raw WiFi name from device: "$wifiName"');

      // Remove quotes that some devices add around WiFi names
      final cleanWifiName = wifiName?.replaceAll('"', '').trim();
      print('DEBUG: Cleaned WiFi name: "$cleanWifiName"');
      print('DEBUG: Expected WiFi name: "$allowedWifiName"');
      print('DEBUG: Match result: ${cleanWifiName == allowedWifiName}');

      if (cleanWifiName != null && cleanWifiName == allowedWifiName) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('DEBUG: WiFi check error: $e');
      return false;
    }
  }
}
