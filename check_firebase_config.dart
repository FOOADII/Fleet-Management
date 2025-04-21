import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    print('Platform: ${Firebase.app().options.platform}');
    print('Project ID: ${Firebase.app().options.projectId}');
    print('App ID: ${Firebase.app().options.appId}');
    print('API Key: ${Firebase.app().options.apiKey}');

    // Check Firebase Auth
    final auth = FirebaseAuth.instance;
    print('Firebase Auth instance: ${auth.app.name}');
    print('Current user: ${auth.currentUser?.uid}');

    // Try to create a test user
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: 'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'TestPassword123!',
      );
      print('Test user created successfully: ${userCredential.user?.uid}');

      // Delete the test user
      await userCredential.user?.delete();
      print('Test user deleted successfully');
    } catch (e) {
      print('Error creating test user: $e');
    }

    print('Firebase configuration check completed');
  } catch (e) {
    print('Error checking Firebase configuration: $e');
  }
}
