import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/mock_user.dart';

class MockAuthService {
  MockUser? _currentUser;
  final _authStateController = StreamController<MockUser?>.broadcast();
  bool _isLoading = false;

  MockUser? get currentUser => _currentUser;
  Stream<MockUser?> get authStateChanges => _authStateController.stream;
  bool get isLoading => _isLoading;

  Future<MockUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // For development, accept any email/password combination
      final user = MockUser(
        uid: const Uuid().v4(),
        email: email,
        displayName: email.split('@')[0],
        emailVerified: true,
      );

      _currentUser = user;
      _authStateController.add(user);
      return user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<MockUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final user = MockUser(
        uid: const Uuid().v4(),
        email: email,
        displayName: email.split('@')[0],
        emailVerified: true,
      );

      _currentUser = user;
      _authStateController.add(user);
      return user;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (_currentUser != null) {
        _isLoading = true;
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        _currentUser = MockUser(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          displayName: displayName ?? _currentUser!.displayName,
          photoURL: photoURL ?? _currentUser!.photoURL,
          emailVerified: _currentUser!.emailVerified,
          isAnonymous: _currentUser!.isAnonymous,
        );

        _authStateController.add(_currentUser);
      }
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      _isLoading = false;
    }
  }

  void dispose() {
    _authStateController.close();
  }
}
