import 'package:flutter/material.dart';
import 'home_screen_new.dart';
import 'market_wallet_screen.dart';
import 'profile_screen.dart';
import 'data_screen.dart';
import 'projects_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 2; // Start on Home tab (index 2)
  int _hoveredIndex = -1;

  final List<Widget> _pages = [
    const DataScreen(),
    const ProjectsScreen(),
    const HomeScreen(),
    const MarketWalletScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Lock dashboard - prevent back navigation
      child: Scaffold(
        body: SafeArea(child: _pages[_selectedIndex]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 26),
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
            items: List.generate(5, (index) {
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
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.cloud_upload;
      case 1:
        return Icons.business_center;
      case 2:
        return Icons.home;
      case 3:
        return Icons.account_balance_wallet;
      case 4:
        return Icons.person;
      default:
        return Icons.home;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return "Data";
      case 1:
        return "Projects";
      case 2:
        return "Home";
      case 3:
        return "Market & Wallet";
      case 4:
        return "Profile";
      default:
        return "Home";
    }
  }
}
