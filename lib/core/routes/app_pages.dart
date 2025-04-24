import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/tasks/bindings/tasks_binding.dart';
import '../../features/tasks/views/tasks_view.dart';
import '../../features/tracking/bindings/tracking_binding.dart';
import '../../features/tracking/views/tracking_view.dart';
import '../../features/maintenance/bindings/maintenance_binding.dart';
import '../../features/maintenance/views/maintenance_view.dart';
import '../../features/fuel/bindings/fuel_binding.dart';
import '../../features/fuel/views/fuel_view.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/onboarding/views/onboarding_view.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../bindings/auth_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      bindings: [
        AuthBinding(),
        HomeBinding(),
        TasksBinding(),
        TrackingBinding(),
        MaintenanceBinding(),
        FuelBinding(),
        NotificationsBinding(),
        SettingsBinding(),
      ],
    ),
    GetPage(
      name: Routes.tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: Routes.tracking,
      page: () => const TrackingView(),
      binding: TrackingBinding(),
    ),
    GetPage(
      name: Routes.maintenance,
      page: () => const MaintenanceView(),
      binding: MaintenanceBinding(),
    ),
    GetPage(
      name: Routes.fuel,
      page: () => const FuelView(),
      binding: FuelBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      bindings: [
        AuthBinding(),
        ProfileBinding(),
      ],
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.settingsEmailPreferences,
      page: () => Scaffold(
        appBar: AppBar(title: const Text('Email Preferences')),
        body: const Center(child: Text('Email Preferences Settings')),
      ),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.settingsTerms,
      page: () => Scaffold(
        appBar: AppBar(title: const Text('Terms of Service')),
        body: const Center(child: Text('Terms of Service Content')),
      ),
    ),
    GetPage(
      name: Routes.settingsPrivacy,
      page: () => Scaffold(
        appBar: AppBar(title: const Text('Privacy Policy')),
        body: const Center(child: Text('Privacy Policy Content')),
      ),
    ),
  ];
}
