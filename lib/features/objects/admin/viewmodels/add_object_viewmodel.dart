import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/object_lost.dart';

class AddObjectViewModel {
  final _db = FirebaseFirestore.instance;

  Future<void> addObject(ObjectLost object) async {
    await _db.collection('objetos_perdidos').add(object.toMap());
  }
}
