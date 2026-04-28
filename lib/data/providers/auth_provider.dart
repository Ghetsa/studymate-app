import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserCredential?> login(String email, String password) async {
    return _runAuthAction(() => _authService.login(email, password));
  }

  Future<UserCredential?> register(String email, String password) async {
    return _runAuthAction(() => _authService.register(email, password));
  }

  Future<void> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.logout();
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? 'Failed to logout.';
    } catch (_) {
      errorMessage = 'An unexpected error occurred.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> _runAuthAction(
    Future<UserCredential> Function() action,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? 'Authentication failed.';
      return null;
    } catch (_) {
      errorMessage = 'An unexpected error occurred.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
