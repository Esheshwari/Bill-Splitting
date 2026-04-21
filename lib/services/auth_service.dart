import '../models/app_user.dart';

abstract class AuthService {
  Future<AppUser?> currentUser();
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
    required String name,
    bool createAccount,
  });
  Future<void> signOut();
}

class DemoAuthService implements AuthService {
  AppUser? _user;

  @override
  Future<AppUser?> currentUser() async => _user;

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
    required String name,
    bool createAccount = false,
  }) async {
    _user = AppUser(
      id: 'demo-user',
      name: name.isEmpty ? 'Demo User' : name,
      email: email,
      avatarUrl: '',
    );
    return _user!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    _user = const AppUser(
      id: 'demo-user',
      name: 'Demo User',
      email: 'demo@splitsmart.app',
      avatarUrl: '',
    );
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

