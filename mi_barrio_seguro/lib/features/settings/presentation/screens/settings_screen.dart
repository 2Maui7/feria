import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_barrio_seguro/core/services/report_service.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _suggestionController = TextEditingController();
  final _reportService = ReportService();
  bool _isSubmitting = false;
  String _userName = "Vecino";
  String _userBarrio = "Mi Barrio";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Vecino";
      _userBarrio = prefs.getString('user_barrio') ?? "Mi Barrio";
    });
  }

  Future<void> _handleSendSuggestion() async {
    if (_suggestionController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? "vecino_demo_123";

      await _reportService.sendSuggestion(
        usuarioId: userId,
        mensaje: _suggestionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Gracias! Tu sugerencia ha sido enviada.")),
        );
        _suggestionController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al enviar sugerencia: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BUZÓN Y AJUSTES"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 150), // Aumentado para no tapar botón de salir
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil de Usuario
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50, 
                    backgroundColor: AppTheme.primaryBlue,
                    child: Icon(Icons.person, size: 50, color: Colors.white)
                  ),
                  const SizedBox(height: 12),
                  Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Barrio: $_userBarrio", style: const TextStyle(color: Colors.white60)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Buzón de Sugerencias
            const Text(
              "BUZÓN DE SUGERENCIAS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _suggestionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Escribe tus sugerencias para mejorar el barrio...",
                hintStyle: const TextStyle(color: Colors.white38),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppTheme.cardDark,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSendSuggestion,
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ENVIAR SUGERENCIA"),
              ),
            ),

            const SizedBox(height: 40),

            // Otras opciones
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white70),
              title: const Text("Ayuda y Soporte"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text("Acerca de la App"),
              onTap: () {},
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.alertRed),
              title: const Text("Cerrar Sesión", style: TextStyle(color: AppTheme.alertRed)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
