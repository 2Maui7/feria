import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/screens/login_screen.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.surfaceDark,
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_moon_outlined, size: 100, color: AppTheme.primaryBlue),
            const SizedBox(height: 32),
            Text(
              "BIENVENIDO A\nMI BARRIO SEGURO",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 60),
            _buildRoleCard(
              context,
              "SOY VECINO",
              "Reporta incidentes y mantente informado",
              Icons.home_rounded,
              AppTheme.primaryBlue,
              'vecino',
            ),
            const SizedBox(height: 24),
            _buildRoleCard(
              context,
              "SOY AGENTE",
              "Atiende emergencias y protege a la comunidad",
              Icons.security_rounded,
              AppTheme.alertRed,
              'agente',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String role,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<AuthViewModel>().setInitialRole(role);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
