import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../profile_screen.dart';

class BlockZenDashboardScreen extends StatefulWidget {
  static const String routeName = '/blockzen/dashboard';

  const BlockZenDashboardScreen({super.key});

  @override
  State<BlockZenDashboardScreen> createState() =>
      _BlockZenDashboardScreenState();
}

class _BlockZenDashboardScreenState extends State<BlockZenDashboardScreen> {
  int _selectedIndex = 2; // Start with Home (center tab)

  final List<Widget> _screens = [
    const BlockZenProjectsScreen(),
    const BlockZenWalletScreen(),
    const BlockZenHomeScreen(),
    const BlockZenMarketplaceScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.assignment),
      label: 'Projects',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet),
      label: 'Wallet',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 32),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.storefront),
      label: 'Market',
    ),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: _screens[_selectedIndex],
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
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

// Placeholder screens for now
class BlockZenHomeScreen extends StatelessWidget {
  const BlockZenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'BlockZen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name ?? 'User'}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${user?.role ?? 'Project Developer'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 204),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your carbon credit balance: ${user?.credits.toStringAsFixed(2) ?? '0.00'} Credits',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Summary Stats
            const Text(
              'Platform Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Total Projects',
                  '156',
                  Icons.assignment,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'CO₂ Reduced',
                  '2.4M tonnes',
                  Icons.eco,
                  const Color(0xFF2196F3),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Credits Issued',
                  '890K',
                  Icons.monetization_on,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Active Users',
                  '1,234',
                  Icons.people,
                  const Color(0xFF9C27B0),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Browse Projects',
                    'View available carbon credit projects',
                    Icons.assignment,
                    () {
                      // Navigate to projects tab
                      final dashboardState = context
                          .findAncestorStateOfType<
                            _BlockZenDashboardScreenState
                          >();
                      // ignore: invalid_use_of_protected_member
                      dashboardState?.setState(() {
                        dashboardState._selectedIndex = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    'Marketplace',
                    'Buy and sell carbon credits',
                    Icons.storefront,
                    () {
                      // Navigate to marketplace tab
                      final dashboardState = context
                          .findAncestorStateOfType<
                            _BlockZenDashboardScreenState
                          >();
                      // ignore: invalid_use_of_protected_member
                      dashboardState?.setState(() {
                        dashboardState._selectedIndex = 3;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 77)),
        ),
        child: Column(
          children: [
            icon == Icons.eco
                ? ImageIcon(
                    AssetImage('assets/images/logo.png'),
                    color: color,
                    size: 32,
                  )
                : Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0D47A1).withValues(alpha: 77),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0D47A1), size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens
class BlockZenProjectsScreen extends StatelessWidget {
  const BlockZenProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Projects', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Projects Screen\nComing Soon!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BlockZenMarketplaceScreen extends StatelessWidget {
  const BlockZenMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Marketplace', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Marketplace Screen\nComing Soon!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BlockZenWalletScreen extends StatelessWidget {
  const BlockZenWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Wallet', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Wallet Screen\nComing Soon!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BlockZenProfileScreen extends StatelessWidget {
  const BlockZenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Profile Screen\nComing Soon!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
