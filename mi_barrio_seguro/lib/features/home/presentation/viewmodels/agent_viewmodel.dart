import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mi_barrio_seguro/core/services/agent_service.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/data/models/incident_model.dart';

class AgentViewModel extends ChangeNotifier {
  final AgentService _agentService = AgentService();
  StreamSubscription? _incidentsSubscription;
  
  bool _isOnline = false;
  List<IncidentModel> _incidents = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;

  bool get isOnline => _isOnline;
  List<IncidentModel> get incidents => _incidents;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;

  AgentViewModel() {
    _startListening();
  }

  void _startListening() {
    _incidentsSubscription?.cancel();
    _incidentsSubscription = _agentService.getAllIncidentsStream().listen(
      (rawData) {
        _updateIncidentsInternal(rawData);
      },
      onError: (e) {
        debugPrint("Error en stream de AgentViewModel: $e");
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  void toggleService(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  void _updateIncidentsInternal(List<Map<String, dynamic>> rawData) {
    _incidents = rawData
        .map((map) {
          final bool isAlert = map.containsKey('tipo');
          return IncidentModel.fromMap(map, isAlert: isAlert);
        })
        .where((incident) => incident.estado == 'activa' || incident.estado == 'pendiente')
        .toList();

    _generateMarkers();
    _isLoading = false;
    notifyListeners();
  }

  void _generateMarkers() {
    _markers = _incidents.map((incident) {
      Color markerColor = incident.isAlert ? AppTheme.alertRed : AppTheme.warningOrange;
      
      return Marker(
        markerId: MarkerId(incident.id.toString()),
        position: LatLng(incident.lat, incident.lng),
        infoWindow: InfoWindow(
          title: incident.tipo.toUpperCase(),
          snippet: incident.fechaLocal,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getHue(markerColor)),
      );
    }).toSet();
  }

  double _getHue(Color color) {
    if (color == AppTheme.alertRed) return BitmapDescriptor.hueRed;
    if (color == AppTheme.primaryBlue) return BitmapDescriptor.hueAzure;
    if (color == AppTheme.successGreen) return BitmapDescriptor.hueGreen;
    if (color == AppTheme.warningOrange) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueRed;
  }

  Future<void> attendIncident(IncidentModel incident) async {
    // Optimistic UI
    _incidents.removeWhere((i) => i.id == incident.id);
    _generateMarkers();
    notifyListeners();

    try {
      await _agentService.updateIncidentStatus(
        incident.isAlert ? 'alerts' : 'reports',
        incident.id,
        'atendido',
      );
    } catch (e) {
      debugPrint("Error al atender incidente: $e");
      // En una app real, aquí revertiríamos el estado si falla
    }
  }

  @override
  void dispose() {
    _incidentsSubscription?.cancel();
    super.dispose();
  }
}
