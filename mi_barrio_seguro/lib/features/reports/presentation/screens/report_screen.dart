import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:mi_barrio_seguro/core/services/location_service.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/home/presentation/viewmodels/neighbor_viewmodel.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _selectedCategory;
  File? _image;
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  LatLng _currentPosition = const LatLng(-19.0333, -65.2627); // Default Sucre

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    
    // Cargar reportes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NeighborViewModel>().loadMyReports();
    });
  }

  Future<void> _loadCurrentLocation() async {
    // Escuchar cambios de ubicación para actualizar el mini-mapa
    Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    });
    
    final position = LocationService().currentPosition;
    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    final neighborVM = context.read<NeighborViewModel>();

    if (_selectedCategory == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecciona una categoría y escribe una descripción")),
      );
      return;
    }

    try {
      final position = await neighborVM.getCurrentLocation();
      
      if (position == null) {
        throw Exception("No se pudo obtener la ubicación GPS.");
      }
      
      final success = await neighborVM.sendReport(
        categoria: _selectedCategory!,
        descripcion: _descriptionController.text.trim(),
        position: position,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("¡REPORTE ENVIADO CON TU UBICACIÓN! GPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}"),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          _descriptionController.clear();
          setState(() {
            _selectedCategory = null;
            _image = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al enviar reporte. Reintenta.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<NeighborViewModel>().isSending;

    return Scaffold(
      appBar: AppBar(
        title: const Text("REPORTE DE INCIDENCIAS"),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NUEVO REPORTE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            
            // Selector de Categorías
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                _categoryButton("Cable Caído", Icons.bolt, "cable_caido"),
                _categoryButton("Fuga de Agua", Icons.water_drop, "fuga_agua"),
                _categoryButton("Alumbrado", Icons.lightbulb, "alumbrado"),
                _categoryButton("Sospechoso", Icons.visibility, "sospechoso"),
              ],
            ),
            
            const SizedBox(height: 24),

            // Carga Multimedia
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 45, color: AppTheme.primaryBlue),
                          SizedBox(height: 8),
                          Text(
                            "AÑADIR EVIDENCIA VISUAL",
                            style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Descripción
            const Text("DESCRIPCIÓN:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Escribe detalles de la incidencia...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Ubicación
            Text("UBICACIÓN: [${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}]", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
                  liteModeEnabled: true,
                  zoomControlsEnabled: false,
                  myLocationEnabled: true,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botón Envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ENVIAR REPORTE ->"),
              ),
            ),

            const SizedBox(height: 20),
            Consumer<NeighborViewModel>(
              builder: (context, vm, child) {
                return ExpansionTile(
                  title: const Text("MIS REPORTES ENVIADOS", style: TextStyle(fontWeight: FontWeight.bold)),
                  children: vm.myReports.isEmpty
                    ? [const ListTile(title: Text("No tienes reportes enviados aún", style: TextStyle(color: Colors.white38)))]
                    : vm.myReports.map((report) {
                        return ListTile(
                          leading: Icon(
                            report['estado'] == 'atendido' ? Icons.check_circle : Icons.pending,
                            color: report['estado'] == 'atendido' ? AppTheme.successGreen : AppTheme.warningOrange,
                          ),
                          title: Text("${report['categoria']} - ${report['fecha_local']}"),
                          subtitle: Text("Estado: ${report['estado'].toString().toUpperCase()}"),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon, String value) {
    bool isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
