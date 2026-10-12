import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class MongoDBService {
  static final MongoDBService _instance = MongoDBService._internal();
  factory MongoDBService() => _instance;
  MongoDBService._internal();

  late Db _db;
  bool _isConnected = false;

  static const String connectionString = 
      "mongodb+srv://USUARIO:CONTRASEÑA@cluster0.fvlegss.mongodb.net/mi_barrio_seguro?retryWrites=true&w=majority";

  Future<void> connect() async {
    if (_isConnected && _db.isConnected) return;
    
    try {
      log("Iniciando conexión a MongoDB Atlas...");
      _db = await Db.create(connectionString);
      await _db.open(secure: true);
      _isConnected = true;
      log("Conectado exitosamente a MongoDB Atlas");
    } catch (e) {
      log("Error al conectar a MongoDB: $e");
      _isConnected = false;
      // Reintento silencioso se manejará en el getter seguro
    }
  }

  Future<Db> getDatabase() async {
    if (!_isConnected || !_db.isConnected) {
      await connect();
    }
    
    int retries = 0;
    while ((!_isConnected || !_db.isConnected) && retries < 5) {
      log("Esperando conexión a base de datos... intento ${retries + 1}");
      await Future.delayed(const Duration(seconds: 1));
      await connect();
      retries++;
    }

    if (!_isConnected || !_db.isConnected) {
      throw Exception("No se pudo establecer conexión con el servidor. Verifica tu conexión a internet.");
    }
    
    return _db;
  }

  // Métodos de acceso a colecciones garantizados
  Future<DbCollection> getUsersCollection() async => (await getDatabase()).collection('users');
  Future<DbCollection> getAlertsCollection() async => (await getDatabase()).collection('alerts');
  Future<DbCollection> getReportsCollection() async => (await getDatabase()).collection('reports');
  Future<DbCollection> getMessagesCollection() async => (await getDatabase()).collection('messages');
  Future<DbCollection> getSuggestionsCollection() async => (await getDatabase()).collection('suggestions');

  Future<void> close() async {
    await _db.close();
    _isConnected = false;
  }
}
