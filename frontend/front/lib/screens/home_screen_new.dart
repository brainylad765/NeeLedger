import 'package:flutter/material.dart';
import 'project_details_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAllProjects = false;

  final List<Map<String, dynamic>> _projects = [
    {
      'id': '1',
      'name': 'Solar Farm Initiative',
      'location': 'Mahandi Delta, Odisha',
      'status': 'Active',
      'progress': 0.85,
      'carbonCredits': 1250000,
      'startDate': '2023-01-15',
      'endDate': '2025-12-31',
      'description':
          'Large-scale solar installation project generating renewable energy and carbon credits.',
      'investors': 45,
      'totalValue': 25000000,
      'type': 'Renewable Energy',
    },
    {
      'id': '2',
      'name': 'Kutch Conservation',
      'location': 'Gulf of Kutch, Gujrat',
      'status': 'Active',
      'progress': 0.92,
      'carbonCredits': 850000,
      'startDate': '2022-06-01',
      'endDate': '2032-05-31',
      'description':
          'Protecting 500,000 hectares of pristine rainforest from deforestation.',
      'investors': 128,
      'totalValue': 15000000,
      'type': 'Conservation',
    },
    {
      'id': '3',
      'name': 'Wind Energy Project',
      'location': 'Bhitarkanika',
      'status': 'Planning',
      'progress': 0.25,
      'carbonCredits': 600000,
      'startDate': '2024-03-01',
      'endDate': '2026-02-28',
      'description':
          'Offshore wind farm development with advanced turbine technology.',
      'investors': 23,
      'totalValue': 18000000,
      'type': 'Renewable Energy',
    },
    {
      'id': '4',
      'name': 'Ocean Cleanup Initiative',
      'location': 'Indian Ocean',
      'status': 'Active',
      'progress': 0.67,
      'carbonCredits': 450000,
      'startDate': '2023-09-01',
      'endDate': '2025-08-31',
      'description':
          'Removing plastic pollution from ocean gyres to restore marine ecosystems.',
      'investors': 67,
      'totalValue': 12000000,
      'type': 'Environmental Cleanup',
    },
    {
      'id': '5',
      'name': 'Urban Reforestation Program',
      'location': 'Sunderbans, W.B.',
      'status': 'Completed',
      'progress': 1.0,
      'carbonCredits': 125000,
      'startDate': '2021-04-01',
      'endDate': '2023-03-31',
      'description':
          'Planting 50,000 trees across urban areas to improve air quality.',
      'investors': 89,
      'totalValue': 5000000,
      'type': 'Reforestation',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<int> visibleIndices = _showAllProjects
        ? [0, 4, 2, 3, 1]
        : [0, 4, 2, 3];
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Blue background
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Header Section with Company Info
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Company Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 51),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Company Title
                        const Text(
                          'NeeLedger',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Company Description
                        const Text(
                          'Building Trust in Climate Action',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Leading the way in carbon credit verification and trading',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Empowering organizations to make a real environmental impact',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // Profile Button in top right corner
                  Positioned(
                    top: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 51),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF0D47A1),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Projects Summary Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F1416),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ongoing Projects',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Project List
                    ...visibleIndices
                        .map((i) => _buildProjectItem(_projects[i]))
                        .toList(),
                    if (!_showAllProjects) _buildShowMoreButton(),

                    const SizedBox(height: 32),

                    // Total Statistics
                    const Text(
                      'Platform Totals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildTotalCard(
                          'Carbon Converted',
                          '3.2M tonnes',
                          Icons.eco,
                          const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 16),
                        _buildTotalCard(
                          'Credits Generated',
                          '2.8M',
                          Icons.monetization_on,
                          const Color(0xFFFF9800),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        _buildTotalCard(
                          'Credits Sold',
                          '2.1M',
                          Icons.trending_up,
                          const Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 16),
                        _buildTotalCard(
                          'Revenue Generated',
                          '\$15.2M',
                          Icons.account_balance,
                          const Color(0xFF9C27B0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Contact Us Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Contact Us',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Have questions about our platform or carbon credit projects?',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.email, color: const Color(0xFF0D47A1)),
                              const SizedBox(width: 8),
                              const Text(
                                'contact@NeeLedger.com',
                                style: TextStyle(
                                  color: Color(0xFF0D47A1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${project['carbonCredits'] ~/ 1000}K tonnes CO₂',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: project['status'] == 'Active'
                    ? const Color(0xFF4CAF50).withValues(alpha: 51)
                    : project['status'] == 'Planning'
                    ? const Color(0xFFFF9800).withValues(alpha: 51)
                    : const Color(0xFF2196F3).withValues(alpha: 51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: project['status'] == 'Active'
                      ? const Color(0xFF4CAF50)
                      : project['status'] == 'Planning'
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF2196F3),
                ),
              ),
              child: Text(
                project['status'],
                style: TextStyle(
                  color: project['status'] == 'Active'
                      ? const Color(0xFF4CAF50)
                      : project['status'] == 'Planning'
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF2196F3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(
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
            Icon(icon, color: color, size: 32),
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

  Widget _buildShowMoreButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllProjects = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Show More',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.expand_more, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
