import 'package:flutter/material.dart';
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
  Future<bool> login({required String email, required String role}) async {
    try {
      // TODO: Implement actual login with Firebase/Django
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock user creation
      final user = User(
        id: '1',
        name: email.split('@')[0],
        email: email,
        walletAddress: '0x${DateTime.now().millisecondsSinceEpoch.toString()}',
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

  Future<bool> signup({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // TODO: Implement actual signup with Firebase/Django
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock user creation
      final user = User(
        id: '1',
        name: email.split('@')[0],
        email: email,
        walletAddress: '0x${DateTime.now().millisecondsSinceEpoch.toString()}',
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
