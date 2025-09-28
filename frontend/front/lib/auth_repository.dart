import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  // Corresponds to the Design Document's AuthService.signUp
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Create user profile after signup
  Future<void> createProfile({
    required String userId,
    required String fullName,
    required String mobile,
    required bool isProjectProponent,
    required bool hasCompletedKYC,
  }) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'full_name': fullName,
      'mobile': mobile,
      'user_type': isProjectProponent ? 'project_proponent' : 'retailer',
      'kyc_completed': hasCompletedKYC,
    });
  }

  // Corresponds to the Design Document's AuthService.signIn
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Corresponds to the Design Document's AuthService.signOut
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
