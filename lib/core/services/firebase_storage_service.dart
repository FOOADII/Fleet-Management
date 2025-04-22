import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'storage_service.dart';

class FirebaseStorageService extends GetxService implements StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<String> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadBytes(List<int> bytes, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(bytes as Uint8List);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading bytes: $e');
      rethrow;
    }
  }

  @override
  Future<File> downloadFile(String url, String localPath) async {
    try {
      final File file = File(localPath);
      final ref = _storage.refFromURL(url);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

  @override
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      return result.items.map((ref) => ref.fullPath).toList();
    } catch (e) {
      print('Error listing files: $e');
      rethrow;
    }
  }

  String _generateUniqueFileName(String originalFileName) {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(originalFileName);
    final String nameWithoutExtension =
        path.basenameWithoutExtension(originalFileName);
    return '${nameWithoutExtension}_$timestamp$extension';
  }
}
