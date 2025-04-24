import 'package:cloud_firestore/cloud_firestore.dart';

enum MaintenanceStatus { scheduled, completed, overdue }

class MaintenanceLog {
  final String id;
  final String vehicleId;
  final String description;
  final String maintenanceType;
  final DateTime datePerformed;
  final int? odometerReading;
  final double? cost;
  final String? notes;
  final MaintenanceStatus status; // Changed to enum
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime? updatedAt; // Added for tracking updates

  MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.description,
    required this.maintenanceType,
    required this.datePerformed,
    this.odometerReading,
    this.cost,
    this.notes,
    required this.status,
    this.nextDueDate,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id' is usually the document ID, not stored in the map itself
      'vehicleId': vehicleId,
      'description': description,
      'maintenanceType': maintenanceType,
      'datePerformed': Timestamp.fromDate(datePerformed), // Store as Timestamp
      'odometerReading': odometerReading,
      'cost': cost,
      'notes': notes,
      'status': status.name, // Store enum name as string
      'nextDueDate':
          nextDueDate != null ? Timestamp.fromDate(nextDueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt), // Store as Timestamp
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map, String documentId) {
    return MaintenanceLog(
      id: documentId, // Use the document ID passed from Firestore
      vehicleId: map['vehicleId'] as String? ?? 'N/A', // Handle potential null
      description: map['description'] as String? ?? '',
      maintenanceType: map['maintenanceType'] as String? ?? 'General',
      datePerformed: (map['datePerformed'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Handle Timestamp
      odometerReading: map['odometerReading'] as int?,
      cost: (map['cost'] as num?)?.toDouble(), // Handle num type for cost
      notes: map['notes'] as String?,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MaintenanceStatus.completed, // Default status
      ),
      nextDueDate:
          (map['nextDueDate'] as Timestamp?)?.toDate(), // Handle Timestamp
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Handle Timestamp
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(), // Handle Timestamp
    );
  }

  // Helper to determine if a scheduled task is overdue
  bool get isOverdue {
    if (status == MaintenanceStatus.scheduled && nextDueDate != null) {
      return DateTime.now().isAfter(nextDueDate!);
    }
    return false;
  }
}
