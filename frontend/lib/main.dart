import 'package:flutter/material.dart';
import 'src/theme/app_theme.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/register_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Hospitality',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/register':
            return MaterialPageRoute(
                builder: (_) => const RegisterScreen());
          case '/login':
            return MaterialPageRoute(
                builder: (_) => const LoginScreen());
          case '/menu':
            final userName = settings.arguments as String? ?? 'User';
            return MaterialPageRoute(
                builder: (_) => MenuScreen(userName: userName));
          default:
            return MaterialPageRoute(
                builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
