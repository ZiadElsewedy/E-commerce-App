import 'package:flutter/material.dart';
import 'Features/auth/Presentation/Login_Page.dart';
import 'Features/auth/Presentation/Register_Page.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      // Use theme from app_theme.dart
      theme: AppTheme.lightTheme,
      // Optional: Uncomment to enable dark theme
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      // Initial route - start with login page
      initialRoute: '/login',
      // Define all routes for navigation
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

