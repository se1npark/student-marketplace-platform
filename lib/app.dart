import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bootstrap.dart';
import 'controllers/app_controller.dart';
import 'screens/auth_screen.dart';
import 'screens/marketplace_screen.dart';

class CampusCartApp extends StatelessWidget {
  const CampusCartApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppController(
        authRepository: dependencies.authRepository,
        listingRepository: dependencies.listingRepository,
        deviceService: dependencies.deviceService,
        usingDemoBackend: dependencies.usingDemoBackend,
        startupNotice: dependencies.startupNotice,
      ),
      child: MaterialApp(
        title: 'Campus Cart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF006C67),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          cardTheme: const CardThemeData(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppController controller) => controller.user);
    return user == null ? const AuthScreen() : const MarketplaceScreen();
  }
}
