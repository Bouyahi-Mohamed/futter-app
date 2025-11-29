import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _authService.login(email, password);
      if (!success) {
        _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _authService.signup(name, email, password);
      if (!success) {
        _errorMessage = 'فشل إنشاء الحساب، يرجى التأكد من البيانات';
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
