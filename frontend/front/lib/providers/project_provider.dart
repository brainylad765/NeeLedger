import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';

class ProjectProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProjectProvider() {
    _listenToProjects();
  }

  void _listenToProjects() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Real-time subscription to projects table
    final subscription = _supabase
        .channel('projects')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'projects',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            _fetchProjects(); // Refresh on change
          },
        )
        .subscribe();

    // Initial fetch
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('projects')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _projects.clear();
      for (final json in response) {
        _projects.add(Project.fromJson(json));
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> refreshProjects() async {
    await _fetchProjects();
  }

  Future<String> createProject({
    required String name,
    String status = 'Planning',
    String? evidenceId,
    int carbonCredits = 0,
    int totalValue = 0,
    double progress = 0.0,
    String? location,
    String? type,
    String? description,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final projectData = {
        'id': const Uuid().v4(),
        'user_id': userId,
        'account_id': 'ACC-DEFAULT',
        'name': name,
        'status': status,
        'evidence_id': evidenceId,
        'carbon_credits': carbonCredits,
        'credits_issued': 0,
        'total_value': totalValue,
        'progress': progress,
        'location': location,
        'type': type,
        'country': 'Unknown',
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase.from('projects').insert(projectData);
      if (response.isEmpty) {
        throw Exception('Failed to create project');
      }

      // Refresh to include new project
      await _fetchProjects();
      return projectData['id'] as String;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _error = error;
  }

  @override
  void dispose() {
    _supabase.removeAllChannels();
    super.dispose();
  }
}
