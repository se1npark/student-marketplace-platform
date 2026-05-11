import '../models/campus_user.dart';

abstract class AuthRepository {
  Stream<CampusUser?> authStateChanges();

  CampusUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
