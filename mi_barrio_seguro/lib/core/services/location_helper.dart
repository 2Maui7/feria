import 'package:geolocator/geolocator.dart';
import 'dart:developer';

class LocationHelper {
  static Future<Position?> getCurrentPosition() async {
    try {
      // 1. Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log("Servicios de ubicación desactivados.");
        return null;
      }

      // 2. Intentar obtener la posición actual con un tiempo límite
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      log("Error obteniendo ubicación actual: $e");
      
      // 3. Fallback: Intentar obtener la última ubicación conocida
      try {
        log("Intentando obtener última ubicación conocida...");
        return await Geolocator.getLastKnownPosition();
      } catch (e2) {
        log("Error obteniendo última ubicación: $e2");
        return null;
      }
    }
  }
}
