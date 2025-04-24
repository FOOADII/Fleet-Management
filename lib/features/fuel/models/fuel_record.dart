import 'package:cloud_firestore/cloud_firestore.dart';

class FuelRecord {
  final String id;
  final String vehicleId;
  final double odometerReading;
  final double fuelGauge;
  final double fuelAmount;
  final String status;
  final DateTime timestamp;
  final String? notes;
  final String organizationId;
  final String createdBy;

  FuelRecord({
    required this.id,
    required this.vehicleId,
    required this.odometerReading,
    required this.fuelGauge,
    required this.fuelAmount,
    required this.status,
    required this.timestamp,
    this.notes,
    required this.organizationId,
    required this.createdBy,
  });

  factory FuelRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FuelRecord(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      odometerReading: (data['odometerReading'] ?? 0.0).toDouble(),
      fuelGauge: (data['fuelGauge'] ?? 0.0).toDouble(),
      fuelAmount: (data['fuelAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'],
      organizationId: data['organizationId'] ?? 'ddu-fleet',
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'odometerReading': odometerReading,
      'fuelGauge': fuelGauge,
      'fuelAmount': fuelAmount,
      'status': status,
      'timestamp': timestamp,
      'notes': notes,
      'organizationId': organizationId,
      'createdBy': createdBy,
    };
  }
}
