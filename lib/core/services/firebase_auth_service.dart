import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'auth_service.dart';

class FirebaseAuthService extends GetxService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GoogleSignIn _googleSignIn;
  final _firebaseUser = Rx<User?>(null);
  final _organizationId = RxString(
    'ddu-fleet',
  ); // Organization ID for DDU Fleet Management
  final _isDriver = RxBool(false);

  User? get currentUser => _firebaseUser.value;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoggedIn => _firebaseUser.value != null;
  String? get organizationId => _organizationId.value;
  Rx<bool> get isDriver => _isDriver;

  @override
  void onInit() {
    super.onInit();
    debugPrint('FirebaseAuthService onInit called');
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('Firebase apps not initialized');
        throw Exception('Firebase not initialized');
      }

      _firebaseUser.bindStream(_auth.authStateChanges());

      // Check if user is a driver whenever auth state changes
      ever(_firebaseUser, (user) {
        if (user != null) {
          checkIfUserIsDriver();
        } else {
          _isDriver.value = false;
        }
      });

      // Initialize Google Sign In based on platform
      _googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? '361140798002-2jeat516aknjjtke8rd37djlimod4mtv.apps.googleusercontent.com'
            : null,
        scopes: ['email', 'profile'],
      );

      debugPrint('FirebaseAuthService initialized successfully');
      debugPrint('Current Firebase user: ${_auth.currentUser?.uid}');
      debugPrint('Firebase app name: ${_auth.app.name}');
      debugPrint('Firebase app options: ${_auth.app.options.apiKey}');
    } catch (e, stackTrace) {
      debugPrint('Error initializing FirebaseAuthService: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to initialize authentication service. Please restart the app.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<bool> checkIfUserIsDriver() async {
    try {
      if (_firebaseUser.value == null) {
        _isDriver.value = false;
        return false;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(_firebaseUser.value!.uid)
          .get();

      if (!userDoc.exists) {
        _isDriver.value = false;
        return false;
      }

      final userData = userDoc.data();
      if (userData == null) {
        _isDriver.value = false;
        return false;
      }

      // Check if user has driver role
      final role = userData['role'] as String?;
      final isUserDriver = role == 'driver';

      _isDriver.value = isUserDriver;
      return isUserDriver;
    } catch (e) {
      debugPrint('Error checking if user is driver: $e');
      _isDriver.value = false;
      return false;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint(
        'FirebaseAuthService: Attempting to sign in with email: $email',
      );
      debugPrint(
        'FirebaseAuthService: Firebase instance initialized: ${_auth.app.name}',
      );
      debugPrint(
        'FirebaseAuthService: Firebase instance state: ${_auth.app.isAutomaticDataCollectionEnabled}',
      );
      debugPrint(
        'FirebaseAuthService: Current user before sign in: ${_auth.currentUser?.uid}',
      );

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser.value = userCredential.user;
      debugPrint(
        'FirebaseAuthService: Successfully signed in user: ${userCredential.user?.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthService: FirebaseAuthException during sign in:');
      debugPrint('Error code: ${e.code}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Error details: ${e.stackTrace}');
      debugPrint('Error raw: $e');

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      throw e.message ?? 'Sign in failed';
    } catch (e, stackTrace) {
      debugPrint('FirebaseAuthService: Unexpected error during sign in:');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint(
        'Firebase instance state: ${_auth.app.isAutomaticDataCollectionEnabled}',
      );
      debugPrint('Current user state: ${_auth.currentUser?.uid}');

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      throw 'Sign in failed';
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('Attempting to sign in with Google');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Google sign in was cancelled by user';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google Auth credential
      final userCredential = await _auth.signInWithCredential(credential);

      debugPrint(
          'Successfully signed in with Google: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('Google sign in failed: $e');
      Get.snackbar(
        'Error',
        'Failed to sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      throw 'Google sign in failed: $e';
    }
  }

  Future<UserCredential> signInWithApple() async {
    try {
      debugPrint('Attempting to sign in with Apple');

      // Create an Apple provider
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      UserCredential userCredential;
      if (kIsWeb) {
        // Sign in for Web
        userCredential = await _auth.signInWithPopup(appleProvider);
      } else {
        // Sign in for native platforms
        userCredential = await _auth.signInWithProvider(appleProvider);
      }

      debugPrint(
          'Successfully signed in with Apple: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('Apple sign in failed: $e');
      Get.snackbar(
        'Error',
        'Failed to sign in with Apple. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      throw 'Apple sign in failed: $e';
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint(
        'FirebaseAuthService: Attempting to create user with email: $email',
      );
      debugPrint(
        'FirebaseAuthService: Firebase instance initialized: ${_auth.app.name}',
      );

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser.value = userCredential.user;
      debugPrint(
        'FirebaseAuthService: Successfully created user: ${userCredential.user?.uid}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthService: FirebaseAuthException during user creation:',
      );
      debugPrint('Error code: ${e.code}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Error details: ${e.stackTrace}');

      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      throw e.message ?? 'User creation failed';
    } catch (e) {
      debugPrint('FirebaseAuthService: Unexpected error during user creation:');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      throw 'User creation failed';
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('FirebaseAuthService: Attempting to sign out');
      await _googleSignIn.signOut();
      await _auth.signOut();
      _firebaseUser.value = null;
      debugPrint('FirebaseAuthService: Successfully signed out');
    } catch (e) {
      debugPrint('FirebaseAuthService: Error during sign out: $e');
      Get.snackbar(
        'Error',
        'Error signing out. Try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint(
        'FirebaseAuthService: Attempting to send password reset email to: $email',
      );
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('FirebaseAuthService: Successfully sent password reset email');
      Get.snackbar(
        'Success',
        'Password reset email sent. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'FirebaseAuthService: FirebaseAuthException during password reset: ${e.code} - ${e.message}',
      );
      Get.snackbar(
        'Error',
        e.message ?? 'Could not send password reset email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } catch (e) {
      debugPrint(
        'FirebaseAuthService: Unexpected error during password reset: $e',
      );
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      print('Attempting to update password');
      await _auth.currentUser?.updatePassword(newPassword);
      print('Successfully updated password');
    } on FirebaseAuthException catch (e) {
      print('Password update failed: ${e.message}');
      throw e.message ?? 'Password update failed';
    }
  }

  Future<void> deleteAccount() async {
    try {
      print('Attempting to delete account');
      await _auth.currentUser?.delete();
      print('Successfully deleted account');
    } on FirebaseAuthException catch (e) {
      print('Account deletion failed: ${e.message}');
      throw e.message ?? 'Account deletion failed';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      print('Attempting to send email verification');
      await _auth.currentUser?.sendEmailVerification();
      print('Successfully sent email verification');
    } on FirebaseAuthException catch (e) {
      print('Failed to send email verification: ${e.message}');
      throw e.message ?? 'Failed to send email verification';
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      print('Attempting to update email');
      await _auth.currentUser?.updateEmail(email);
      print('Successfully updated email');
    } on FirebaseAuthException catch (e) {
      print('Email update failed: ${e.message}');
      throw e.message ?? 'Email update failed';
    }
  }

  Future<void> verifyEmail() async {
    try {
      print('Attempting to verify email');
      await _auth.currentUser?.reload();
      if (_auth.currentUser?.emailVerified ?? false) {
        print('Email is already verified');
      } else {
        print('Email is not verified');
        throw 'Email is not verified';
      }
    } on FirebaseAuthException catch (e) {
      print('Email verification failed: ${e.message}');
      throw e.message ?? 'Email verification failed';
    }
  }

  @override
  void onClose() {
    debugPrint('FirebaseAuthService onClose called');
    _firebaseUser.close();
    super.onClose();
  }
}
