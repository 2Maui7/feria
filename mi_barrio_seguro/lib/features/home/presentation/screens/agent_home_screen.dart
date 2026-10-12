import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mi_barrio_seguro/features/home/presentation/viewmodels/agent_viewmodel.dart';
import 'package:mi_barrio_seguro/data/models/incident_model.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  String _agentName = "Agente";
  String _agentInst = "Emergencias";
  String _agentBadge = "";

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _agentName = prefs.getString('user_name') ?? "Agente";
      _agentInst = prefs.getString('user_inst') ?? "Emergencias";
      _agentBadge = prefs.getString('user_badge') ?? "";
    });
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final agentVM = context.watch<AgentViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$_agentInst ${_agentBadge.isNotEmpty ? '| ID: $_agentBadge' : ''}", 
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
            Text("HOLA, $_agentName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: AppTheme.alertRed), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Banner de Estado
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: agentVM.isOnline ? AppTheme.successGreen.withOpacity(0.3) : Colors.white10,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agentVM.isOnline ? "ESTADO: DISPONIBLE" : "ESTADO: FUERA DE SERVICIO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: agentVM.isOnline ? AppTheme.successGreen : Colors.white30,
                      ),
                    ),
                    const Text("Activa para recibir reportes", style: TextStyle(fontSize: 12, color: Colors.white38)),
                  ],
                ),
                Switch(
                  value: agentVM.isOnline,
                  onChanged: (val) {
                    agentVM.toggleService(val);
                    if (val) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("ESTÁS DE SERVICIO - Recibiendo alertas"),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  },
                  activeColor: AppTheme.successGreen,
                ),
              ],
            ),
          ),

          // Mapa de Incidentes - Siempre visible
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(-19.0333, -65.2627), zoom: 14),
                  markers: agentVM.markers,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                ),
              ),
            ),
          ),

          // Lista de Incidentes (Solo si está Online)
          if (agentVM.isOnline)
            Expanded(
              flex: 2,
              child: agentVM.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildIncidentList(agentVM.incidents),
            )
          else
            const Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_rounded, size: 50, color: Colors.white10),
                    SizedBox(height: 16),
                    Text("PONTE EN SERVICIO PARA ATENDER INCIDENTES", style: TextStyle(color: Colors.white24)),
                    Text("El mapa muestra emergencias pendientes", style: TextStyle(fontSize: 10, color: Colors.white12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncidentList(List<IncidentModel> incidents) {
    if (incidents.isEmpty) {
      return const Center(child: Text("No hay incidentes activos en tu zona", style: TextStyle(color: Colors.white30)));
    }

    final now = DateTime.now();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        final incident = incidents[index];
        final bool isNew = now.difference(incident.timestamp).inMinutes < 2;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNew ? AppTheme.alertRed.withOpacity(0.3) : Colors.white.withOpacity(0.05)
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (incident.isAlert ? AppTheme.alertRed : AppTheme.warningOrange).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  incident.isAlert ? Icons.notifications_active : Icons.report_problem, 
                  color: incident.isAlert ? AppTheme.alertRed : AppTheme.warningOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          incident.tipo.toUpperCase(), 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 13,
                            color: Colors.white
                          )
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.alertRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text("NUEVO", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    Text(incident.fechaLocal, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.read<AgentViewModel>().attendIncident(incident),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("ATENDIDO", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
