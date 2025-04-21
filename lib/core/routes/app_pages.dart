import 'package:get/get.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/maintenance/bindings/maintenance_binding.dart';
import '../../features/maintenance/views/maintenance_view.dart';
import '../../features/tasks/views/tasks_view.dart';
import '../../features/tasks/bindings/tasks_binding.dart';
import '../../features/splash/views/splash_view.dart';
import '../../features/onboarding/onboarding_screen.dart';
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
      page: () => const OnboardingScreen(),
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
      ],
    ),
    GetPage(
      name: Routes.maintenance,
      page: () => const MaintenanceView(),
      binding: MaintenanceBinding(),
    ),
    GetPage(
      name: Routes.tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
    ),
  ];
}
