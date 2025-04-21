import 'mock_firestore_service.dart';

class Expense {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? receiptUrl;
  final String status;

  Expense({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.receiptUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'status': status,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      receiptUrl: map['receiptUrl'] as String?,
      status: map['status'] as String,
    );
  }
}

class MockExpensesService {
  final MockFirestoreService _firestore;

  MockExpensesService({
    MockFirestoreService? firestore,
  }) : _firestore = firestore ?? MockFirestoreService();

  Future<List<Expense>> getExpenses() async {
    final snapshot = await _firestore.collection('expenses').get();
    return snapshot.documents.map((doc) {
      final data = doc.data;
      data['id'] = doc.id;
      return Expense.fromMap(data);
    }).toList();
  }

  Future<Expense> createExpense(
    String vehicleId,
    String title,
    String description,
    double amount,
    String category, {
    String? receiptUrl,
  }) async {
    final data = {
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': DateTime.now().toIso8601String(),
      'receiptUrl': receiptUrl,
      'status': 'pending',
    };

    final docRef = await _firestore.collection('expenses').add(data);
    final doc = await docRef.get();
    final docData = doc.data;
    docData['id'] = doc.id;
    return Expense.fromMap(docData);
  }

  Future<void> updateExpense(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('expenses').doc(id).update(data);
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }
}
