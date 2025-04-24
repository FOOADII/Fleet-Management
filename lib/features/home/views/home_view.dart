import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../tasks/views/tasks_view.dart';
import '../../tracking/views/tracking_view.dart';
import '../../maintenance/views/maintenance_view.dart';
import '../../fuel/views/fuel_tracking_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsController = Get.find<NotificationsController>();
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // User Profile Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                controller.userDisplayName[0].toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: theme.colorScheme.primary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.userDisplayName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    controller.userEmail ?? '',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        // Menu Items
                        _ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'profile'.tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed('/profile');
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'settings'.tr,
                          onTap: () {
                            Get.back();
                            Get.toNamed('/settings');
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'notifications'.tr,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(() => Text(
                                  '${notificationsController.unreadCount}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                                )),
                          ),
                          onTap: () {
                            Get.back();
                            Get.toNamed('/notifications');
                          },
                        ),
                        const Divider(),
                        _ProfileMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          onTap: () {
                            Get.back();
                            // TODO: Implement help & support
                            Get.snackbar(
                              'Coming Soon',
                              'Help & Support will be available soon',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          textColor: Colors.red,
                          onTap: () {
                            Get.back();
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                    'Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      controller.handleSignOut();
                                    },
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Obx(() => CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          controller.userDisplayName[0].toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodySmall,
                      ),
                      Obx(() => Text(
                            controller.userDisplayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            const ThemeToggleButton(),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_rounded,
                      color: theme.iconTheme.color),
                  onPressed: () => Get.toNamed('/notifications'),
                ),
                Obx(() {
                  final unreadCount = notificationsController.unreadCount.value;
                  if (unreadCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            _HomeContent(),
            TasksView(),
            TrackingView(),
            MaintenanceView(),
            FuelTrackingView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              height: 60,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              iconTheme: MaterialStateProperty.resolveWith((states) {
                return const IconThemeData(size: 22);
              }),
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (Set<MaterialState> states) {
                  return TextStyle(
                    fontSize: 11,
                    height: 1.0,
                  );
                },
              ),
            ),
          ),
          child: NavigationBar(
            elevation: 0,
            height: 60,
            backgroundColor: theme.cardColor,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
            selectedIndex: controller.currentIndex.value,
            onDestinationSelected: controller.changePage,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined,
                    size: 22, color: theme.iconTheme.color),
                selectedIcon: Icon(Icons.home_rounded,
                    size: 22, color: theme.iconTheme.color),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined,
                    size: 22, color: theme.iconTheme.color),
                selectedIcon: Icon(Icons.assignment_rounded,
                    size: 22, color: theme.iconTheme.color),
                label: 'Tasks',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined,
                    size: 22, color: theme.iconTheme.color),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.location_on_rounded,
                      size: 24, color: theme.iconTheme.color),
                ),
                label: 'Tracking',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_outlined,
                    size: 22, color: theme.iconTheme.color),
                selectedIcon: Icon(Icons.build_rounded,
                    size: 22, color: theme.iconTheme.color),
                label: 'Maintenance',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_gas_station_outlined,
                    size: 22, color: theme.iconTheme.color),
                selectedIcon: Icon(Icons.local_gas_station_rounded,
                    size: 22, color: theme.iconTheme.color),
                label: 'Fuel',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends GetView<HomeController> {
  const _HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth > 600 ? 24.0 : 16.0;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadQuickStats();
        await controller.loadRecentActivities();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fleet Overview Card
            Padding(
              padding: EdgeInsets.all(padding),
              child: _FleetOverviewCard(),
            ),

            // Quick Access Boxes
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => _QuickAccessBox(
                          title: 'vehicle_status'.tr,
                          value:
                              '${controller.quickStats['activeVehicles']}/20',
                          subtitle: 'active_vehicles'.tr,
                          icon: Icons.local_shipping_rounded,
                          color: Colors.blue,
                          onTap: () => Get.toNamed('/vehicles'),
                        )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _QuickAccessBox(
                          title: 'todays_tasks'.tr,
                          value: '${controller.quickStats['pendingTasks']}',
                          subtitle: 'pending_tasks'.tr,
                          icon: Icons.assignment_rounded,
                          color: Colors.orange,
                          onTap: () =>
                              controller.changePage(1), // Navigate to Tasks tab
                        )),
                  ),
                ],
              ),
            ),

            // Additional Quick Access Boxes
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => _QuickAccessBox(
                          title: 'fuel_alerts'.tr,
                          value: '${controller.quickStats['fuelAlerts']}',
                          subtitle: 'low_fuel'.tr,
                          icon: Icons.local_gas_station_rounded,
                          color: Colors.red,
                          onTap: () =>
                              controller.changePage(4), // Navigate to Fuel tab
                        )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _QuickAccessBox(
                          title: 'maintenance_due'.tr,
                          value: '${controller.quickStats['maintenanceDue']}',
                          subtitle: 'vehicles_due'.tr,
                          icon: Icons.build_rounded,
                          color: Colors.purple,
                          onTap: () => controller
                              .changePage(3), // Navigate to Maintenance tab
                        )),
                  ),
                ],
              ),
            ),

            // Recent Activity
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'recent_activity'.tr,
                        style: theme.textTheme.headlineSmall,
                      ),
                      TextButton.icon(
                        onPressed: () => Get.toNamed('/activity'),
                        icon: Icon(Icons.history_rounded,
                            color: theme.colorScheme.primary),
                        label: Text(
                          'view_all'.tr,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.recentActivities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final activity = controller.recentActivities[index];
                          return _ActivityCard(
                            title: activity['title'],
                            description: activity['description'],
                            time: activity['time'],
                            type: activity['type'],
                            onTap: () => _navigateBasedOnActivity(activity),
                          );
                        },
                      )),
                ],
              ),
            ),
            SizedBox(height: padding),
          ],
        ),
      ),
    );
  }

  void _navigateBasedOnActivity(Map<String, dynamic> activity) {
    // Navigate based on activity type and content
    switch (activity['type']) {
      case 'task':
        // Navigate to Tasks tab
        controller.changePage(1);
        break;
      case 'maintenance':
        // Navigate to Maintenance tab
        controller.changePage(3);
        break;
      case 'fuel':
        // Navigate to Fuel tab
        controller.changePage(4);
        break;
      case 'tracking':
        // Navigate to Tracking tab
        controller.changePage(2);
        break;
      default:
        // Fallback to showing a snackbar with activity info
        Get.snackbar(
          activity['title'],
          activity['description'],
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }
}

class _QuickAccessBox extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessBox({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: theme.iconTheme.color?.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetOverviewCard extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'fleet_overview'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.loadQuickStats();
                    Get.snackbar(
                      'refreshed'.tr,
                      'fleet_updated'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.7),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'refresh'.tr,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: isWide
                      ? WrapAlignment.spaceAround
                      : WrapAlignment.spaceBetween,
                  children: [
                    _buildFleetStatButton(
                        context,
                        Icons.local_shipping_rounded,
                        '15',
                        'total_vehicles'.tr,
                        () => Get.toNamed('/vehicles')),
                    _buildFleetStatButton(
                        context,
                        Icons.check_circle_rounded,
                        '8',
                        'active'.tr,
                        () => Get.toNamed('/vehicles?filter=active')),
                    _buildFleetStatButton(context, Icons.build_rounded, '3',
                        'in_maintenance'.tr, () => controller.changePage(3)),
                    _buildFleetStatButton(context, Icons.warning_rounded, '4',
                        'alerts'.tr, () => Get.toNamed('/alerts')),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetStatButton(BuildContext context, IconData icon,
      String value, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Get.textTheme.labelSmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime time;
  final String type;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.onTap,
  });

  Color _getActivityColor(String type) {
    switch (type) {
      case 'task':
        return const Color.fromARGB(255, 29, 206, 76);
      case 'maintenance':
        return Colors.orange;
      case 'fuel':
        return Colors.green;
      case 'tracking':
        return const Color.fromARGB(255, 32, 185, 121);
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      case 'fuel':
        return Icons.local_gas_station_outlined;
      case 'tracking':
        return Icons.location_on_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _getActionText(String type) {
    switch (type) {
      case 'task':
        return 'View Task Details';
      case 'maintenance':
        return 'Go to Maintenance';
      case 'fuel':
        return 'Check Fuel Status';
      case 'tracking':
        return 'View Location';
      default:
        return 'View Details';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionText = _getActionText(type);
    final color = _getActivityColor(type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getActivityIcon(type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDateTime(time),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type.capitalizeFirst!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: textColor ?? theme.iconTheme.color),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: theme.iconTheme.color?.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
