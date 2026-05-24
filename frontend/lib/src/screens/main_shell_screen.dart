import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

/// The main shell of the app that holds the bottom navigation bar
/// and switches between the main tabs (Menu, Orders, Cart, Profile).
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartItemCount = context.watch<CartProvider>().totalItemCount;
    final userName = authProvider.userName;

    final screens = <Widget>[
      MenuScreen(userName: userName),        // 0: Menu
      const OrdersScreen(),                  // 1: Orders
      const CartScreen(),                    // 2: Cart
      const ProfileScreen(),                 // 3: Profile
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        cartBadgeCount: cartItemCount,
        onTap: _onTabTapped,
      ),
    );
  }
}
