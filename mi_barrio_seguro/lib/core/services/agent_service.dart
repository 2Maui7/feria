import 'package:mi_barrio_seguro/core/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class AgentService {
  final MongoDBService _mongoService = MongoDBService();

  // Escuchar todos los incidentes activos en tiempo real
  Stream<List<Map<String, dynamic>>> getAllIncidentsStream() async* {
    while (true) {
      try {
        final alertsColl = await _mongoService.getAlertsCollection();
        final reportsColl = await _mongoService.getReportsCollection();
        
        final alerts = await alertsColl.find(where.eq('estado', 'activa')).toList();
        final reports = await reportsColl.find(where.eq('estado', 'pendiente')).toList();
        
        final all = [...alerts, ...reports];
        all.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
        
        yield all;
      } catch (e) {
        log("Error en stream de incidentes: $e");
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<void> updateIncidentStatus(String collectionName, ObjectId id, String newStatus) async {
    final collection = await (collectionName == 'alerts' 
        ? _mongoService.getAlertsCollection() 
        : _mongoService.getReportsCollection());
    
    await collection.updateOne(
      where.id(id),
      modify.set('estado', newStatus),
    );
  }
}
