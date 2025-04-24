import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/tracking_controller.dart';
import '../../../core/theme/colors.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Tracking'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.iconTheme.color),
            onPressed: () => controller.refreshLocations(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Initializing location...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            _buildMap(),
            _buildControls(theme),
            _buildActiveDriversPanel(theme),
          ],
        );
      }),
      floatingActionButton: Obx(() => _buildTrackingFab(theme)),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: controller.currentLocation.value,
        zoom: 15,
      ),
      markers: controller.markers.values.toSet(),
      onMapCreated: (GoogleMapController mapController) {
        controller.onMapCreated(mapController);
      },
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      compassEnabled: true,
      trafficEnabled: true,
      buildingsEnabled: true,
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Zoom buttons
          Card(
            elevation: 4,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: theme.iconTheme.color),
                  onPressed: () {
                    controller.mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                ),
                Divider(height: 1, color: theme.dividerColor),
                IconButton(
                  icon: Icon(Icons.remove, color: theme.iconTheme.color),
                  onPressed: () {
                    controller.mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Map type toggle
          Card(
            elevation: 4,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.layers, color: theme.iconTheme.color),
              onPressed: () {
                // TODO: Implement map type toggle
              },
            ),
          ),
          const SizedBox(height: 8),
          // My location button
          Card(
            elevation: 4,
            color: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.my_location, color: theme.iconTheme.color),
              onPressed: () {
                controller.focusOnLocation(controller.currentLocation.value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDriversPanel(ThemeData theme) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.1,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Drivers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${controller.activeDrivers.length} Online',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              // Driver list
              Expanded(
                child: Obx(() {
                  if (controller.activeDrivers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 48,
                              color:
                                  theme.colorScheme.secondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No drivers online',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drivers will appear here when they are active on the road',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.activeDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = controller.activeDrivers[index];
                      final isSelected =
                          controller.selectedDriverId.value == driver['id'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        elevation: isSelected ? 2 : 0,
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.person,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          title: Text(
                            driver['name'] ?? 'Unknown Driver',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(driver['vehicleName'] ?? 'No vehicle'),
                          trailing: IconButton(
                            icon: Icon(
                              isSelected
                                  ? Icons.location_on
                                  : Icons.location_searching,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              controller.trackDriver(driver['id']);
                            },
                          ),
                          onTap: () {
                            controller.trackDriver(driver['id']);
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackingFab(ThemeData theme) {
    return FloatingActionButton.extended(
      heroTag: 'tracking_fab',
      onPressed: () {
        if (controller.isTracking.value) {
          controller.stopTracking();
        } else {
          controller.startTracking();
        }
      },
      backgroundColor:
          controller.isTracking.value ? Colors.red : theme.colorScheme.primary,
      label: Text(
        controller.isTracking.value ? 'Stop Tracking' : 'Start Tracking',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      icon: Icon(
        controller.isTracking.value ? Icons.location_off : Icons.location_on,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}

enum VehicleStatus { active, idle, maintenance, offline }

class Vehicle {
  final String id;
  final String name;
  final String plateNumber;
  final LatLng location;
  final VehicleStatus status;
  final String driver;
  final double speed;
  final double heading;

  Vehicle({
    required this.id,
    required this.name,
    required this.plateNumber,
    required this.location,
    required this.status,
    required this.driver,
    required this.speed,
    required this.heading,
  });
}
