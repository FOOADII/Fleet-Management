import 'package:get/get.dart';
import '../features/tasks/views/tasks_view.dart';
import '../features/tasks/bindings/tasks_binding.dart';
import '../features/notifications/bindings/notifications_binding.dart';
import '../features/notifications/views/notifications_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String vehicles = '/vehicles';
  static const String dashboard = '/dashboard';

  static final routes = [
    GetPage(
      name: home,
      page: () => const TasksView(), // Temporarily using TasksView as home
      binding: TasksBinding(),
    ),
    GetPage(
      name: tasks,
      page: () => const TasksView(),
      binding: TasksBinding(),
    ),
    GetPage(
      name: '/notifications',
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
  ];
}
