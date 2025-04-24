import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  // Form keys for different screens - using unique keys
  final loginScreenFormKey =
      GlobalKey<FormState>(debugLabel: 'login_screen_form');
  final loginViewFormKey = GlobalKey<FormState>(debugLabel: 'login_view_form');
  final registerFormKey = GlobalKey<FormState>(debugLabel: 'register_form');
  final forgotPasswordFormKey =
      GlobalKey<FormState>(debugLabel: 'forgot_password_form');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isAuthenticated = false.obs;

  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    debugPrint('AuthController onInit called');

    // Listen to authentication state changes
    _authService.authStateChanges.listen((User? user) {
      isAuthenticated.value = user != null;
      if (user != null) {
        debugPrint('User authenticated: ${user.uid}');
      } else {
        debugPrint('User signed out');
      }
    });
  }

  @override
  void onClose() {
    debugPrint('AuthController onClose called');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> handleLogin() async {
    // First check which form key was used
    final formKey = Get.currentRoute == Routes.login
        ? loginScreenFormKey
        : loginViewFormKey;

    if (!formKey.currentState!.validate()) {
      debugPrint('AuthController: Form validation failed');
      return;
    }

    try {
      debugPrint('AuthController: Starting login process');
      isLoading.value = true;

      final userCredential = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (userCredential.user != null) {
        debugPrint(
            'AuthController: Login successful - user: ${userCredential.user?.uid}');
        Get.offAllNamed(Routes.home);
      } else {
        throw 'Login failed - no user returned';
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'AuthController: FirebaseAuthException during login: ${e.code}');
      _handleAuthError(e);
    } catch (e, stackTrace) {
      debugPrint('AuthController: Unexpected error during login: $e');
      debugPrint('Stack trace: $stackTrace');
      _showErrorSnackbar('An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleGoogleSignIn() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential.user != null) {
        debugPrint(
            'AuthController: Google sign in successful - user: ${userCredential.user?.uid}');
        Get.offAllNamed(Routes.home);
      } else {
        throw 'Google sign in failed - no user returned';
      }
    } catch (e) {
      debugPrint('AuthController: Google sign in failed: $e');
      _showErrorSnackbar('Failed to sign in with Google');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleRegister() async {
    if (!registerFormKey.currentState!.validate()) {
      debugPrint('AuthController: Registration form validation failed');
      return;
    }

    try {
      debugPrint('AuthController: Starting registration process');
      isLoading.value = true;

      final userCredential = await _authService.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        debugPrint(
            'AuthController: Registration successful - user: ${userCredential.user?.uid}');
        Get.offAllNamed(Routes.home);
      } else {
        throw 'Registration failed - no user returned';
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'AuthController: FirebaseAuthException during registration: ${e.code}');
      _handleAuthError(e);
    } catch (e) {
      debugPrint('AuthController: Unexpected error during registration: $e');
      _showErrorSnackbar('An unexpected error occurred during registration');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleSignOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('AuthController: Sign out failed: $e');
      _showErrorSnackbar('Failed to sign out');
    }
  }

  Future<void> handleForgotPassword() async {
    if (!forgotPasswordFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      await _authService.sendPasswordResetEmail(emailController.text.trim());
      Get.snackbar(
        'Success',
        'Password reset email sent. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send password reset email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email';
        break;
      case 'wrong-password':
        message = 'Wrong password provided';
        break;
      case 'invalid-email':
        message = 'The email address is badly formatted';
        break;
      case 'user-disabled':
        message = 'This user has been disabled';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later';
        break;
      case 'weak-password':
        message = 'The password provided is too weak';
        break;
      case 'email-already-in-use':
        message = 'An account already exists for this email';
        break;
      default:
        message = e.message ?? 'An error occurred';
    }
    _showErrorSnackbar(message);
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential.user != null) {
        debugPrint(
            'AuthController: Google sign in successful - user: ${userCredential.user?.uid}');
        Get.offAllNamed(Routes.home);
      } else {
        throw 'Google sign in failed - no user returned';
      }
    } catch (e) {
      debugPrint('AuthController: Google sign in failed: $e');
      _showErrorSnackbar('Failed to sign in with Google');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithApple();

      if (userCredential.user != null) {
        debugPrint(
            'AuthController: Apple sign in successful - user: ${userCredential.user?.uid}');
        Get.offAllNamed(Routes.home);
      } else {
        throw 'Apple sign in failed - no user returned';
      }
    } catch (e) {
      debugPrint('AuthController: Apple sign in failed: $e');
      _showErrorSnackbar('Failed to sign in with Apple');
    } finally {
      isLoading.value = false;
    }
  }
}
