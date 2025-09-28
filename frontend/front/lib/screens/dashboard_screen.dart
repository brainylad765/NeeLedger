import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart'; // For file selection
import 'dart:io';

import 'home_screen_new.dart';
import 'market_wallet_screen.dart';
import 'profile_screen.dart';
import 'data_screen.dart';
import 'projects_screen.dart';
import 'welcome_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;

  int _selectedIndex = 2; // Start on Home tab
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

  /// ===============================
  /// Supabase Upload Functionality
  /// ===============================
  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final storagePath = '${user.id}/$fileName';
      await supabase.storage.from('projects').upload(storagePath, file);

      final fileUrl =
          supabase.storage.from('projects').getPublicUrl(storagePath);

      await supabase.from('projects').insert({
        'user_id': user.id,
        'title': fileName,
        'file_url': fileUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully!')),
        );
        setState(() {});
      }
    } on StorageException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProjects() {
    return supabase
        .from('projects')
        .select()
        .order('created_at', ascending: false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                  );
                }
              },
            )
          ],
        ),
        body: _selectedIndex == 1
            ? FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchProjects(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final projects = snapshot.data ?? [];
                  if (projects.isEmpty) {
                    return const Center(
                        child: Text('No projects yet. Upload one!'));
                  }

                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        title: Text(project['title']),
                        subtitle: Text('Uploaded on: ${project['created_at']}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // You could launch URL here with url_launcher
                        },
                      );
                    },
                  );
                },
              )
            : SafeArea(child: _pages[_selectedIndex]),
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
        floatingActionButton: _selectedIndex == 1
            ? FloatingActionButton(
                onPressed: _uploadDocument,
                child: const Icon(Icons.add),
              )
            : null,
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
