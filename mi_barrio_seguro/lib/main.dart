import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mi_barrio_seguro/core/services/location_service.dart';
import 'package:mi_barrio_seguro/core/services/mongodb_service.dart';
import 'package:mi_barrio_seguro/core/services/permission_service.dart';
import 'package:mi_barrio_seguro/core/theme/app_theme.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/screens/permission_screen.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:mi_barrio_seguro/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mi_barrio_seguro/features/home/presentation/screens/agent_home_screen.dart';
import 'package:mi_barrio_seguro/features/home/presentation/screens/home_screen.dart';
import 'package:mi_barrio_seguro/features/home/presentation/viewmodels/agent_viewmodel.dart';
import 'package:mi_barrio_seguro/features/home/presentation/viewmodels/neighbor_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('user_id');
  final String? userRole = prefs.getString('user_role');
  
  final permissionService = PermissionService();
  final bool hasPermissions = await permissionService.hasAllPermissions();

  // Iniciar servicios globales
  if (hasPermissions) {
    LocationService().startTracking();
  }

  final mongoService = MongoDBService();
  try {
    await mongoService.connect();
  } catch (e) {
    debugPrint("Error inicial de conexión MongoDB: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AgentViewModel()),
        ChangeNotifierProvider(create: (_) => NeighborViewModel()),
      ],
      child: MiBarrioSeguroApp(
        isLoggedIn: userId != null,
        hasPermissions: hasPermissions,
        userRole: userRole,
      ),
    ),
  );
}

class MiBarrioSeguroApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool hasPermissions;
  final String? userRole;
  
  const MiBarrioSeguroApp({
    super.key, 
    required this.isLoggedIn,
    required this.hasPermissions,
    this.userRole,
  });

  @override
  State<MiBarrioSeguroApp> createState() => _MiBarrioSeguroAppState();
}

class _MiBarrioSeguroAppState extends State<MiBarrioSeguroApp> {
  late bool _hasPermissions;

  @override
  void initState() {
    super.initState();
    _hasPermissions = widget.hasPermissions;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MI BARRIO SEGURO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: !_hasPermissions
          ? PermissionScreen(
              onPermissionsGranted: () {
                LocationService().startTracking();
                setState(() => _hasPermissions = true);
              },
            )
          : (widget.isLoggedIn 
              ? (widget.userRole == 'agente' ? const AgentHomeScreen() : const HomeScreen()) 
              : const RoleSelectionScreen()),
    );
  }
}
