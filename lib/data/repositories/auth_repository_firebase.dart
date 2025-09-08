import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email/password
  Future<User?> signIn(String email, String password) async {
    if (!email.endsWith("@ritrjpm.ac.in")) {
      throw Exception("Only @ritrjpm.ac.in emails are allowed");
    }
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Sign up new user
  Future<User?> signUp(String email, String password) async {
    if (!email.endsWith("@ritrjpm.ac.in")) {
      throw Exception("Only @ritrjpm.ac.in emails are allowed");
    }
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Forgot Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check current user
  User? get currentUser => _auth.currentUser;
}
