import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mi_barrio_seguro/core/services/permission_service.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionScreen({super.key, required this.onPermissionsGranted});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final _permissionService = PermissionService();
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);
    
    final statuses = await _permissionService.requestPermissions();
    
    // Verificamos si todos los permisos necesarios están concedidos o son limitados
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!(status.isGranted || status.isLimited)) {
        allGranted = false;
      }
    });

    // Verificamos GPS físico
    final gpsEnabled = await _permissionService.isGPSEnabled();
    
    if (allGranted && gpsEnabled) {
      widget.onPermissionsGranted();
    } else {
      if (mounted) {
        String message = "Es obligatorio conceder todos los permisos";
        if (!gpsEnabled) message = "Por favor, enciende el GPS de tu dispositivo";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.alertRed,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 100, color: AppTheme.primaryBlue),
            const SizedBox(height: 32),
            Text(
              "TU SEGURIDAD ES PRIMERO",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Para que MI BARRIO SEGURO funcione correctamente, necesitamos acceso a tu ubicación (para geolocalización de emergencias) y permiso para enviarte notificaciones críticas.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 48),
            _buildPermissionItem(Icons.location_on, "Ubicación en tiempo real"),
            const SizedBox(height: 16),
            _buildPermissionItem(Icons.notifications_active, "Alertas y notificaciones"),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestPermissions,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CONCEDER PERMISOS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 30),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
