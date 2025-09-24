import 'package:flutter/material.dart';
import 'home_screen_new.dart';
import 'market_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _hoveredIndex = -1;

  final List<Widget> _pages = [
    const HomeScreen(),
    const MarketScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  final List<String> _tooltips = [
    "Home Dashboard",
    "Carbon Credit Market",
    "Your Wallet",
    "User Profile"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: List.generate(4, (index) {
            return BottomNavigationBarItem(
              icon: MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = -1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: _hoveredIndex == index
                      ? (Matrix4.identity()..translate(0.0, -4.0))
                      : Matrix4.identity(),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _hoveredIndex == index ? 1.2 : 1.0,
                    child: Icon(
                      _getIconForIndex(index),
                      size: _hoveredIndex == index ? 28 : 24,
                    ),
                  ),
                ),
              ),
              label: _getLabelForIndex(index),
            );
          }),
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.store;
      case 2:
        return Icons.account_balance_wallet;
      case 3:
        return Icons.person;
      default:
        return Icons.home;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Market";
      case 2:
        return "Wallet";
      case 3:
        return "Profile";
      default:
        return "Home";
    }
  }
}
