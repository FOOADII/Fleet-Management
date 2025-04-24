import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../../core/models/mock_user.dart' as models;

class AuthProvider extends ChangeNotifier {
  final MockAuthService _auth = MockAuthService();
  models.MockUser? _user;
  bool _isLoading = false;

  models.MockUser? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _user = _convertToMockUser(firebaseUser);
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // Helper method to convert Firebase User to our MockUser
  models.MockUser _convertToMockUser(User firebaseUser) {
    return models.MockUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      emailVerified: firebaseUser.emailVerified,
    );
  }

  Future<models.MockUser?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential =
          await _auth.signInWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        _user = _convertToMockUser(userCredential.user!);
        return _user;
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<models.MockUser?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential =
          await _auth.createUserWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        _user = _convertToMockUser(userCredential.user!);
        return _user;
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signOut();
      _user = null;
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Since updateProfile is not defined in MockAuthService, we'll implement a simple version
      if (_user != null) {
        // In a real implementation, this would update the user's profile
        // For now, we'll just print a message
        print('Profile updated: displayName=$displayName, photoURL=$photoURL');
      }
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Since dispose is not defined in MockAuthService, we'll just call super.dispose()
    super.dispose();
  }
}
