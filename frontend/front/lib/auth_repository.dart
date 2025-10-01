import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Corresponds to the Design Document's AuthService.signUp
  Future<UserCredential> signUp(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  // Create user profile after signup
  Future<void> createProfile({
    required String userId,
    required String fullName,
    required String mobile,
    required bool isProjectProponent,
    required bool hasCompletedKYC,
  }) async {
    await _firestore.collection('profiles').doc(userId).set({
      'id': userId,
      'full_name': fullName,
      'mobile': mobile,
      'user_type': isProjectProponent ? 'project_proponent' : 'retailer',
      'kyc_completed': hasCompletedKYC,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Corresponds to the Design Document's AuthService.signIn
  Future<UserCredential> signIn(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  // Corresponds to the Design Document's AuthService.signOut
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
