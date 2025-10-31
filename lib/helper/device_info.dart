import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "deviceModel": androidInfo.model ?? "unknown",
        "deviceFingerprint": androidInfo.fingerprint ?? "unknown",
        "deviceBrand": androidInfo.brand ?? "unknown",
        "deviceId": androidInfo.id ?? "unknown",
        "deviceName": androidInfo.device ?? "unknown",
        "deviceManufacturer": androidInfo.manufacturer ?? "unknown",
        "deviceProduct": androidInfo.product ?? "unknown",
        "deviceSerialNumber": androidInfo.serialNumber ?? "unknown",
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "deviceModel": iosInfo.utsname.machine ?? "unknown",
        "deviceFingerprint": iosInfo.identifierForVendor ?? "unknown",
        "deviceBrand": "Apple",
        "deviceId": iosInfo.identifierForVendor ?? "unknown",
        "deviceName": iosInfo.name ?? "unknown",
        "deviceManufacturer": "Apple",
        "deviceProduct": iosInfo.model ?? "unknown",
        "deviceSerialNumber": "unknown",
      };
    } else {
      return {
        "deviceModel": "unknown",
        "deviceFingerprint": "unknown",
        "deviceBrand": "unknown",
        "deviceId": "unknown",
        "deviceName": "unknown",
        "deviceManufacturer": "unknown",
        "deviceProduct": "unknown",
        "deviceSerialNumber": "unknown",
      };
    }
  }
}
