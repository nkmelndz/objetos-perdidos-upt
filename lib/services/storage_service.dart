import 'dart:io';
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadObjectImage({
    required XFile file,
    required String objectId,
  }) async {
    final String ext = file.name.split('.').last.toLowerCase();
    final String path =
        'objetos/$objectId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: _mimeTypeFromExt(ext));
    // Asegura que nunca quede colgado: timeout de 30s
    await ref
        .putFile(File(file.path), metadata)
        .timeout(const Duration(seconds: 30));
    return await ref.getDownloadURL().timeout(const Duration(seconds: 15));
  }

  Future<String> uploadObjectImageFromPath({
    required String filePath,
    required String objectId,
  }) async {
    final String ext = filePath.split('.').last.toLowerCase();
    final String path =
        'objetos/$objectId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: _mimeTypeFromExt(ext));
    await ref
        .putFile(File(filePath), metadata)
        .timeout(const Duration(seconds: 30));
    return await ref.getDownloadURL().timeout(const Duration(seconds: 15));
  }

  String _mimeTypeFromExt(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
