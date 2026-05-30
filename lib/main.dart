import 'package:flutter/material.dart';
import 'package:constraa_report/screens/splash_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:constraa_report/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const ConstrAAApp());
}

class ConstrAAApp extends StatelessWidget {
  const ConstrAAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConstrAA Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2F66A9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F66A9)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light gray/blueish background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F66A9),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F66A9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2F66A9), width: 2),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
