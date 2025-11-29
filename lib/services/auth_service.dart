import 'dart:async';

class AuthService {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    // Mock validation
    if (email.isNotEmpty && password.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      return true;
    }
    return false;
  }
}
