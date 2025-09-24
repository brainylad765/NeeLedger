import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class ProjectsScreen extends StatefulWidget {
  static const String routeName = '/projects';

  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final List<Map<String, dynamic>> _projects = [
    {
      'id': '1',
      'name': 'Solar Farm Initiative',
      'location': 'California, USA',
      'status': 'Active',
      'progress': 0.85,
      'carbonCredits': 1250000,
      'startDate': '2023-01-15',
      'endDate': '2025-12-31',
      'description': 'Large-scale solar installation project generating renewable energy and carbon credits.',
      'investors': 45,
      'totalValue': 25000000,
      'type': 'Renewable Energy',
    },
    {
      'id': '2',
      'name': 'Amazon Rainforest Conservation',
      'location': 'Amazonas, Brazil',
      'status': 'Active',
      'progress': 0.92,
      'carbonCredits': 850000,
      'startDate': '2022-06-01',
      'endDate': '2032-05-31',
      'description': 'Protecting 500,000 hectares of pristine rainforest from deforestation.',
      'investors': 128,
      'totalValue': 15000000,
      'type': 'Conservation',
    },
    {
      'id': '3',
      'name': 'Wind Energy Project',
      'location': 'Texas, USA',
      'status': 'Planning',
      'progress': 0.25,
      'carbonCredits': 600000,
      'startDate': '2024-03-01',
      'endDate': '2026-02-28',
      'description': 'Offshore wind farm development with advanced turbine technology.',
      'investors': 23,
      'totalValue': 18000000,
      'type': 'Renewable Energy',
    },
    {
      'id': '4',
      'name': 'Ocean Cleanup Initiative',
      'location': 'Pacific Ocean',
      'status': 'Active',
      'progress': 0.67,
      'carbonCredits': 450000,
      'startDate': '2023-09-01',
      'endDate': '2025-08-31',
      'description': 'Removing plastic pollution from ocean gyres to restore marine ecosystems.',
      'investors': 67,
      'totalValue': 12000000,
      'type': 'Environmental Cleanup',
    },
    {
      'id': '5',
      'name': 'Urban Reforestation Program',
      'location': 'New York, USA',
      'status': 'Completed',
      'progress': 1.0,
      'carbonCredits': 125000,
      'startDate': '2021-04-01',
      'endDate': '2023-03-31',
      'description': 'Planting 50,000 trees across urban areas to improve air quality.',
      'investors': 89,
      'totalValue': 5000000,
      'type': 'Reforestation',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Planning', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final filteredProjects = _selectedFilter == 'All'
        ? _projects
        : _projects.where((project) => project['status'] == _selectedFilter).toList();

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
                          color: _selectedFilter == filter ? Colors.white : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Projects List
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
                    color: const Color(0xFF0D47A1).withOpacity(0.3),
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
                          '${_projects.where((p) => p['status'] == 'Active').length}',
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
                          '${_projects.fold(0, (sum, p) => sum + (p['carbonCredits'] as int))}',
                          Icons.eco,
                          const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 16),
                        _buildSummaryCard(
                          'Portfolio Value',
                          '\$${_projects.fold(0, (sum, p) => sum + (p['totalValue'] as int)) ~/ 1000000}M',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(project['status']).withOpacity(0.3),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(project['status']).withOpacity(0.2),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${((project['progress'] as double) * 100).toInt()}%',
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
                value: project['progress'],
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
                child: _buildDetailItem(
                  'Credits',
                  '${project['carbonCredits'] ~/ 1000}K',
                  Icons.eco,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Investors',
                  '${project['investors']}',
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
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View Details',
                  onPressed: () {
                    _showProjectDetails(project);
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
        Icon(icon, color: const Color(0xFF0D47A1), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
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

  void _showProjectDetails(Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                project['description'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Location', project['location']),
              _buildDetailRow('Status', project['status']),
              _buildDetailRow('Type', project['type']),
              _buildDetailRow('Start Date', project['startDate']),
              _buildDetailRow('End Date', project['endDate']),
              _buildDetailRow('Carbon Credits', '${project['carbonCredits'] ~/ 1000}K tonnes'),
              _buildDetailRow('Investors', '${project['investors']}'),
              _buildDetailRow('Total Value', '\$${(project['totalValue'] as int) ~/ 1000000}M'),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvestmentDialog(Map<String, dynamic> project) {
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
              'Project Value: \$${(project['totalValue'] as int) ~/ 1000000}M',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Investment Amount (\$)',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
