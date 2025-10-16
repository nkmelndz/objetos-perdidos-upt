import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewModel {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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
}
