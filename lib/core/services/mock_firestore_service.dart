import 'dart:async';
import 'package:uuid/uuid.dart';

class MockDocumentSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  final bool exists;

  MockDocumentSnapshot({
    required this.id,
    required Map<String, dynamic> data,
    this.exists = true,
  }) : _data = data;

  Map<String, dynamic> get data => _data;
}

class MockQuerySnapshot {
  final List<MockDocumentSnapshot> docs;

  MockQuerySnapshot({required this.docs});

  List<MockDocumentSnapshot> get documents => docs;
}

class MockDocumentReference {
  final String path;
  final String id;
  final Map<String, dynamic> _data;

  MockDocumentReference({
    required this.path,
    required this.id,
    Map<String, dynamic>? data,
  }) : _data = data ?? {};

  Future<MockDocumentSnapshot> get() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDocumentSnapshot(
      id: id,
      data: _data,
    );
  }

  Future<void> update(Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _data.addAll(data);
  }

  Future<void> delete() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _data.clear();
  }
}

class MockCollectionReference {
  final String path;
  final Map<String, Map<String, dynamic>> _documents;

  MockCollectionReference({
    required this.path,
    Map<String, Map<String, dynamic>>? documents,
  }) : _documents = documents ?? {};

  MockDocumentReference doc([String? id]) {
    final docId = id ?? const Uuid().v4();
    return MockDocumentReference(
      path: '$path/$docId',
      id: docId,
      data: _documents[docId],
    );
  }

  Future<MockQuerySnapshot> get() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final docs = _documents.entries.map((entry) {
      return MockDocumentSnapshot(
        id: entry.key,
        data: entry.value,
      );
    }).toList();
    return MockQuerySnapshot(docs: docs);
  }

  Future<MockDocumentReference> add(Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final docId = const Uuid().v4();
    _documents[docId] = data;
    return doc(docId);
  }
}

class MockFirestoreService {
  final Map<String, Map<String, Map<String, dynamic>>> _collections;

  MockFirestoreService({
    Map<String, Map<String, Map<String, dynamic>>>? collections,
  }) : _collections = collections ?? {};

  MockCollectionReference collection(String path) {
    return MockCollectionReference(
      path: path,
      documents: _collections[path],
    );
  }

  // Helper method to add test data
  void addTestData(String collection, String docId, Map<String, dynamic> data) {
    if (!_collections.containsKey(collection)) {
      _collections[collection] = {};
    }
    _collections[collection]![docId] = data;
  }
}
