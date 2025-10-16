import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/object_lost.dart';

class AddObjectViewModel {
  final _db = FirebaseFirestore.instance;

  Future<void> addObject(ObjectLost object) async {
    final data = object.toMap();
    await _db.collection('objetos_perdidos').add(data);
  }

  /// Guarda el objeto y la entrega (quedando la entrega en una subcolección del objeto)
  Future<void> addObjectAndEntrega(ObjectLost object, Map<String, dynamic> entrega) async {
    final data = object.toMap();
    // Primero guardar el objeto y obtener el docRef
    final docRef = await _db.collection('objetos_perdidos').add(data);
    // Guardar la entrega en una subcolección "entregas" del objeto
    await docRef.collection('entregas').add(entrega);
  }
}
