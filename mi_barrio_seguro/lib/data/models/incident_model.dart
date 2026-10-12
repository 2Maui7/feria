import 'package:mongo_dart/mongo_dart.dart';

class IncidentModel {
  final ObjectId id;
  final String usuarioId;
  final String tipo; // Para alertas o categoría para reportes
  final double lat;
  final double lng;
  final String estado;
  final DateTime timestamp;
  final String fechaLocal;
  final String? descripcion;
  final bool isAlert; // true para alertas, false para reportes

  IncidentModel({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.lat,
    required this.lng,
    required this.estado,
    required this.timestamp,
    required this.fechaLocal,
    this.descripcion,
    required this.isAlert,
  });

  factory IncidentModel.fromMap(Map<String, dynamic> map, {required bool isAlert}) {
    return IncidentModel(
      id: map['_id'] as ObjectId,
      usuarioId: map['usuario_id'] ?? '',
      tipo: isAlert ? (map['tipo'] ?? 'EMERGENCIA') : (map['categoria'] ?? 'REPORTE'),
      lat: (map['ubicacion']['lat'] as num).toDouble(),
      lng: (map['ubicacion']['lng'] as num).toDouble(),
      estado: map['estado'] ?? '',
      timestamp: map['timestamp'] as DateTime,
      fechaLocal: map['fecha_local'] ?? '',
      descripcion: map['descripcion'],
      isAlert: isAlert,
    );
  }
}
