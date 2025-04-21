import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRequest {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? assignedTo;
  final double? cost;

  MaintenanceRequest({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.assignedTo,
    this.cost,
  });

  factory MaintenanceRequest.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequest(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      scheduledDate: map['scheduledDate'] != null
          ? (map['scheduledDate'] as Timestamp).toDate()
          : null,
      assignedTo: map['assignedTo'] as String?,
      cost: (map['cost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledDate':
          scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'assignedTo': assignedTo,
      'cost': cost,
    };
  }
}
