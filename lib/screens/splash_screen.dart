import 'package:flutter/material.dart';
import 'package:constraa_report/screens/main_layout.dart';
import 'package:constraa_report/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;
      final Widget nextScreen = session != null ? const MainLayout() : const LoginScreen();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F66A9), // The blue background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using Icon as a placeholder for the logo
            const Icon(
              Icons.domain_verification_outlined,
              size: 80,
              color: Colors.white,
            ).animate().fade(duration: 800.ms).scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            const Text(
              'ConstrAAReport',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fade(delay: 400.ms, duration: 800.ms).slideY(begin: 0.5, curve: Curves.easeOut),
            const SizedBox(height: 10),
            Text(
              'Platform Pelaporan Progres\nKonstruksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withAlpha(230),
              ),
            ).animate().fade(delay: 600.ms, duration: 800.ms).slideY(begin: 0.5, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}
