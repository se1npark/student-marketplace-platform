import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/campus_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _firebaseAuth.authStateChanges().listen(
      (user) => _controller.add(_mapUser(user)),
      onError: (error) {
        if (!_isKeychainError(error)) _controller.addError(error);
      },
      cancelOnError: false,
    );
  }

  final FirebaseAuth _firebaseAuth;
  final _controller = StreamController<CampusUser?>.broadcast();

  // macOS Firebase Auth cannot persist to keychain without code signing.
  // Fall back to the REST API so we can manually drive auth state.
  static const _apiKey = 'AIzaSyCBP4Rsm8lHzFLeiTB6v0M6P2iUSrUu_3k';

  @override
  CampusUser? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Stream<CampusUser?> authStateChanges() => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (_isKeychainError(error)) {
        await _restSignIn(email.trim(), password);
        return;
      }
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (error) {
      if (_isKeychainError(error)) {
        await _restRegister(name.trim(), email.trim(), password);
        return;
      }
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(_messageFor(error));
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut().catchError((_) {});
    _controller.add(null);
  }

  // ── REST API fallback (macOS keychain workaround) ──────────────────────

  // REST sign-in is used when the SDK throws a keychain error (macOS without
  // code signing). The response gives us the UID and display name so we can
  // push a CampusUser directly onto the stream without SDK persistence.
  Future<void> _restSignIn(String email, String password) async {
    final data = await _restPost('accounts:signInWithPassword', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    _controller.add(_userFromRestData(data));
  }

  Future<void> _restRegister(
    String name,
    String email,
    String password,
  ) async {
    final data = await _restPost('accounts:signUp', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    final idToken = data['idToken'] as String;
    await _restPost('accounts:update', {
      'idToken': idToken,
      'displayName': name,
      'returnSecureToken': false,
    });

    _controller.add(CampusUser(
      id: data['localId'] as String,
      email: email,
      displayName: name.isNotEmpty ? name : _displayNameFromEmail(email),
    ));
  }

  Future<Map<String, dynamic>> _restPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/$endpoint',
      {'key': _apiKey},
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final msg =
          ((json['error'] as Map?)?['message']) as String? ?? 'Unknown error';
      throw AuthException(_restErrorMessage(msg));
    }

    return json;
  }

  CampusUser _userFromRestData(Map<String, dynamic> data) {
    final email = data['email'] as String;
    return CampusUser(
      id: data['localId'] as String,
      email: email,
      displayName:
          (data['displayName'] as String?)?.isNotEmpty == true
              ? data['displayName'] as String
              : _displayNameFromEmail(email),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  CampusUser? _mapUser(User? user) {
    if (user == null) return null;
    return CampusUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : _displayNameFromEmail(user.email),
    );
  }

  String _displayNameFromEmail(String? email) {
    final localPart = email?.split('@').first.trim();
    if (localPart == null || localPart.isEmpty) return 'Campus seller';
    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  bool _isKeychainError(dynamic error) {
    if (error is! FirebaseAuthException) return false;
    return error.code == 'keychain-error' ||
        (error.message?.toLowerCase().contains('keychain') ?? false);
  }

  String _restErrorMessage(String code) {
    switch (code.toUpperCase()) {
      case 'INVALID_PASSWORD':
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email or password is incorrect.';
      case 'EMAIL_EXISTS':
        return 'An account already exists for that email.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed.';
    }
  }

  String _messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password must be stronger.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}
