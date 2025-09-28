import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/upload_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import 'project_details_screen.dart';

class YourProjectsScreen extends StatefulWidget {
  YourProjectsScreen({Key? key}) : super(key: key);
  static const routeName = '/your-projects';

  @override
  State<YourProjectsScreen> createState() => _YourProjectsScreenState();
}

class _YourProjectsScreenState extends State<YourProjectsScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Planning', 'Completed'];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final projects = await _apiService.fetchUserProjects();
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
      if (_projects.isEmpty) {
        _showNoProjectsSnackbar();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showNoProjectsSnackbar();
    }
  }

  void _showNoProjectsSnackbar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No projects initiated yet. Please upload documents in the Uploads section.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1416),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
          ),
        ),
      );
    }

    final filteredProjects = _selectedFilter == 'All'
        ? _projects
        : _projects
              .where((project) => project['status'] == _selectedFilter)
              .toList();

    final int totalCredits = _projects.fold(
      0,
      (sum, p) => sum + ((p['carbonCredits'] ?? 0) as int),
    );
    final int totalValue = _projects.fold(
      0,
      (sum, p) => sum + ((p['totalValue'] ?? 0) as int),
    );
    final int activeProjectsCount = _projects
        .where((p) => p['status'] == 'Active')
        .length;
    final int portfolioValueM = totalValue ~/ 1000000;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Filter Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        backgroundColor: const Color(0xFF1E1E1E),
                        selectedColor: const Color(0xFF0D47A1),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Projects List
              if (filteredProjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.business_center,
                        color: Colors.grey[600],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No projects found',
                        style: TextStyle(color: Colors.grey[400], fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/uploads');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                        ),
                        child: const Text('Go to Uploads'),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  itemCount: filteredProjects.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return _buildProjectCard(project);
                  },
                ),

              const SizedBox(height: 32),

              // Summary Statistics
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0D47A1).withAlpha(77),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Portfolio Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Total Projects',
                          '${_projects.length}',
                          Icons.business_center,
                          const Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          'Active Projects',
                          '$activeProjectsCount',
                          Icons.play_circle,
                          const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Total Credits',
                          '$totalCredits',
                          Icons.eco,
                          const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          'Portfolio Value',
                          '\$$portfolioValueM M',
                          Icons.account_balance,
                          const Color(0xFFFF9800),
                        ),
                      ],
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

  Widget _buildProjectCard(Map<String, dynamic> project) {
    final double progress = project['progress'] as double;
    final int progressPercent = (progress * 100).toInt();
    final int carbonCredits = project['carbonCredits'] as int;
    final int creditsK = carbonCredits ~/ 1000;
    final int investors = project['investors'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(project['status']).withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Header
          Row(
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          project['location'],
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(project['status']).withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(project['status'])),
                ),
                child: Text(
                  project['status'],
                  style: TextStyle(
                    color: _getStatusColor(project['status']),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    '$progressPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(project['status']),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Project Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Credits', '$creditsK K', Icons.eco),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Investors',
                  '$investors',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Type',
                  project['type'],
                  Icons.category,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            project['description'],
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'More Info',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailsScreen(project: project),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Invest',
                  onPressed: () {
                    _showInvestmentDialog(project);
                  },
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        icon == Icons.eco
            ? ImageIcon(
                AssetImage('assets/images/logo.png'),
                color: const Color(0xFF0D47A1),
                size: 20,
              )
            : Icon(icon, color: const Color(0xFF0D47A1), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _buildSummaryCard(
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
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            icon == Icons.eco
                ? ImageIcon(
                    AssetImage('assets/images/logo.png'),
                    color: color,
                    size: 24,
                  )
                : Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF4CAF50);
      case 'Planning':
        return const Color(0xFFFF9800);
      case 'Completed':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  void _showInvestmentDialog(Map<String, dynamic> project) {
    final int projectValue = (project['totalValue'] as int) ~/ 1000000;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Invest in ${project['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Project Value: \$${projectValue}M',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Investment Amount (USD)',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0D47A1)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Invest'),
          ),
        ],
      ),
    );
  }
}
