import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createSampleData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user is currently signed in');
        Get.snackbar(
          'Error',
          'No user is signed in',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      print('Creating sample data for user: ${currentUser.uid}');

      // Create organization
      final organizationId = 'ddu-fleet';
      await _firestore.collection('organizations').doc(organizationId).set({
        'name': 'DDU Fleet Management',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Created organization: $organizationId');

      // Create vehicle
      final vehicleId = 'VEH001';
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('vehicles')
          .doc(vehicleId)
          .set({
        'id': vehicleId,
        'currentRoute': 'Route 1',
        'status': 'Available',
        'speed': 0.0,
        'fuelLevel': 85.0,
        'engineTemp': 45.0,
        'lastMaintenance': FieldValue.serverTimestamp(),
      });
      print('Created vehicle: $vehicleId');

      // Create today's schedule
      final today = DateTime.now().toIso8601String().split('T')[0];
      print('Creating schedules for date: $today');

      // Delete existing schedules for today (to avoid duplicates)
      final existingSchedules = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('schedules')
          .where('date', isEqualTo: today)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      for (var doc in existingSchedules.docs) {
        await doc.reference.delete();
      }

      // Morning schedule
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('schedules')
          .add({
        'date': today,
        'time': '08:00',
        'vehicleId': vehicleId,
        'type': 'Pickup',
        'location': 'Main Campus',
        'status': 'Upcoming',
        'passengers': 5,
        'notes': 'Student pickup for morning classes',
      });
      print('Created morning schedule');

      // Mid-morning schedule
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('schedules')
          .add({
        'date': today,
        'time': '10:30',
        'vehicleId': vehicleId,
        'type': 'Delivery',
        'location': 'Engineering Campus',
        'status': 'Upcoming',
        'passengers': 3,
        'notes': 'Faculty transport',
      });
      print('Created mid-morning schedule');

      // Afternoon schedule
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('schedules')
          .add({
        'date': today,
        'time': '13:00',
        'vehicleId': vehicleId,
        'type': 'Pickup',
        'location': 'Engineering Campus',
        'status': 'Upcoming',
        'passengers': 8,
        'notes': 'Student pickup for afternoon classes',
      });
      print('Created afternoon schedule');

      // Evening schedule
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('schedules')
          .add({
        'date': today,
        'time': '16:30',
        'vehicleId': vehicleId,
        'type': 'Delivery',
        'location': 'Main Campus',
        'status': 'Upcoming',
        'passengers': 6,
        'notes': 'End of day transport',
      });
      print('Created evening schedule');

      // Create emergency report
      final emergencyReport = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('emergencies')
          .add({
        'type': 'Maintenance',
        'details': 'Engine check light is on',
        'vehicleId': vehicleId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });
      print('Created emergency report: ${emergencyReport.id}');

      // Update user document with organization and vehicle IDs
      await _firestore.collection('users').doc(currentUser.uid).set({
        'organizationId': organizationId,
        'assignedVehicleId': vehicleId,
        'name': 'Fuad Getachew',
        'role': 'Driver',
        'email': currentUser.email,
      }, SetOptions(merge: true));
      print('Updated user document with organization and vehicle IDs');

      // Show success message
      Get.snackbar(
        'Success',
        'Sample data created successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      print('Sample data created successfully!');
    } catch (e) {
      print('Error creating sample data: $e');
      Get.snackbar(
        'Error',
        'Failed to create sample data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      rethrow;
    }
  }
}
