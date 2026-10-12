import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialRole;
  const RegisterScreen({super.key, this.initialRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _barrioController = TextEditingController();
  final _credencialController = TextEditingController();
  
  late String _selectedRol;
  String? _selectedInstitucion;
  
  final List<String> _instituciones = [
    'POLICÍA',
    'BOMBEROS',
    'HOSPITAL / AMBULANCIA',
    'SERVICIOS BÁSICOS',
  ];

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _selectedRol = widget.initialRole ?? 'vecino';
  }

  Future<void> _handleRegister() async {
    final authVM = context.read<AuthViewModel>();

    if (_nombreController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        (_selectedRol == 'vecino' && _barrioController.text.isEmpty) ||
        (_selectedRol == 'agente' && (_selectedInstitucion == null || _credencialController.text.length != 5))) {
      
      String error = "Por favor, completa todos los campos";
      if (_selectedRol == 'agente' && _credencialController.text.length != 5) {
        error = "La credencial debe tener exactamente 5 caracteres";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final success = await authVM.register(
      nombre: _nombreController.text.trim(),
      correo: _emailController.text.trim(),
      password: _passwordController.text,
      telefono: _telefonoController.text.trim(),
      barrio: _selectedRol == 'vecino' ? _barrioController.text.trim() : 'AGENTE',
      rol: _selectedRol,
      institucion: _selectedInstitucion,
      credencial: _credencialController.text.trim().toUpperCase(),
    );

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Registro exitoso! Ya puedes iniciar sesión"),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El correo ya está registrado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedRol == 'vecino' ? "REGISTRO DE VECINO" : "REGISTRO DE AGENTE"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person_add_alt_1_rounded, size: 80, color: AppTheme.primaryBlue),
            const SizedBox(height: 32),
            
            // Selector de Rol
            IgnorePointer(
              ignoring: widget.initialRole != null,
              child: Opacity(
                opacity: widget.initialRole != null ? 0.6 : 1.0,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildRoleButton("VECINO", Icons.home, 'vecino'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRoleButton("AGENTE", Icons.security, 'agente'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ... resto igual ...

            _buildTextField(
              controller: _nombreController,
              hint: "NOMBRE COMPLETO",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              hint: "CORREO ELECTRÓNICO",
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _telefonoController,
              hint: "TELÉFONO / CELULAR",
              icon: Icons.phone_android_rounded,
            ),
            const SizedBox(height: 16),

            if (_selectedRol == 'vecino')
              _buildTextField(
                controller: _barrioController,
                hint: "TU BARRIO / ZONA",
                icon: Icons.location_city_rounded,
              )
            else
              Column(
                children: [
                  _buildDropdownField(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _credencialController,
                    hint: "N° PLACA / CREDENCIAL (5 DIGITOS)",
                    icon: Icons.badge_rounded,
                  ),
                ],
              ),

            const SizedBox(height: 16),
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
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("CREAR CUENTA"),
              ),
            ),
          ],
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

  Widget _buildRoleButton(String label, IconData icon, String role) {
    bool isSelected = _selectedRol == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRol = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedInstitucion,
          hint: const Text("SELECCIONA INSTITUCIÓN", style: TextStyle(color: Colors.white24, fontSize: 14)),
          isExpanded: true,
          dropdownColor: AppTheme.cardDark,
          items: _instituciones.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedInstitucion = val),
        ),
      ),
    );
  }
}
