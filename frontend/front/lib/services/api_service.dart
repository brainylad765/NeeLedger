import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/transaction_model.dart';

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
}
