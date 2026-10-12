import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'dart:developer';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  Position? get currentPosition => _currentPosition;

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("Ubicación desactivada por hardware.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      log("Permiso de ubicación denegado.");
      return;
    }

    // Escuchar cambios de posición continuamente
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Notificar cada 5 metros
      ),
    ).listen((Position position) {
      _currentPosition = position;
      log("GPS Actualizado: ${position.latitude}, ${position.longitude}");
    }, onError: (e) {
      log("Error en el stream de ubicación: $e");
    });

    // Obtener la posición inicial de inmediato con fallback
    try {
      // Intentar primero con la última conocida por rapidez
      _currentPosition = await Geolocator.getLastKnownPosition();
      
      // Luego intentar obtener una fresca con timeout corto
      final freshPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 3),
      );
      _currentPosition = freshPosition;
      log("GPS Inicial establecido: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}");
    } catch (e) {
      log("Error obteniendo posición inicial fresca: $e");
    }
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
  }
}
