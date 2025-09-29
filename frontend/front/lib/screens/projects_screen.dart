import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'project_details_screen.dart';
import '../widgets/custom_button.dart';

class ProjectsScreen extends StatefulWidget {
  static const routeName = '/projects';

  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
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
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      // res will be `List<Map<String, dynamic>>` on success
      setState(() {
        _projects = res ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: kIsWeb, // ensure bytes are available on web
      );
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.single;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final bucket =
          'projects'; // ensure this bucket exists in Supabase Storage
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not signed in — cannot upload.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      // Upload differently for web and mobile
      if (kIsWeb) {
        // on web we have bytes in picked.bytes
        if (picked.bytes == null) {
          throw Exception('No file bytes found on web.');
        }
        final Uint8List data = picked.bytes!;
        // Supabase Flutter supports uploadBinary for web
        await supabase.storage.from(bucket).uploadBinary(fileName, data);
      } else {
        // mobile: use File(path)
        if (picked.path == null) throw Exception('No file path.');
        final file = File(picked.path!);
        await supabase.storage.from(bucket).upload(fileName, file);
      }

      // Get public URL
      final publicUrlResponse = supabase.storage
          .from(bucket)
          .getPublicUrl(fileName);
      final fileUrl = publicUrlResponse; // string

      // Insert metadata row into projects table
      final insertRes = await supabase
          .from('projects')
          .insert({
            'user_id': user.id,
            'title': picked.name,
            'file_url': fileUrl,
            'status': 'Requested', // default status - change if you want
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded and project created.')),
      );

      // refresh list
      await _fetchProjects();
    } catch (e, st) {
      debugPrint('Upload error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      setState(() => _isLoading = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'planning':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF2196F3);
      case 'requested':
        return Colors.red;
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
      backgroundColor: const Color(0xFF0F1416),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadDocument,
        child: const Icon(Icons.upload_file),
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: _fetchProjects,
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
                    return ChoiceChip(
                      label: Text(f),
                      selected: selected,
                      onSelected: (sel) => setState(() => _selectedFilter = f),
                      selectedColor: const Color(0xFF0D47A1),
                      backgroundColor: const Color(0xFF1E1E1E),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Body
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_error != null)
                    ? Center(
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _filteredProjects.isEmpty
                    ? const Center(
                        child: Text(
                          'No projects yet. Upload one!',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, idx) {
                          final project = _filteredProjects[idx];
                          final status =
                              project['status']?.toString() ?? 'Unknown';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(status).withOpacity(0.6),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                project['title'] ?? 'Untitled',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    'Status: $status',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  if (project['file_url'] != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      project['file_url'].toString(),
                                      style: TextStyle(
                                        color: Colors.blue[300],
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  // open project details or launch URL using url_launcher
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProjectDetailsScreen(
                                        project: project,
                                      ),
                                    ),
                                  );
                                },
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
