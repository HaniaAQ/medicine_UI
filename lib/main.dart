import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'screens/login_screen.dart';
import 'screens/medicines_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
      ],
      child: MaterialApp(
        title: 'Task1 - Medicines App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF667eea),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667eea),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF667eea),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return authProvider.isLoggedIn 
                ? const MedicinesScreen() 
                : const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/loading': (context) => const LoadingScreen(),
          '/medicines': (context) => const MedicinesScreen(),
          '/register': (context) => const RegisterScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
