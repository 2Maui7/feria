import 'package:mi_barrio_seguro/core/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChatService {
  final MongoDBService _mongoService = MongoDBService();

  Future<List<Map<String, dynamic>>> getMessages() async {
    final collection = await _mongoService.getMessagesCollection();
    return await collection
        .find(where.sortBy('timestamp', descending: false))
        .toList();
  }

  Future<void> sendMessage({
    required String emisorId,
    required String emisorNombre,
    required String mensaje,
    bool esOficial = false,
  }) async {
    final collection = await _mongoService.getMessagesCollection();
    await collection.insertOne({
      '_id': ObjectId(),
      'emisor_id': emisorId,
      'emisor_nombre': emisorNombre,
      'mensaje': mensaje,
      'es_oficial': esOficial,
      'timestamp': DateTime.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> get messagesStream async* {
    while (true) {
      yield await getMessages();
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
