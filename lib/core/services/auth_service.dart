import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

abstract class AuthService {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  String? get organizationId;
  Rx<bool> get isDriver;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail();
  Future<void> updatePassword(String password);
  Future<void> updateEmail(String email);
  Future<void> deleteAccount();
  Future<void> sendEmailVerification();
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInWithApple();
  Future<bool> checkIfUserIsDriver();
}
