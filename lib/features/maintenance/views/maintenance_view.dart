import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../controllers/maintenance_controller.dart';
import '../models/maintenance_log_model.dart';
import '../../../core/routes/app_pages.dart'; // For Routes

class MaintenanceView extends GetView<MaintenanceController> {
  const MaintenanceView({Key? key}) : super(key: key);

  // Determine if the AppBar should be shown
  bool get _shouldShowAppBar => Get.currentRoute == Routes.maintenance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _shouldShowAppBar
          ? AppBar(
              title: const Text('Maintenance Records'),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 1,
              actions: [
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Refresh Data',
                  onPressed: () => _refreshData(context),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter Records',
                  onPressed: () => _showFilterDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  tooltip: 'Add New Log',
                  onPressed: () => _showAddLogDialog(context),
                ),
              ],
            )
          : null, // No AppBar if part of Home
      body: Obx(() {
        if (controller.isLoading.value && controller.maintenanceLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.maintenanceLogs.isEmpty) {
          return _buildEmptyState(context, theme, colorScheme);
        }

        return RefreshIndicator(
          onRefresh: controller.loadMaintenanceLogs,
          color: colorScheme.primary,
          child: Column(
            children: [
              if (!_shouldShowAppBar) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
                  child: Center(
                    child: Text(
                      'Maintenance Records',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: controller.maintenanceLogs.length,
                  itemBuilder: (context, index) {
                    final log = controller.maintenanceLogs[index];
                    return _MaintenanceLogCard(
                      log: log,
                      onDelete: () => _confirmDelete(context, log.id),
                      onViewDetails: () => _showLogDetailsDialog(context, log),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        heroTag: 'maintenance_fab',
        onPressed: () => _showAddLogDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        tooltip: 'Add Maintenance Log',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 80,
              color: colorScheme.secondary.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No Maintenance Records',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Keep track of vehicle maintenance by adding the first log entry.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddLogDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add First Log Entry'),
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

  void _confirmDelete(BuildContext context, String logId) {
    Get.defaultDialog(
      title: "Delete Log?",
      middleText:
          "Are you sure you want to delete this maintenance record? This action cannot be undone.",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Theme.of(context).colorScheme.error,
      cancelTextColor: Theme.of(context).colorScheme.secondary,
      onConfirm: () {
        controller.deleteMaintenanceLog(logId);
        Get.back(); // Close the dialog
      },
      onCancel: () {},
      radius: 16,
    );
  }

  void _refreshData(BuildContext context) async {
    final loadingOverlay =
        _showLoadingOverlay(context, 'Refreshing Records...');
    try {
      await controller.loadMaintenanceLogs();
      Get.snackbar(
        'Data Refreshed',
        'Successfully retrieved latest maintenance logs',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Refresh Failed',
        'Could not retrieve latest data: ${e.toString()}',
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

  OverlayEntry _showLoadingOverlay(BuildContext context, String message) {
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
                    message,
                    style: theme.textTheme.titleMedium,
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

  // --- Dialogs ---

  void _showLogDetailsDialog(BuildContext context, MaintenanceLog log) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final DateFormat dateFormat = DateFormat.yMMMd(); // Date formatter
    final NumberFormat currencyFormat =
        NumberFormat.currency(symbol: 'ETB '); // Currency formatter

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding:
            const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16),
        title: Text(log.maintenanceType, style: theme.textTheme.headlineSmall),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildDetailRow(theme, Icons.directions_car_outlined,
                  'Vehicle ID', log.vehicleId, colorScheme.secondary),
              const SizedBox(height: 8),
              Text(log.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              _buildDetailRow(
                  theme,
                  Icons.calendar_today,
                  'Date Performed',
                  dateFormat.format(log.datePerformed),
                  colorScheme.onSurfaceVariant),
              if (log.odometerReading != null)
                _buildDetailRow(theme, Icons.speed_outlined, 'Odometer',
                    '${log.odometerReading} km', colorScheme.onSurfaceVariant),
              if (log.cost != null && log.cost! > 0)
                _buildDetailRow(theme, Icons.attach_money, 'Cost',
                    currencyFormat.format(log.cost), Colors.green.shade700),
              _buildDetailRow(
                  theme,
                  _getStatusIcon(log.status),
                  'Status',
                  log.status.name.capitalizeFirst!,
                  _getStatusColor(log.status)),
              if (log.nextDueDate != null)
                _buildDetailRow(
                    theme,
                    Icons.event_repeat_outlined,
                    'Next Due',
                    dateFormat.format(log.nextDueDate!),
                    log.isOverdue ? Colors.red.shade600 : colorScheme.primary),
              if (log.notes != null && log.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes:',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(log.notes!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildTimestampRow(
                  theme, Icons.access_time, 'Logged', log.createdAt),
              if (log.updatedAt != null)
                _buildTimestampRow(
                    theme, Icons.update, 'Updated', log.updatedAt!),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            onPressed: () {
              Navigator.pop(context); // Close details dialog first
              _confirmDelete(context, log.id);
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

  void _showFilterDialog(BuildContext context) {
    final theme = Theme.of(context);
    String? _selectedVehicleId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Filter Records', style: theme.textTheme.headlineSmall),
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
                      controller.filterLogsByStatus(null);
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Scheduled',
                    color: Colors.blue,
                    onTap: () {
                      controller
                          .filterLogsByStatus(MaintenanceStatus.scheduled);
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Completed',
                    color: Colors.green,
                    onTap: () {
                      controller
                          .filterLogsByStatus(MaintenanceStatus.completed);
                      Navigator.pop(context);
                    }),
                _FilterChip(
                    label: 'Overdue',
                    color: Colors.red,
                    onTap: () {
                      controller.filterLogsByStatus(MaintenanceStatus.overdue);
                      Navigator.pop(context);
                    }),
              ],
            ),
            const SizedBox(height: 20),
            Text('By Vehicle ID:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Enter Vehicle ID',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_selectedVehicleId != null &&
                          _selectedVehicleId!.isNotEmpty) {
                        controller.filterLogsByVehicle(_selectedVehicleId);
                        Navigator.pop(context);
                      }
                    },
                  )),
              onChanged: (value) => _selectedVehicleId = value.trim(),
              onFieldSubmitted: (value) {
                // Allow submitting with Enter key
                if (value.isNotEmpty) {
                  controller.filterLogsByVehicle(value);
                  Navigator.pop(context);
                }
              },
            ),
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

  void _showAddLogDialog(BuildContext context) {
    final theme = Theme.of(context);
    final _formKey = GlobalKey<FormState>();
    final vehicleIdController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = TextEditingController();
    final odometerController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();
    DateTime datePerformed = DateTime.now();
    DateTime? nextDueDate;
    MaintenanceStatus selectedStatus = MaintenanceStatus.completed;

    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to update date pickers within the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text('Add Maintenance Log',
                  style: theme.textTheme.headlineSmall),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: vehicleIdController,
                        decoration: const InputDecoration(
                            labelText: 'Vehicle ID*',
                            border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Vehicle ID is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: typeController,
                        decoration: const InputDecoration(
                            labelText: 'Maintenance Type* (e.g., Oil Change)',
                            border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Maintenance type is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Description*',
                            border: OutlineInputBorder()),
                        maxLines: 2,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<MaintenanceStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                            labelText: 'Status*', border: OutlineInputBorder()),
                        items: MaintenanceStatus.values
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.name.capitalizeFirst!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStatus = value);
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Please select a status' : null,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade400)),
                        title: const Text('Date Performed*'),
                        subtitle:
                            Text(DateFormat.yMMMd().format(datePerformed)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: datePerformed,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 1)), // Allow today
                          );
                          if (pickedDate != null) {
                            setState(() => datePerformed = pickedDate);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: odometerController,
                        decoration: const InputDecoration(
                            labelText: 'Odometer Reading (km)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: costController,
                        decoration: const InputDecoration(
                            labelText: 'Cost (ETB)',
                            border: OutlineInputBorder()),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade400)),
                        title: const Text('Next Due Date (Optional)'),
                        subtitle: Text(nextDueDate == null
                            ? 'Tap to select'
                            : DateFormat.yMMMd().format(nextDueDate!)),
                        trailing: const Icon(Icons.event_repeat),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: nextDueDate ??
                                DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 5)),
                          );
                          if (pickedDate != null) {
                            setState(() => nextDueDate = pickedDate);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes (Optional)',
                            border: OutlineInputBorder()),
                        maxLines: 3,
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
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.addMaintenanceLog(
                        vehicleId: vehicleIdController.text.trim(),
                        description: descriptionController.text.trim(),
                        maintenanceType: typeController.text.trim(),
                        datePerformed: datePerformed,
                        odometerReading: int.tryParse(odometerController.text),
                        cost: double.tryParse(costController.text),
                        notes: notesController.text.trim(),
                        status: selectedStatus,
                        nextDueDate: nextDueDate,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Helpers for Dialogs & Cards ---

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label,
      String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18, color: theme.colorScheme.primary.withOpacity(0.8)),
          const SizedBox(width: 12),
          Text('$label: ',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w500))), // Value styling
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
          Text('$label: ${DateFormat.yMMMd().add_jm().format(time)}',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)), // Added time
        ],
      ),
    );
  }

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.completed:
        return Colors.green.shade600;
      case MaintenanceStatus.scheduled:
        return Colors.blue.shade600;
      case MaintenanceStatus.overdue:
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.completed:
        return Icons.check_circle_outline;
      case MaintenanceStatus.scheduled:
        return Icons.calendar_month_outlined;
      case MaintenanceStatus.overdue:
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }
}

