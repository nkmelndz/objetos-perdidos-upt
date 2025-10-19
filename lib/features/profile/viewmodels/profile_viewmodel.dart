import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../services/storage_service.dart';

class ProfileViewModel {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storageService = StorageService();

  Stream<Map<String, dynamic>?> get userProfileStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('usuarios').doc(uid).snapshots().map((doc) => doc.data());
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('usuarios').doc(uid).set(data, SetOptions(merge: true));
    }
  }
  
  Future<String?> uploadProfilePhoto(XFile imageFile) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      
      // Modificamos el método para usar la carpeta 'perfiles' en lugar de 'objetos'
      final String ext = imageFile.name.split('.').last.toLowerCase();
      final String path = 'perfiles/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      final ref = FirebaseStorage.instance.ref().child(path);
      final metadata = SettableMetadata(
        contentType: _getMimeTypeFromExt(ext)
      );
      
      await ref.putFile(File(imageFile.path), metadata)
          .timeout(const Duration(seconds: 30));
      
      final downloadUrl = await ref.getDownloadURL();
      
      // Actualizar el perfil con la nueva URL de la foto
      await updateProfile({'fotoUrl': downloadUrl});
      
      return downloadUrl;
    } catch (e) {
      print('Error al subir la foto de perfil: $e');
      return null;
    }
  }
  
  // Implementación local del método para determinar el tipo MIME
  String _getMimeTypeFromExt(String ext) {
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
