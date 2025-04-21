import 'package:flutter/foundation.dart';
import '../../../core/services/mock_auth_service.dart';
import '../../../core/models/mock_user.dart';

class AuthProvider extends ChangeNotifier {
  final MockAuthService _auth = MockAuthService();
  MockUser? _user;
  bool _isLoading = false;

  MockUser? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges.listen((MockUser? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<MockUser?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _auth.signInWithEmailAndPassword(email, password);
      _user = user;
      return user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MockUser?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _auth.createUserWithEmailAndPassword(email, password);
      _user = user;
      return user;
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

      await _auth.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      _user = _auth.currentUser;
    } catch (e) {
      print('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }
}
