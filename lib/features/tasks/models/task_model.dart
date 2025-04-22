class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? assignedTo;
  final String? vehicleId;
  final String priority;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.assignedTo,
    this.vehicleId,
    required this.priority,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'vehicleId': vehicleId,
      'priority': priority,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      assignedTo: map['assignedTo'] as String?,
      vehicleId: map['vehicleId'] as String?,
      priority: map['priority'] as String,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? dueDate,
    String? assignedTo,
    String? vehicleId,
    String? priority,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      assignedTo: assignedTo ?? this.assignedTo,
      vehicleId: vehicleId ?? this.vehicleId,
      priority: priority ?? this.priority,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
