import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
  AppUser? user;
  bool isLoading = true;
  ThemeMode themeMode = ThemeMode.system;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    user = await _authService.currentUser();
    isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();
    user = await _authService.signInWithGoogle();
    isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required String name,
    required bool createAccount,
  }) async {
    isLoading = true;
    notifyListeners();
    user = await _authService.signInWithEmail(
      email: email,
      password: password,
      name: name,
      createAccount: createAccount,
    );
    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

