import 'package:flutter/material.dart';
import 'project_details_screen.dart';

// The main function sets up the root application widget.
void main() {
  runApp(const ProjectsApp());
}

// Root Widget for the application
class ProjectsApp extends StatelessWidget {
  const ProjectsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenTech Projects',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2196F3),
        hintColor: const Color(0xFF4CAF50),
        fontFamily: 'Inter',
        // Use a dark background theme globally
        scaffoldBackgroundColor: const Color(0xFF0F1416),
        appBarTheme: const AppBarTheme(color: Color(0xFF0F1416), elevation: 0),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const ProjectsScreen(),
    );
  }
}

// Main Projects Listing Screen
class ProjectsScreen extends StatefulWidget {
  static const routeName = '/projects';

  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  // --- Static Project Data (6 Projects) ---
  final List<Map<String, dynamic>> _allProjects = [
    {
      'id': 1,
      'title': 'Solar Farm Initiative',
      'location': 'Mahandi Delta, Odisha',
      'status': 'Active',
      'progress': 85,
      'credits': 1250000,
      'investors': 45,
      'type': 'Renewable Energy',
      'description':
          'Large-scale solar installation project generating renewable energy and carbon credits.',
    },
    {
      'id': 2,
      'title': 'Kutch Conservation',
      'location': 'Gulf of Kutch, Gujrat',
      'status': 'Active',
      'progress': 92,
      'credits': 850000,
      'investors': 128,
      'type': 'Conservation',
      'description':
          'Protecting 500,000 hectares of pristine rainforest from deforestation.',
    },
    {
      'id': 3,
      'title': 'Urban Reforestation Program',
      'location': 'Sunderbans, W.B.',
      'status': 'Completed',
      'progress': 100,
      'credits': 125000,
      'investors': 89,
      'type': 'Reforestation',
      'description':
          'Planting 50,000 trees across urban areas to improve air quality.',
    },
    {
      'id': 4,
      'title': 'Wind Energy Project',
      'location': 'Bhitarkanika',
      'status': 'Planning',
      'progress': 25,
      'credits': 600000,
      'investors': 23,
      'type': 'Renewable Energy',
      'description':
          'Offshore wind farm development with advanced turbine technology.',
    },
    {
      'id': 5,
      'title': 'Ocean Cleanup Initiative',
      'location': 'Indian Ocean',
      'status': 'Active',
      'progress': 67,
      'credits': 450000,
      'investors': 67,
      'type': 'Environmental Cleanup',
      'description':
          'Removing plastic pollution from ocean gyres to restore marine ecosystems.',
    },
    {
      'id': 6,
      'title': 'Carbon Capture Initiative',
      'location': 'Mumbai, Maharashtra',
      'status': 'Requested',
      'progress': 0,
      'credits': 750000,
      'investors': 0,
      'type': 'Technology',
      'description':
          'Advanced carbon capture technology implementation in industrial zones.',
    },
  ];

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  String? _error;
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Active',
    'Planning',
    'Completed',
    'Requested',
  ];

  @override
  void initState() {
    super.initState();
    _loadStaticProjects();
  }

  // Load and sort the static project data
  void _loadStaticProjects() {
    _allProjects.sort(
      (a, b) => (b['progress'] as int).compareTo(a['progress'] as int),
    );
    setState(() {
      _projects = _allProjects;
      _isLoading = false;
    });
  }

  // Determine status color based on project status
  Color _getStatusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'planning':
        return const Color(0xFFFF9800); // Orange
      case 'completed':
        return const Color(0xFF2196F3); // Blue
      case 'requested':
        return const Color(0xFFFF5252); // Red
      default:
        return Colors.grey;
    }
  }

  // Compute filtered list based on the selected status filter
  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedFilter == 'All') return _projects;
    return _projects.where((p) {
      final s = (p['status'] ?? '').toString().toLowerCase();
      return s == _selectedFilter.toLowerCase();
    }).toList();
  }

  // Summary calculations
  int get _totalProjects => _projects.length;
  int get _activeProjects =>
      _projects.where((p) => p['status']?.toLowerCase() == 'active').length;
  int get _totalCredits =>
      _projects.fold(0, (sum, p) => sum + (p['credits'] ?? 0) as int);
  int get _portfolioValue => 100000000; // Static $100M value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Placeholder for upload or add project
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        child: const Icon(Icons.upload_file),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: _loadStaticProjects,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filters
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final f = _filters[i];
                    final selected = f == _selectedFilter;
                    return ActionChip(
                      label: Text(
                        f,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey[400],
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onPressed: () => setState(() => _selectedFilter = f),
                      backgroundColor: selected
                          ? const Color(0xFF0D47A1)
                          : const Color(0xFF1E1E1E),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFF2196F3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Portfolio Summary (Now takes 50% of remaining vertical space)
              Flexible(
                flex:
                    1, // Ensures this section takes half of the remaining space
                child: Container(
                  padding: const EdgeInsets.all(12), // Reduced padding
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1E1E1E).withOpacity(0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Portfolio Summary Title (Font size reduced to 14)
                      const Text(
                        'Portfolio Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Title size decreased from 18 to 14
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Dynamically determine card width for 2-column layout on smaller screens
                          final cardWidth = (constraints.maxWidth - 12) / 2 - 6;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildSummaryCard(
                                icon: Icons.business_center,
                                iconColor: Colors.blue,
                                label: 'Total Projects',
                                value: '$_totalProjects',
                                borderColor: Colors.blue,
                                textColor: Colors.white,
                                width: cardWidth,
                              ),
                              _buildSummaryCard(
                                icon: Icons.play_arrow,
                                iconColor: Colors.green,
                                label: 'Active Projects',
                                value: '$_activeProjects',
                                borderColor: Colors.green,
                                textColor: Colors.white,
                                width: cardWidth,
                              ),
                              _buildSummaryCard(
                                icon: Icons.square_foot,
                                iconColor: Colors.amber,
                                label: 'Total Credits',
                                value: _formatNumber(_totalCredits),
                                borderColor: Colors.amber,
                                textColor: Colors.white,
                                width: cardWidth,
                              ),
                              _buildSummaryCard(
                                icon: Icons.account_balance,
                                iconColor: Colors.orange,
                                label: 'Portfolio Value',
                                value:
                                    '\$${(_portfolioValue / 1000000).toStringAsFixed(0)}M',
                                borderColor: Colors.orange,
                                textColor: Colors.white,
                                width: cardWidth,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Project Cards List (Now takes the other 50% of remaining vertical space)
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2196F3),
                        ),
                      )
                    : (_error != null)
                    ? Center(
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _filteredProjects.isEmpty
                    ? Center(
                        child: Text(
                          'No ${_selectedFilter.toLowerCase()} projects match the current filter.',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, idx) {
                          final project = _filteredProjects[idx];
                          final status =
                              project['status']?.toString() ?? 'Unknown';
                          final statusColor = _getStatusColor(status);
                          return _buildProjectCard(
                            context,
                            project,
                            status,
                            statusColor,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for rendering a single project card
  Widget _buildProjectCard(
    BuildContext context,
    Map<String, dynamic> project,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
        color: const Color(0xFF1E1E1E),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project['title'] ?? 'Untitled',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white70,
                size: 14, // Reduced icon size
              ),
              const SizedBox(width: 4),
              Text(
                project['location'] ?? 'Unknown location',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14, // Consistent font size
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress Bar and Percentage
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (project['progress'] ?? 0) / 100,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${project['progress'] ?? 0}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Credits, Investors, Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(
                icon: Icons.square_foot,
                label: 'Credits',
                value: _formatNumber(project['credits']),
                color: Colors.amber,
              ),
              _buildInfoColumn(
                icon: Icons.people,
                label: 'Investors',
                value: project['investors']?.toString() ?? '0',
                color: Colors.greenAccent,
              ),
              _buildInfoColumn(
                icon: Icons.category,
                label: 'Type',
                value: project['type'] ?? 'Unknown',
                color: Colors.blueAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            project['description'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Buttons
          Row(
            children: [
              // Navigation to ProjectDetailsScreen
              ElevatedButton.icon(
                onPressed: () {
                  // Map project keys to expected keys in ProjectDetailsScreen
                  final mappedProject = {
                    'name': project['title'] ?? 'Untitled',
                    'status': project['status'] ?? 'Unknown',
                    'description': project['description'] ?? '',
                    'progress': (project['progress'] ?? 0) / 100,
                    'location': project['location'] ?? 'Unknown location',
                    'carbonCredits': project['credits'] ?? 0,
                    'investors': project['investors'] ?? 0,
                    'totalValue': 0, // No totalValue in original, set 0 or calculate
                    'startDate': '2023-01-01', // Placeholder dates
                    'endDate': '2023-12-31',
                    'type': project['type'] ?? 'Unknown',
                  };
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailsScreen(project: mappedProject),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('More Info'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // Placeholder for Invest action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.trending_up, size: 18),
                label: const Text('Invest'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget for the summary cards (Made more compact)
  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color borderColor,
    required Color textColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8), // Reduced padding
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1E1E1E),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24), // Reduced icon size
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Font size for values is 16
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
            ), // Reduced font size
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper widget for the info columns within project cards
  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20), // Reduced icon size
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }

  // Helper function to format large numbers
  String _formatNumber(int? number) {
    if (number == null) return '0';
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toString();
    }
  }
}
