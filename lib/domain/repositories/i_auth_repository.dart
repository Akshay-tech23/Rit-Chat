/// Contract for Authentication Repository
/// Keeps your business logic independent from Firebase or any backend.
abstract class IAuthRepository {
  /// Stream of authentication state (null if signed out).
  Stream<UserEntity?> get user;

  /// Signs in with email + password.
  Future<UserEntity?> signInWithEmail(String email, String password);

  /// Signs out the current user.
  Future<void> signOut();
}

/// Minimal user entity (can expand later).
class UserEntity {
  final String id;
  final String email;

  UserEntity({required this.id, required this.email});
}
