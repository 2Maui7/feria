import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/home/presentation/viewmodels/neighbor_viewmodel.dart';
import 'package:mi_barrio_seguro/features/home/presentation/widgets/emergency_button.dart';
import 'package:mi_barrio_seguro/features/reports/presentation/screens/report_screen.dart';
import 'package:mi_barrio_seguro/features/chat/presentation/screens/chat_screen.dart';
import 'package:mi_barrio_seguro/features/settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ReportScreen(),
    const ChatScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Para el efecto Glassmorphism en el nav bar
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryBlue,
            unselectedItemColor: Colors.white30,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Panel'),
              BottomNavigationBarItem(icon: Icon(Icons.add_location_alt_rounded), label: 'Reportar'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static const CameraPosition _kSucre = CameraPosition(
    target: LatLng(-19.0333, -65.2627),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    final neighborVM = context.watch<NeighborViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MI BARRIO SEGURO",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Espacio para el nav bar flotante
        child: Column(
          children: [
            // Mapa Decorado Ultra-Premium
            Container(
              height: 280,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: const GoogleMap(
                  initialCameraPosition: _kSucre,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                ),
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "CENTRO DE ALERTA RÁPIDA",
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  EmergencyButton(
                    title: "LLAMAR POLICÍA",
                    icon: Icons.notifications_active,
                    color: AppTheme.primaryBlue,
                    onTap: () => _showAlert(context, neighborVM, "POLICÍA"),
                  ),
                  EmergencyButton(
                    title: "BOMBEROS",
                    icon: Icons.fire_truck,
                    color: AppTheme.alertRed,
                    onTap: () => _showAlert(context, neighborVM, "BOMBEROS"),
                  ),
                  EmergencyButton(
                    title: "AMBULANCIA",
                    icon: Icons.local_hospital,
                    color: AppTheme.successGreen,
                    onTap: () => _showAlert(context, neighborVM, "AMBULANCIA"),
                  ),
                  EmergencyButton(
                    title: "SERVICIOS BÁSICOS",
                    icon: Icons.home_repair_service,
                    color: AppTheme.warningOrange,
                    onTap: () => _showAlert(context, neighborVM, "SERVICIOS BÁSICOS"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAlert(BuildContext context, NeighborViewModel vm, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text("Alerta de $type", style: const TextStyle(color: Colors.white)),
        content: Text("¿Confirmar envío de alerta de emergencia a $type? Se enviará tu ubicación GPS actual.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            onPressed: () async {
              Navigator.pop(context);
              
              final position = await vm.getCurrentLocation();

              if (position == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No se pudo obtener tu ubicación. Verifica tu GPS.")),
                  );
                }
                return;
              }

              final success = await vm.sendAlert(type, position);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("¡ALERTA ENVIADA CON TU UBICACIÓN! GPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}"),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al enviar alerta. Reintenta.")),
                  );
                }
              }
            },
            child: const Text("ENVIAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
