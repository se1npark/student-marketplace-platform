import 'dart:async';

import 'package:uuid/uuid.dart';

import '../models/campus_user.dart';
import 'auth_repository.dart';

class MemoryAuthRepository implements AuthRepository {
  MemoryAuthRepository({List<MemoryAccount> accounts = const []}) {
    for (final account in accounts) {
      _accounts[account.user.email.toLowerCase()] = account;
    }
  }

  factory MemoryAuthRepository.withDemoUser() {
    return MemoryAuthRepository(
      accounts: const [
        MemoryAccount(
          user: CampusUser(
            id: 'demo-user-sein',
            email: 'sein.park@students.mq.edu.au',
            displayName: 'Sein Park',
          ),
          password: 'CampusCart1!',
        ),
      ],
    );
  }

  final Map<String, MemoryAccount> _accounts = {};
  final StreamController<CampusUser?> _controller =
      StreamController<CampusUser?>.broadcast();
  CampusUser? _currentUser;

  @override
  CampusUser? get currentUser => _currentUser;

  @override
  Stream<CampusUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final account = _accounts[email.toLowerCase().trim()];
    if (account == null || account.password != password) {
      throw const AuthException('Email or password is incorrect.');
    }

    _currentUser = account.user;
    _controller.add(_currentUser);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();
    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthException('An account already exists for that email.');
    }

    if (password.length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }

    final user = CampusUser(
      id: const Uuid().v4(),
      email: normalizedEmail,
      displayName: name.trim(),
    );

    _accounts[normalizedEmail] = MemoryAccount(user: user, password: password);
    _currentUser = user;
    _controller.add(_currentUser);
  }

  @override
  Future<void> resetPassword(String email) async {
    final normalizedEmail = email.toLowerCase().trim();
    if (!_accounts.containsKey(normalizedEmail)) {
      throw const AuthException('Enter a registered email address.');
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

class MemoryAccount {
  const MemoryAccount({required this.user, required this.password});

  final CampusUser user;
  final String password;
}
