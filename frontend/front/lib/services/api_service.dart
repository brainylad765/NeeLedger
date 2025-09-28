import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/project_model.dart';

class ApiService {
  static const String baseUrl =
      'https://api.NeeLedger.com'; // Replace with actual API URL

  Future<User> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<Transaction>> fetchTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch transactions');
    }
  }

  Future<void> buyCredits(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buy'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to buy credits');
    }
  }

  Future<void> sellCredits(double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sell'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sell credits');
    }
  }

  Future<void> uploadDocumentMetadata(
    String downloadURL,
    String fileName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/upload-document'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'downloadURL': downloadURL,
        'fileName': fileName,
        // Add user ID or other metadata as needed
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload document metadata');
    }
  }

  Future<List<Project>> fetchUserProjects() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await supabase
        .from('projects')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((json) => Project.fromJson(json)).toList();
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
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final projectData = {
      'id': const Uuid().v4(),
      'user_id': userId,
      'name': name,
      'status': status,
      'evidence_id': evidenceId,
      'carbon_credits': carbonCredits,
      'total_value': totalValue,
      'progress': progress,
      'location': location,
      'type': type,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await supabase.from('projects').insert(projectData);
    if (response.isEmpty) {
      throw Exception('Failed to create project');
    }

    return projectData['id'] as String;
  }
}
