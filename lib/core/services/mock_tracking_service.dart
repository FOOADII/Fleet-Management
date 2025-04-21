import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'mock_firestore_service.dart';

class MockTrackingService {
  final MockFirestoreService _firestore;
  final Map<String, StreamController<Position>> _locationStreams;

  MockTrackingService({
    MockFirestoreService? firestore,
  })  : _firestore = firestore ?? MockFirestoreService(),
        _locationStreams = {};

  Future<void> updateLocation(String vehicleId, Position position) async {
    final data = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
      'speed': position.speed,
      'heading': position.heading,
      'accuracy': position.accuracy,
    };

    await _firestore.collection('vehicles').doc(vehicleId).update(data);
  }

  Stream<Position> getLocationStream(String vehicleId) {
    if (!_locationStreams.containsKey(vehicleId)) {
      _locationStreams[vehicleId] = StreamController<Position>();
    }

    return _locationStreams[vehicleId]!.stream;
  }

  void dispose() {
    for (final controller in _locationStreams.values) {
      controller.close();
    }
    _locationStreams.clear();
  }
}
