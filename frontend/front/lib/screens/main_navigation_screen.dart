import 'package:flutter/material.dart';
import 'home_screen_new.dart';
import 'data_screen.dart';
import 'projects_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DataScreen(),
    const ProjectsScreen(),
    const HomeScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Data',
    'Projects',
    'HOME',
    'Wallet',
    'Profile',
  ];

  final List<IconData> _icons = [
    Icons.cloud_upload,
    Icons.business_center,
    Icons.home,
    Icons.account_balance_wallet,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF0D47A1).withValues(alpha: 77),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: List.generate(_icons.length, (index) {
            return BottomNavigationBarItem(
              icon: Icon(_icons[index]),
              label: _titles[index],
            );
          }),
        ),
      ),
    );
  }
}
