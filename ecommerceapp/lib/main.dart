import 'package:ecommerceapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Features/auth/Presentation/Login_Page.dart';
import 'Features/auth/Presentation/Register_Page.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

