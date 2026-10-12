import 'package:mi_barrio_seguro/core/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ReportService {
  final MongoDBService _mongoService = MongoDBService();

  Future<void> sendReport({
    required String usuarioId,
    required String categoria,
    required String descripcion,
    String? fotoUrl,
    required double lat,
    required double lng,
  }) async {
    final now = DateTime.now();
    final collection = await _mongoService.getReportsCollection();

    final result = await collection.insertOne({
      '_id': ObjectId(),
      'usuario_id': usuarioId,
      'categoria': categoria,
      'descripcion': descripcion,
      'foto_url': fotoUrl ?? '',
      'ubicacion': {'lat': lat, 'lng': lng},
      'estado': 'pendiente',
      'timestamp': now,
      'fecha_local': "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
    });
    
    if (result.isFailure) {
      throw Exception("Error al guardar el reporte en la base de datos.");
    }
  }

  Future<List<Map<String, dynamic>>> getReportsByUserId(String userId) async {
    final collection = await _mongoService.getReportsCollection();
    return await collection
        .find(where.eq('usuario_id', userId).sortBy('timestamp', descending: true))
        .toList();
  }

  Future<void> sendSuggestion({
    required String usuarioId,
    required String mensaje,
  }) async {
    final now = DateTime.now();
    final collection = await _mongoService.getSuggestionsCollection();

    await collection.insertOne({
      '_id': ObjectId(),
      'usuario_id': usuarioId,
      'mensaje': mensaje,
      'timestamp': now,
      'fecha_local': "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
    });
  }
}
