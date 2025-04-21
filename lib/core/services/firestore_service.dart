import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get a collection reference
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  // Get a document reference
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  // Add a document to a collection
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await _firestore.collection(collection).add(data);
  }

  // Update a document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  // Get a document
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String documentId,
  ) async {
    final doc = await _firestore.collection(collection).doc(documentId).get();
    return doc.data();
  }

  // Get documents from a collection
  Future<List<Map<String, dynamic>>> getDocuments(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderByField,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Stream documents from a collection
  Stream<List<Map<String, dynamic>>> streamDocuments(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderByField,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Add test data for tasks
  Future<void> addTestTasks() async {
    final tasksCollection = collection('tasks');

    // Check if tasks already exist
    final tasksSnapshot = await tasksCollection.get();
    if (tasksSnapshot.docs.isNotEmpty) {
      return; // Tasks already exist
    }

    // Add sample tasks
    final tasks = [
      {
        'title': 'Vehicle Maintenance',
        'description': 'Perform routine maintenance on vehicle #123',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'assignedTo': currentUserId,
        'vehicleId': 'vehicle123',
        'priority': 'high',
      },
      {
        'title': 'Fuel Refill',
        'description': 'Refill fuel for vehicle #456',
        'status': 'in_progress',
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 1)),
        ),
        'assignedTo': currentUserId,
        'vehicleId': 'vehicle456',
        'priority': 'medium',
      },
      {
        'title': 'Route Planning',
        'description': 'Plan the route for tomorrow\'s delivery',
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'assignedTo': currentUserId,
        'vehicleId': 'vehicle789',
        'priority': 'low',
      },
    ];

    for (final task in tasks) {
      await tasksCollection.add(task);
    }
  }
}
