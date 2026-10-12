import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  Future<bool> hasAllPermissions() async {
    final locationStatus = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    
    // Verificamos permisos
    bool locationOk = locationStatus.isGranted || locationStatus.isLimited;
    bool notificationOk = notificationStatus.isGranted;
    
    // Verificamos hardware GPS
    bool gpsEnabled = await Geolocator.isLocationServiceEnabled();
    
    return locationOk && notificationOk && gpsEnabled;
  }

  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    return await [
      Permission.location,
      Permission.notification,
    ].request();
  }

  Future<bool> isGPSEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
