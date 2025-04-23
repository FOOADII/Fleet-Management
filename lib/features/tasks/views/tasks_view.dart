import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_model.dart';
import '../../../routes/app_routes.dart'; // Import AppRoutes
import '../../../core/routes/app_pages.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({Key? key}) : super(key: key);

  // Helper to determine if we should show our own AppBar
  // We want to show it when in the standalone Tasks route, but not when in Home
  bool get _shouldShowAppBar => Get.currentRoute == Routes.tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Show AppBar only when navigated to directly (not from home navigation)
      appBar: _shouldShowAppBar
          ? AppBar(
              title: Text('tasks'.tr),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 1,
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'refresh_data'.tr,
                  onPressed: () => _refreshData(context),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'filter_tasks'.tr,
                  onPressed: () => _showFilterDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.add_task),
                  tooltip: 'add_new_task'.tr,
                  onPressed: () => _showAddTaskDialog(context),
                ),
              ],
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppBar(
                title: Text('tasks'.tr),
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                elevation: 1,
                automaticallyImplyLeading: false,
              ),
            ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt_outlined,
                    size: 80,
                    color: colorScheme.secondary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'no_tasks'.tr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get started by adding a new task using the button below.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTaskDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your First Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: theme.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTasks,
          color: colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return _TaskCard(
                task: task,
                onStatusChange: (status) =>
                    controller.updateTaskStatus(task.id, status),
                onDelete: () => controller.deleteTask(task.id),
                onViewDetails: () => _showTaskDetailsDialog(context, task),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: Text('add_task'.tr),
      ),
    );
  }

  // --- Dialogs and Helper Methods (Updated Styling) ---

  void _refreshData(BuildContext context) async {
    final loadingOverlay = _showLoadingOverlay(context);
    try {
      await controller.loadTasks();
      Get.snackbar(
        'success'.tr,
        'task_refreshed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'refresh_failed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Theme.of(context).colorScheme.error,
        colorText: Theme.of(context).colorScheme.onError,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    } finally {
      loadingOverlay.remove();
    }
  }

  OverlayEntry _showLoadingOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final overlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary)),
                  const SizedBox(height: 20),
                  Text(
                    'Refreshing Data...',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fetching latest driver and task updates',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlay);
    return overlay;
  }

  void _showTaskDetailsDialog(BuildContext context, TaskModel task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding:
            const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
        title: Text(task.title, style: theme.textTheme.headlineSmall),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(task.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              _buildDetailRow(
                  theme,
                  Icons.priority_high,
                  'priority'.tr,
                  task.priority?.capitalizeFirst ?? '',
                  _getPriorityColor(task.priority)),
              _buildDetailRow(
                  theme,
                  _getStatusIcon(task.status),
                  'status'.tr,
                  task.status?.capitalizeFirst ?? '',
                  _getStatusColor(task.status)),
              if (task.assignedTo != null)
                _buildDetailRow(theme, Icons.person_outline, 'assigned_to'.tr,
                    task.assignedTo!, colorScheme.onSurfaceVariant),
              if (task.vehicleId != null)
                _buildDetailRow(
                    theme,
                    Icons.directions_car_outlined,
                    'vehicle'.tr,
                    task.vehicleId!,
                    colorScheme.onSurfaceVariant),
              if (task.dueDate != null)
                _buildDetailRow(
                    theme,
                    Icons.calendar_today_outlined,
                    'due_date'.tr,
                    task.dueDate!.toString().split(' ')[0],
                    colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildTimestampRow(
                  theme, Icons.access_time, 'created'.tr, task.createdAt),
              if (task.updatedAt != null)
                _buildTimestampRow(
                    theme, Icons.update, 'updated'.tr, task.updatedAt!),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Change Status'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            onPressed: () {
              Navigator.pop(context); // Close details dialog first
              _showStatusChangeDialog(context, task.id, task.status);
            },
          ),
          TextButton(
            child: const Text('Close'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label,
      String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.bold))), // Make value bold
        ],
      ),
    );
  }

  Widget _buildTimestampRow(
      ThemeData theme, IconData icon, String label, DateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ${time.toString().split('.')[0]}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusColor(String status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade700;
      case 'overdue':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  void _showStatusChangeDialog(
      BuildContext context, String taskId, String currentStatus) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Task Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(
                context,
                theme,
                'Pending',
                'pending',
                currentStatus,
                Icons.hourglass_empty_outlined,
                Colors.orange,
                taskId),
            _buildStatusOption(
                context,
                theme,
                'Completed',
                'completed',
                currentStatus,
                Icons.check_circle_outline,
                Colors.green,
                taskId),
            _buildStatusOption(context, theme, 'Overdue', 'overdue',
                currentStatus, Icons.warning_amber_rounded, Colors.red, taskId),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
      BuildContext context,
      ThemeData theme,
      String title,
      String statusValue,
      String currentStatus,
      IconData icon,
      Color color,
      String taskId) {
    final bool isSelected = currentStatus == statusValue;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        controller.updateTaskStatus(taskId, statusValue);
        Navigator.pop(context);
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Filter Tasks', style: theme.textTheme.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Status:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _FilterChip(
                    label: 'All',
                    onTap: () {
                      controller.loadTasks();
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Pending',
                    color: Colors.orange,
                    onTap: () async {
                      final tasks =
                          await controller.getTasksByStatus('pending');
                      controller.tasks.value = tasks;
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Completed',
                    color: Colors.green,
                    onTap: () async {
                      final tasks =
                          await controller.getTasksByStatus('completed');
                      controller.tasks.value = tasks;
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Overdue',
                    color: Colors.red,
                    onTap: () async {
                      final tasks =
                          await controller.getTasksByStatus('overdue');
                      controller.tasks.value = tasks;
                      Navigator.pop(context);
                    }),
              ],
            ),
            const SizedBox(height: 16),
            Text('By Priority:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _FilterChip(
                    label: 'High Priority',
                    color: Colors.red.shade700,
                    onTap: () {
                      final filtered = controller.tasks
                          .whereType<TaskModel>()
                          .where(
                              (task) => task.priority.toLowerCase() == 'high')
                          .toList();
                      controller.tasks.value = filtered;
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Medium Priority',
                    color: Colors.orange.shade700,
                    onTap: () {
                      final filtered = controller.tasks
                          .whereType<TaskModel>()
                          .where(
                              (task) => task.priority.toLowerCase() == 'medium')
                          .toList();
                      controller.tasks.value = filtered;
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Low Priority',
                    color: Colors.green.shade700,
                    onTap: () {
                      final filtered = controller.tasks
                          .whereType<TaskModel>()
                          .where((task) => task.priority.toLowerCase() == 'low')
                          .toList();
                      controller.tasks.value = filtered;
                      Navigator.pop(context);
                    }),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'medium';
    DateTime? selectedDate;
    String? assignedTo;
    String? vehicleId;
    final _formKey = GlobalKey<FormState>(); // Add form key

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New Task', style: theme.textTheme.headlineSmall),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title cannot be empty'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description cannot be empty'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                      labelText: 'Priority', border: OutlineInputBorder()),
                  items: ['low', 'medium', 'high']
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(priority.capitalizeFirst!),
                          ))
                      .toList(),
                  onChanged: (value) => selectedPriority = value!,
                  validator: (value) =>
                      value == null ? 'Please select a priority' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Assigned To (Optional)',
                      border: OutlineInputBorder()),
                  onChanged: (value) =>
                      assignedTo = value.trim().isEmpty ? null : value.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Vehicle ID (Optional)',
                      border: OutlineInputBorder()),
                  onChanged: (value) =>
                      vehicleId = value.trim().isEmpty ? null : value.trim(),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date (Optional)'),
                  subtitle: Text(selectedDate?.toString().split(' ')[0] ??
                      'Tap to select'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade400)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(
                          const Duration(days: 30)), // Allow past dates?
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    // This requires state management within the dialog or rebuilding it
                    // For simplicity, we'll just update the variable.
                    // A StatefulWidget or GetBuilder might be needed for live update in dialog.
                    if (date != null) {
                      selectedDate = date;
                      // Ideally, trigger a rebuild of the dialog content here
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_task), // Changed icon
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Validate form
                controller.createTask(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                  selectedPriority,
                  dueDate: selectedDate,
                  assignedTo: assignedTo,
                  vehicleId: vehicleId,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    Key? key,
    required this.label,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.secondary;
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: theme.textTheme.labelMedium
          ?.copyWith(color: chipColor, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: chipColor.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(String) onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  const _TaskCard({
    Key? key,
    required this.task,
    required this.onStatusChange,
    required this.onDelete,
    this.onViewDetails,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade700;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade700;
      case 'overdue':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty_outlined;
      case 'overdue':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);
    final statusIcon = _getStatusIcon(task.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures ink ripple stays within bounds
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(task.priority?.capitalizeFirst ?? ''),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: priorityColor, fontWeight: FontWeight.bold),
                    backgroundColor: priorityColor.withOpacity(0.15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(task.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              if (task.assignedTo != null || task.vehicleId != null)
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    if (task.assignedTo != null)
                      _buildInfoChip(theme, Icons.person_outline,
                          task.assignedTo!, colorScheme.secondary),
                    if (task.vehicleId != null)
                      _buildInfoChip(theme, Icons.directions_car_outlined,
                          task.vehicleId!, colorScheme.secondary),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _showStatusChangeDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Chip(
                      avatar: Icon(statusIcon, color: statusColor, size: 16),
                      label: Text(task.status?.capitalizeFirst ?? ''),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor, fontWeight: FontWeight.bold),
                      backgroundColor: statusColor.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      side: BorderSide(color: statusColor.withOpacity(0.3)),
                    ),
                  ),
                  if (task.dueDate != null)
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          task.dueDate!.toString().split(' ')[0],
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      ThemeData theme, IconData icon, String text, Color color) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(text),
      labelStyle: theme.textTheme.labelSmall?.copyWith(color: color),
      backgroundColor: color.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }

  void _showStatusChangeDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Task Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(
                context,
                theme,
                'Pending',
                'pending',
                task.status,
                Icons.hourglass_empty_outlined,
                Colors.orange,
                task.id),
            _buildStatusOption(context, theme, 'Completed', 'completed',
                task.status, Icons.check_circle_outline, Colors.green, task.id),
            _buildStatusOption(context, theme, 'Overdue', 'overdue',
                task.status, Icons.warning_amber_rounded, Colors.red, task.id),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
      BuildContext context,
      ThemeData theme,
      String title,
      String statusValue,
      String currentStatus,
      IconData icon,
      Color color,
      String taskId) {
    final bool isSelected = currentStatus == statusValue;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        onStatusChange(statusValue);
        Navigator.pop(context);
      },
    );
  }
}
