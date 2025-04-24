import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/fuel_tracking_service.dart';
import 'fuel_tracking_form.dart';
import 'package:intl/intl.dart';

class FuelTrackingView extends StatefulWidget {
  const FuelTrackingView({super.key});

  @override
  State<FuelTrackingView> createState() => _FuelTrackingViewState();
}

class _FuelTrackingViewState extends State<FuelTrackingView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showAddFuelRecordForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FuelTrackingForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final fuelService = Get.find<FuelTrackingService>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Fuel Tracking',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: () => fuelService.loadFuelRecords(),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'fuel_tracking_fab',
          onPressed: () => _showAddFuelRecordForm(),
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (fuelService.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fuelService.fuelRecords.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station_outlined,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Fuel Records',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add your first fuel record by\ntapping the + button below',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fuelService.fuelRecords.length,
          itemBuilder: (context, index) {
            final record = fuelService.fuelRecords[index];
            return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_gas_station,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Fuel Record Details',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: theme.dividerColor, height: 24),
                        _DetailItem(
                          icon: Icons.directions_car,
                          label: 'Vehicle',
                          value: record.vehicleId,
                        ),
                        _DetailItem(
                          icon: Icons.speed,
                          label: 'Odometer',
                          value: '${record.odometerReading} km',
                        ),
                        _DetailItem(
                          icon: Icons.water_drop,
                          label: 'Fuel Amount',
                          value: '${record.fuelAmount} L',
                        ),
                        _DetailItem(
                          icon: Icons.gas_meter,
                          label: 'Fuel Gauge',
                          value: '${record.fuelGauge}%',
                        ),
                        if (record.notes?.isNotEmpty ?? false)
                          _DetailItem(
                            icon: Icons.note,
                            label: 'Notes',
                            value: record.notes!,
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d, y HH:mm')
                                  .format(record.timestamp),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_gas_station,
                                  color: Color(0xFF4CAF50),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.vehicleId,
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM d, y HH:mm')
                                          .format(record.timestamp),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(record.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  record.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(record.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _InfoChip(
                                icon: Icons.speed,
                                label: '${record.odometerReading} km',
                              ),
                              _InfoChip(
                                icon: Icons.water_drop,
                                label: '${record.fuelAmount} L',
                              ),
                              _InfoChip(
                                icon: Icons.gas_meter,
                                label: '${record.fuelGauge}%',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Tap to view details',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
