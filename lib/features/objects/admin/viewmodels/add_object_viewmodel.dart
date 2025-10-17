import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/object_lost.dart';
import '../../models/entrega.dart';

class AddObjectViewModel {
  final _db = FirebaseFirestore.instance;

  Future<void> addObject(ObjectLost object) async {
    final data = object.toMap();
    await _db.collection('objetos_perdidos').add(data);
  }

  /// Guarda el objeto y crea la entrega inicial (solo con nombreEncontradoPor)
  Future<void> addObjectAndEntrega(ObjectLost object, String nombreEncontradoPor) async {
    final data = object.toMap();
    // Primero guardar el objeto y obtener el docRef
    final docRef = await _db.collection('objetos_perdidos').add(data);
    
    // Crear entrega inicial solo con nombreEncontradoPor
    final entregaInicial = Entrega.inicial(
      nombreEncontradoPor: nombreEncontradoPor,
    );
    
    // Guardar la entrega inicial en una subcolección "entrega" del objeto
    await docRef.collection('entrega').add(entregaInicial.toMap());
  }
}
