import 'package:mi_barrio_seguro/core/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class EmergencyService {
  final MongoDBService _mongoService = MongoDBService();

  Future<void> sendEmergencyAlert({
    required String usuarioId,
    required String tipo,
    required double lat,
    required double lng,
  }) async {
    final now = DateTime.now();
    final collection = await _mongoService.getAlertsCollection();

    final result = await collection.insertOne({
      '_id': ObjectId(),
      'usuario_id': usuarioId,
      'tipo': tipo,
      'ubicacion': {'lat': lat, 'lng': lng},
      'estado': 'activa',
      'timestamp': now,
      'fecha_local': "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
    });

    if (result.isFailure) {
      throw Exception("Error al enviar la alerta a la base de datos.");
    }
  }
}
