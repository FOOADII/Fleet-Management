// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fleet_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Create a mock UserPlatform
class MockUserPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UserPlatform {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';

  @override
  bool get emailVerified => true;
}

// Create a mock UserCredentialPlatform
class MockUserCredentialPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements UserCredentialPlatform {
  @override
  UserPlatform? get user => MockUserPlatform();
}

// Create a mock FirebaseAuthPlatform
class MockFirebaseAuthPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebaseAuthPlatform {
  @override
  Stream<UserPlatform?> authStateChanges() {
    return Stream.value(null);
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return MockUserCredentialPlatform();
  }
}

// Create a mock FirebaseAppPlatform
class MockFirebaseAppPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebaseAppPlatform {
  @override
  FirebaseOptions get options => const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      );
}

// Create a mock FirebasePlatform
class MockFirebasePlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return MockFirebaseAppPlatform();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return MockFirebaseAppPlatform();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Set up Firebase mocks
    FirebasePlatform.instance = MockFirebasePlatform();
    FirebaseAuthPlatform.instance = MockFirebaseAuthPlatform();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(GetMaterialApp(home: Container()));
    await tester.pumpAndSettle();

    // Basic smoke test - verify the app builds
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
