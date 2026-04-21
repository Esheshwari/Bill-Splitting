import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<AppUser?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
    required String name,
    bool createAccount = false,
  }) async {
    final credentials = createAccount
        ? await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
        : await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

    if (createAccount && name.isNotEmpty) {
      await credentials.user?.updateDisplayName(name);
    }

    return _mapUser(credentials.user!);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled.');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return _mapUser(result.user!);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  AppUser _mapUser(User user) {
    return AppUser(
      id: user.uid,
      name: user.displayName ?? 'SplitSmart User',
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
    );
  }
}

