import 'dart:io';

abstract class StorageService {
  /// Upload a file to storage and return the download URL
  Future<String> uploadFile(File file, String path);

  /// Upload data as bytes to storage and return the download URL
  Future<String> uploadBytes(List<int> bytes, String path);

  /// Download a file from storage
  Future<File> downloadFile(String url, String localPath);

  /// Get the download URL for a file
  Future<String> getDownloadURL(String path);

  /// Delete a file from storage
  Future<void> deleteFile(String path);

  /// List files in a directory
  Future<List<String>> listFiles(String path);
}
