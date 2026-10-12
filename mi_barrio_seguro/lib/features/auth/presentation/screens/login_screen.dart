import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/screens/register_screen.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mi_barrio_seguro/features/home/presentation/screens/agent_home_screen.dart';
import 'package:mi_barrio_seguro/features/home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole;
  const LoginScreen({super.key, this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    final authVM = context.read<AuthViewModel>();
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    final success = await authVM.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      if (!mounted) return;
      
      if (authVM.currentUser?.rol == 'agente') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AgentHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo o contraseña incorrectos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = context.watch<AuthViewModel>().isLoading;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Encabezado Ultra-Premium
                Hero(
                  tag: 'logo',
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.05),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(Icons.shield_moon_outlined, size: 90, color: AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "MI BARRIO SEGURO",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 34,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 60),
                
                // Formulario Minimalista
                _buildTextField(
                  controller: _emailController,
                  hint: "CORREO ELECTRÓNICO",
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _passwordController,
                  hint: "CONTRASEÑA",
                  icon: Icons.lock_open_rounded,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),

                const SizedBox(height: 40),

                // Botón Principal Refinado
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      shadowColor: AppTheme.primaryBlue.withOpacity(0.5),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("INGRESAR AL SISTEMA"),
                  ),
                ),

                const SizedBox(height: 32),
                
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen(initialRole: widget.initialRole)),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "¿No tienes una cuenta? ",
                      style: TextStyle(color: Colors.white54),
                      children: [
                        TextSpan(
                          text: "Regístrate aquí",
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white24,
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
