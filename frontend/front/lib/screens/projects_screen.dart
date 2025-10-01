import 'package:flutter/material.dart';

// NOTE: External imports like file_picker, supabase, project_details_screen,
// and custom_button are removed as this is a UI replica with static data.

// Mock Project Details Screen for navigation placeholder
class ProjectDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project['title'] ?? 'Details'),
        backgroundColor: const Color(0xFF0F1416),
      ),
      body: Center(
        child: Text('Details for ${project['title']}', style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: const Color(0xFF0F1416),
    );
  }
}

class ProjectsScreen extends StatefulWidget {
  static const routeName = '/projects';

  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  // --- Static Project Data (8 Projects) ---
  final List<Map<String, dynamic>> _allProjects = [
    {
      'id': 1,
      'title': 'E-Commerce Replatforming',
      'status': 'Active',
      'file_url': 'https://docs.link/ec-replatform-v3.pdf',
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 2,
      'title': 'Mobile App V2 Launch',
      'status': 'Completed',
      'file_url': 'https://docs.link/mobile-app-v2.pdf',
      'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    },
    {
      'id': 3,
      'title': 'Q3 Marketing Campaign',
      'status': 'Planning',
      'file_url': 'https://docs.link/q3-marketing-plan.docx',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 4,
      'title': 'Data Warehouse Migration',
      'status': 'Active',
      'file_url': 'https://docs.link/dw-migration-sow.pdf',
      'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
    {
      'id': 5,
      'title': 'New Client Onboarding Flow',
      'status': 'Requested',
      'file_url': 'https://docs.link/onboarding-request.doc',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 6,
      'title': 'Server Infrastructure Upgrade',
      'status': 'Completed',
      'file_url': 'https://docs.link/server-upgrade-report.pdf',
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    },
    {
      'id': 7,
      'title': 'Internal Tool Development',
      'status': 'Planning',
      'file_url': 'https://docs.link/internal-tool-spec.docx',
      'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    },
    {
      'id': 8,
      'title': 'Annual Budget Review 2026',
      'status': 'Active',
      'file_url': 'https://docs.link/budget-2026-draft.pdf',
      'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false; // Set to false since data is static
  String? _error;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Planning', 'Completed', 'Requested'];

  @override
  void initState() {
    super.initState();
    // Simulate fetching/loading with static data
    _loadStaticProjects();
  }

  void _loadStaticProjects() {
    // Sort statically by 'created_at' to mimic 'order by' from the original code
    _allProjects.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    setState(() {
      _projects = _allProjects;
      _isLoading = false;
    });
  }

  Future<void> _mockUploadDocument() async {
    // Mock upload function
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mock Upload: Project creation feature placeholder.')),
      );
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50); // Green
      case 'planning':
        return const Color(0xFFFF9800); // Orange
      case 'completed':
        return const Color(0xFF2196F3); // Blue
      case 'requested':
        return const Color(0xFFFF5252); // Red (A brighter red for visibility)
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get _filteredProjects {
    if (_selectedFilter == 'All') return _projects;
    return _projects.where((p) {
      final s = (p['status'] ?? '').toString().toLowerCase();
      return s == _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416), // Dark background
      floatingActionButton: FloatingActionButton(
        onPressed: _mockUploadDocument,
        backgroundColor: const Color(0xFF0D47A1), // Blue button
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D47A1), // Deep Blue icon background
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
                    onPressed: _loadStaticProjects, // Mock refresh
                  )
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
                    return ActionChip( // Used ActionChip for better responsiveness than ChoiceChip
                      label: Text(f, style: TextStyle(
                        color: selected ? Colors.white : Colors.grey[400],
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      )),
                      onPressed: () => setState(() => _selectedFilter = f),
                      backgroundColor: selected ? const Color(0xFF0D47A1) : const Color(0xFF1E1E1E),
                      side: BorderSide(
                        color: selected ? const Color(0xFF2196F3) : Colors.grey.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Body
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
                    : (_error != null)
                        ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                        : _filteredProjects.isEmpty
                            ? const Center(child: Text('No projects match the current filter.', style: TextStyle(color: Colors.white70)))
                            : ListView.builder(
                                itemCount: _filteredProjects.length,
                                itemBuilder: (context, idx) {
                                  final project = _filteredProjects[idx];
                                  final status = project['status']?.toString() ?? 'Unknown';
                                  final statusColor = _getStatusColor(status);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.6),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material( // Use Material for tap ripple effect
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ProjectDetailsScreen(project: project),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      project['title'] ?? 'Untitled',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    // Status Tag
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: statusColor.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        status,
                                                        style: TextStyle(
                                                          color: statusColor,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // File URL (Simplified display)
                                                    if (project['file_url'] != null)
                                                      Text(
                                                        project['file_url'].toString().split('/').last,
                                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.chevron_right, color: Colors.white70),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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
}
