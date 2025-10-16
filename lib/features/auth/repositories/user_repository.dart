import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
    String? bio,
    String? theme,
  }) async {
    await _db.collection('usuarios').doc(uid).set({
      'nombre': name,
      'email': email,
      'telefono': phone ?? '',
      'fotoUrl': photoUrl ?? '',
      'bio': bio ?? '',
      'tema': theme ?? 'light',
      'creadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
