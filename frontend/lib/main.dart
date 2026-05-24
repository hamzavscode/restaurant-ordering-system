import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/providers/orders_provider.dart';
import 'src/theme/app_theme.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/register_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/main_shell_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
          // We now route to MainShellScreen instead of MenuScreen directly
            return MaterialPageRoute(
                builder: (_) => const MainShellScreen());
          default:
            return MaterialPageRoute(
                builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
