import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateCredits(double newCredits) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        walletAddress: _currentUser!.walletAddress,
        credits: newCredits,
      );
      notifyListeners();
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // BlockZen specific methods
  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      final userData = userDoc.data()!;

      final user = User(
        id: userCredential.user!.uid,
        name: userData['name'] ?? 'User',
        email: email,
        walletAddress:
            userData['walletAddress'] ?? '0x${userCredential.user!.uid}',
        credits: (userData['credits'] ?? 1000.0).toDouble(),
        role: userData['role'] ?? role,
        memberSince: (userData['memberSince'] as Timestamp).toDate(),
      );

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    try {
      final userCredential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name ?? 'User',
            'email': email,
            'walletAddress': '0x${userCredential.user!.uid}',
            'credits': 1000.0,
            'role': role,
            'memberSince': Timestamp.now(),
          });

      final user = User(
        id: userCredential.user!.uid,
        name: name ?? 'User',
        email: email,
        walletAddress: '0x${userCredential.user!.uid}',
        credits: 1000.0,
        role: role,
        memberSince: DateTime.now(),
      );

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
