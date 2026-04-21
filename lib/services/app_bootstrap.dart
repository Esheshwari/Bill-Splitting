import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import 'auth_service.dart';
import 'expense_repository.dart';
import 'firebase_auth_service.dart';
import 'firebase_expense_repository.dart';
import 'mock_expense_repository.dart';

class AppBootstrapResult {
  const AppBootstrapResult({
    required this.authService,
    required this.repository,
    required this.usingFirebase,
  });

  final AuthService authService;
  final ExpenseRepository repository;
  final bool usingFirebase;
}

class AppBootstrapService {
  static Future<AppBootstrapResult> initialize() async {
    try {
      // Launch with Firebase when configured, but keep the app demoable offline.
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return AppBootstrapResult(
        authService: FirebaseAuthService(),
        repository: FirebaseExpenseRepository(),
        usingFirebase: true,
      );
    } catch (_) {
      return AppBootstrapResult(
        authService: DemoAuthService(),
        repository: MockExpenseRepository(),
        usingFirebase: false,
      );
    }
  }
}
