import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

class ImageStorageService {
  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  ImageStorageService({required FirebaseStorage storage}) : _storage = storage;

  /// Загружает файл в Firebase Storage и возвращает download URL.
  ///
  /// [storagePath] — папка в Storage (из [StoragePaths]).
  /// [filePath] — локальный путь к файлу.
  /// [ownerId] — ID пользователя (для организации по папкам).
  Future<String> uploadImage({
    required String storagePath,
    required String filePath,
    required String ownerId,
  }) async {
    final file = File(filePath);
    final extension = filePath.split('.').last.toLowerCase();
    final fileName = '${_uuid.v4()}.$extension';
    final ref = _storage.ref().child(storagePath).child(ownerId).child(fileName);

    final metadata = SettableMetadata(
      contentType: 'image/$extension',
      customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
    );

    await ref.putFile(file, metadata);
    return await ref.getDownloadURL();
  }

  /// Загружает несколько файлов и возвращает список download URL.
  Future<List<String>> uploadImages({
    required String storagePath,
    required List<String> filePaths,
    required String ownerId,
  }) async {
    final urls = <String>[];
    for (final path in filePaths) {
      final url = await uploadImage(
        storagePath: storagePath,
        filePath: path,
        ownerId: ownerId,
      );
      urls.add(url);
    }
    return urls;
  }

  /// Удаляет файл из Storage по его download URL.
  Future<void> deleteImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException {
      // Файл мог быть уже удалён — игнорируем
    }
  }

  /// Удаляет несколько файлов по их download URL.
  Future<void> deleteImages(List<String> downloadUrls) async {
    for (final url in downloadUrls) {
      await deleteImage(url);
    }
  }

  /// Удаляет все файлы в папке пользователя.
  Future<void> deleteFolder({
    required String storagePath,
    required String ownerId,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath).child(ownerId);
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
    } on FirebaseException {
      // Папка может не существовать
    }
  }
}
