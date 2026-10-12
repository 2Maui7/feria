import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mi_barrio_seguro/core/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuthService {
  final MongoDBService _mongoService = MongoDBService();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    final collection = await _mongoService.getUsersCollection();
    
    final user = await collection.findOne(
      where.eq('correo', email).eq('password_hash', hashedPassword),
    );

    return user;
  }

  Future<bool> register({
    required String nombre,
    required String correo,
    required String password,
    required String telefono,
    required String barrio,
    String rol = 'vecino',
    String? institucion,
    String? credencial,
  }) async {
    final hashedPassword = _hashPassword(password);
    final collection = await _mongoService.getUsersCollection();
    
    // Verificar si el usuario ya existe
    final existingUser = await collection.findOne(
      where.eq('correo', correo),
    );

    if (existingUser != null) return false;

    await collection.insertOne({
      '_id': ObjectId(),
      'nombre_completo': nombre,
      'correo': correo,
      'password_hash': hashedPassword,
      'telefono': telefono,
      'barrio': barrio,
      'rol': rol,
      'institucion': institucion ?? '',
      'credencial': credencial ?? '',
      'fecha_registro': DateTime.now(),
    });

    return true;
  }
}