// --- Reusable Widgets ---

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

class _MaintenanceLogCard extends StatelessWidget {
  final MaintenanceLog log;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  const _MaintenanceLogCard({
    Key? key,
    required this.log,
    required this.onDelete,
    this.onViewDetails,
  }) : super(key: key);

  Color _getStatusColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.completed:
        return Colors.green.shade600;
      case MaintenanceStatus.scheduled:
        return Colors.blue.shade600;
      case MaintenanceStatus.overdue:
        return log.isOverdue ? Colors.red.shade600 : Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    if (log.isOverdue && status == MaintenanceStatus.scheduled)
      return Icons.warning_amber_rounded;
    switch (status) {
      case MaintenanceStatus.completed:
        return Icons.check_circle_outline;
      case MaintenanceStatus.scheduled:
        return Icons.calendar_month_outlined;
      // Overdue case handled above
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(log.status);
    final statusIcon = _getStatusIcon(log.status);
    final DateFormat dateFormat = DateFormat.yMMMd(); // Date formatter

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.vehicleId, // Show Vehicle ID prominently
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          log.maintenanceType, // Type below Vehicle ID
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(statusIcon, color: statusColor, size: 16),
                    label: Text(log.status.name.capitalizeFirst! +
                        (log.isOverdue ? ' (Overdue)' : '')),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor, fontWeight: FontWeight.bold),
                    backgroundColor: statusColor.withOpacity(0.15),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    side: BorderSide(color: statusColor.withOpacity(0.3)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(log.description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Performed: ${dateFormat.format(log.datePerformed)}',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (log.cost != null && log.cost! > 0)
                    Text(
                      NumberFormat.currency(symbol: 'ETB ').format(log.cost),
                      style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              if (log.nextDueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.event_repeat_outlined,
                          size: 14,
                          color: log.isOverdue
                              ? Colors.red.shade600
                              : colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Next Due: ${dateFormat.format(log.nextDueDate!)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: log.isOverdue
                                ? Colors.red.shade600
                                : colorScheme.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
