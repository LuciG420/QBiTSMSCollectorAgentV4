// lib/auth/auth_state.dart
import 'package:flutter/material.dart';
import 'package:app/auth/auth_service.dart';

class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userProfile;
  final AuthService _authService = AuthService();

  // Getter for _authService
  AuthService get authService => _authService;
  
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if(_isLoggedIn){
      await loadUserProfile();
    }
    notifyListeners();
  }


  Future<void> login() async {
    try {
      await _authService.login();
      _isLoggedIn = true;
      await loadUserProfile();
      notifyListeners();
    } catch (e) {
      print('Login failed in AuthState: $e');
      // Handle login error (e.g., show an error message)
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
      String? accessToken = await _authService.getAccessToken();
      if (accessToken != null) {
        _userProfile = await _authService.getUserProfile(accessToken);
      }
      notifyListeners();

  }


  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _userProfile = null;
    notifyListeners();
  }
}