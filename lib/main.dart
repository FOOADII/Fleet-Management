import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/translations/app_translations.dart';
import 'core/bindings/initial_binding.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initServices();
    debugPrint("Services initialized successfully");

    // Load saved theme preference
    final prefs = Get.find<SharedPreferences>();
    final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final language = prefs.getString('language') ?? 'en';

    runApp(
      GetMaterialApp(
        title: 'Fleet Management',
        translations: AppTranslations(),
        locale: Locale(language),
        fallbackLocale: const Locale('en'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  } catch (e) {
    debugPrint("Error during initialization: $e");
    // Fallback to default theme if there's an error
    runApp(
      GetMaterialApp(
        title: 'Fleet Management',
        translations: AppTranslations(),
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Initialize all services and dependencies
Future<void> initServices() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize Firebase Storage
    FirebaseStorage.instance;
    debugPrint('Firebase Storage initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Google Maps
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  // Directly initialize SharedPreferences first
  try {
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    debugPrint('SharedPreferences initialized successfully');
  } catch (e) {
    debugPrint('SharedPreferences initialization error: $e');
    throw Exception('Failed to initialize SharedPreferences: $e');
  }

  // Initialize all dependencies through initial binding
  final binding = InitialBinding();
  await binding.dependencies();

  debugPrint('All services initialized');
}
