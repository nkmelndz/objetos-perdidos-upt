import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/object_lost.dart';
import '../../models/entrega.dart';

class ObjectsViewModel {
  Future<void> updateObject(String id, ObjectLost object) async {
    await _db.collection('objetos_perdidos').doc(id).update(object.toMap());
  }
  final _db = FirebaseFirestore.instance;
  String _search = '';
  ObjectStatus? _filter;

  void setSearch(String value) => _search = value;
  void setFilter(ObjectStatus? status) => _filter = status;

  Stream<List<ObjectLost>> objectsStream() {
    return _db
        .collection('objetos_perdidos')
        .orderBy('fecha_registro', descending: true)
        .snapshots()
        .map((snap) {
          var list = snap.docs
              .map((d) => ObjectLost.fromMap(d.id, d.data()))
              .toList();
          if (_search.isNotEmpty) {
            list = list
                .where(
                  (o) =>
                      o.name.toLowerCase().contains(_search.toLowerCase()) ||
                      o.description.toLowerCase().contains(
                        _search.toLowerCase(),
                      ) ||
                      o.location.toLowerCase().contains(_search.toLowerCase()),
                )
                .toList();
          }
          if (_filter != null) {
            list = list.where((o) => o.status == _filter).toList();
          }
          return list;
        });
  }

  Future<void> addEntrega(String objectId, Entrega entrega) async {
    final doc = _db.collection('objetos_perdidos').doc(objectId);
    await doc.update({'estado': 'entregado'});
    
    // Buscar el documento de entrega existente y actualizarlo
    final entregaSnapshot = await doc.collection('entrega').limit(1).get();
    if (entregaSnapshot.docs.isNotEmpty) {
      // Actualizar el documento existente
      await entregaSnapshot.docs.first.reference.update(entrega.toMap());
    } else {
      // Si no existe, crear uno nuevo (caso de respaldo)
      await doc.collection('entrega').add(entrega.toMap());
    }
  }

  /// Obtiene el nombreEncontradoPor de la subcolección entrega
  Future<String> getNombreEncontradoPor(String objectId) async {
    final entregaSnapshot = await _db
        .collection('objetos_perdidos')
        .doc(objectId)
        .collection('entrega')
        .limit(1)
        .get();
    
    if (entregaSnapshot.docs.isNotEmpty) {
      final data = entregaSnapshot.docs.first.data();
      return data['nombre_encontrado_por'] ?? '';
    }
    return '';
  }
}
