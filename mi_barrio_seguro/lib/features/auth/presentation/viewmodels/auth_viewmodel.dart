import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_barrio_seguro/core/services/auth_service.dart';
import 'package:mi_barrio_seguro/data/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _selectedInitialRole;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get selectedInitialRole => _selectedInitialRole;

  void setInitialRole(String role) {
    _selectedInitialRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userMap = await _authService.login(email, password);
      if (userMap != null) {
        _currentUser = UserModel.fromMap(userMap);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _currentUser!.id.toString());
        await prefs.setString('user_name', _currentUser!.nombre);
        await prefs.setString('user_role', _currentUser!.rol);
        await prefs.setString('user_inst', _currentUser!.institucion ?? '');
        await prefs.setString('user_badge', _currentUser!.credencial ?? '');
        await prefs.setString('user_barrio', _currentUser!.barrio);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error login: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String nombre,
    required String correo,
    required String password,
    required String telefono,
    required String barrio,
    required String rol,
    String? institucion,
    String? credencial,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.register(
        nombre: nombre,
        correo: correo,
        password: password,
        telefono: telefono,
        barrio: barrio,
        rol: rol,
        institucion: institucion,
        credencial: credencial,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint("Error register: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }
}
