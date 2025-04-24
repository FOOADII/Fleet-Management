import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'auth_service.dart';

class MockAuthService extends GetxService implements AuthService {
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();
  final _organizationId = RxString('ddu-fleet');
  bool _isLoading = false;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  String get organizationId => _organizationId.value;

  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock UserCredential
      final credential = MockUserCredential();
      _currentUser = credential.user;
      _authStateController.add(_currentUser);

      return credential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock UserCredential
      final credential = MockUserCredential();
      _currentUser = credential.user;
      _authStateController.add(_currentUser);

      return credential;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));
      print('Mock password reset email sent to: $email');
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));
      print('Mock password updated');
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> verifyEmail() async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));
      if (_currentUser != null) {
        // Update email verification status
        _currentUser = MockUser(
          uid: const Uuid().v4(),
          email: 'mock@example.com',
          emailVerified: true,
        );
        _authStateController.add(_currentUser);
      }
    } catch (e) {
      print('Error verifying email: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> updateEmail(String email) async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));
      if (_currentUser != null) {
        _currentUser = MockUser(
          uid: const Uuid().v4(),
          email: email,
          emailVerified: false,
        );
        _authStateController.add(_currentUser);
      }
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));
      print('Mock email verification sent');
    } catch (e) {
      print('Error sending email verification: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      _isLoading = true;
      await Future.delayed(const Duration(seconds: 1));

      final credential = MockUserCredential();
      _currentUser = credential.user;
      _authStateController.add(_currentUser);

      return credential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  @override
  void onClose() {
    _authStateController.close();
    super.onClose();
  }
}

// Mock implementation of User
class MockUser implements User {
  final String uid;
  final String email;
  final bool emailVerified;

  MockUser({
    required this.uid,
    required this.email,
    this.emailVerified = false,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock implementation of UserCredential
class MockUserCredential implements UserCredential {
  @override
  final User? user = MockUser(
    uid: const Uuid().v4(),
    email: 'mock@example.com',
    emailVerified: true,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
