import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_barrio_seguro/core/services/emergency_service.dart';
import 'package:mi_barrio_seguro/core/services/report_service.dart';
import 'package:mi_barrio_seguro/core/services/location_helper.dart';
import 'package:mi_barrio_seguro/core/services/location_service.dart';

class NeighborViewModel extends ChangeNotifier {
  final EmergencyService _emergencyService = EmergencyService();
  final ReportService _reportService = ReportService();
  bool _isSending = false;
  List<Map<String, dynamic>> _myReports = [];

  bool get isSending => _isSending;
  List<Map<String, dynamic>> get myReports => _myReports;

  Future<void> loadMyReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return;

      _myReports = await _reportService.getReportsByUserId(userId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando reportes: $e");
    }
  }

  Future<Position?> getCurrentLocation() async {
    Position? position = LocationService().currentPosition;
    if (position == null) {
      position = await LocationHelper.getCurrentPosition();
    }
    return position;
  }

  Future<bool> sendAlert(String type, Position position) async {
    _isSending = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return false;

      await _emergencyService.sendEmergencyAlert(
        usuarioId: userId,
        tipo: type,
        lat: position.latitude,
        lng: position.longitude,
      );
      
      await loadMyReports(); // Recargar historial tras envío exitoso
      
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error envio alerta: $e");
    }

    _isSending = false;
    notifyListeners();
    return false;
  }

  Future<bool> sendReport({
    required String categoria,
    required String descripcion,
    required Position position,
  }) async {
    _isSending = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) return false;

      await _reportService.sendReport(
        usuarioId: userId,
        categoria: categoria,
        descripcion: descripcion,
        lat: position.latitude,
        lng: position.longitude,
      );
      
      await loadMyReports(); // Recargar historial tras envío exitoso
      
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error envio reporte: $e");
    }

    _isSending = false;
    notifyListeners();
    return false;
  }
}
