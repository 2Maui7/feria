import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final ObjectId id;
  final String nombre;
  final String correo;
  final String telefono;
  final String barrio;
  final String rol;
  final String? institucion;
  final String? credencial;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.barrio,
    required this.rol,
    this.institucion,
    this.credencial,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] as ObjectId,
      nombre: map['nombre_completo'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'] ?? '',
      barrio: map['barrio'] ?? '',
      rol: map['rol'] ?? 'vecino',
      institucion: map['institucion'],
      credencial: map['credencial'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'nombre_completo': nombre,
      'correo': correo,
      'telefono': telefono,
      'barrio': barrio,
      'rol': rol,
      'institucion': institucion,
      'credencial': credencial,
    };
  }
}
