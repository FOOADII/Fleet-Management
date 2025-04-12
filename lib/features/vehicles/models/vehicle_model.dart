import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleStatus {
  active,
  maintenance,
  inactive,
  retired,
  available,
}

class Vehicle {
  final String id;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final String type;
  final String color;
  final int odometerReading;
  final VehicleStatus status;
  final String organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.color,
    required this.odometerReading,
    required this.status,
    required this.organizationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      type: map['type'] ?? '',
      color: map['color'] ?? '',
      odometerReading: map['odometerReading'] ?? 0,
      status: VehicleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => VehicleStatus.active,
      ),
      organizationId: map['organizationId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plateNumber': plateNumber,
      'make': make,
      'model': model,
      'year': year,
      'type': type,
      'color': color,
      'odometerReading': odometerReading,
      'status': status.toString().split('.').last,
      'organizationId': organizationId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
