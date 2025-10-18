import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/object_lost.dart';
import '../models/entrega.dart';
import '../utils/object_lost_utils.dart';

class ObjectsViewModel {
  final _db = FirebaseFirestore.instance;
  String _search = '';
  ObjectStatus? _filter;

  // Getters para el estado actual
  String get currentSearch => _search;
  ObjectStatus? get currentFilter => _filter;

  /// Actualiza el término de búsqueda
  void setSearch(String value) => _search = value;

  /// Actualiza el filtro de estado
  void setFilter(ObjectStatus? status) => _filter = status;

  /// Stream de objetos con filtros aplicados
  Stream<List<ObjectLost>> objectsStream() {
    return _db
        .collection('objetos_perdidos')
        .orderBy('fecha_registro', descending: true)
        .snapshots()
        .map((snap) {
          var list = snap.docs
              .map((d) => ObjectLost.fromMap(d.id, d.data()))
              .toList();

          // Aplicar filtros
          return _applyFilters(list);
        });
  }

  /// Aplica filtros de búsqueda y estado
  List<ObjectLost> _applyFilters(List<ObjectLost> objects) {
    return objects.where((obj) {
      return ObjectLostUtils.matchesSearch(obj, _search) &&
          ObjectLostUtils.matchesStatus(obj, _filter);
    }).toList();
  }

  /// Actualiza un objeto
  Future<void> updateObject(String id, ObjectLost object) async {
    await _db.collection('objetos_perdidos').doc(id).update(object.toMap());
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

  /// Obtiene la información completa de entrega de un objeto
  Future<Entrega?> getEntregaByObjectId(String objectId) async {
    final entregaSnapshot = await _db
        .collection('objetos_perdidos')
        .doc(objectId)
        .collection('entrega')
        .limit(1)
        .get();

    if (entregaSnapshot.docs.isNotEmpty) {
      final doc = entregaSnapshot.docs.first;
      return Entrega.fromMap(doc.id, doc.data());
    }
    return null;
  }

  /// Valida los datos de un objeto antes de guardar
  String? validateObjectData(
    String name,
    String description,
    String location,
    String nombreEncontradoPor,
  ) {
    if (name.trim().isEmpty) {
      return 'El nombre del objeto es requerido';
    }
    if (description.trim().isEmpty) {
      return 'La descripción es requerida';
    }
    if (location.trim().isEmpty) {
      return 'El lugar donde se encontró es requerido';
    }
    if (nombreEncontradoPor.trim().isEmpty) {
      return 'El nombre de quien encontró el objeto es requerido';
    }
    return null; // Sin errores
  }

  /// Valida los datos de entrega antes de guardar
  String? validateEntregaData(String nombreDevueltoA, String codigoEstudiante) {
    if (nombreDevueltoA.trim().isEmpty) {
      return 'El nombre de la persona a quien se devuelve es requerido';
    }
    if (codigoEstudiante.trim().isEmpty) {
      return 'El código del estudiante es requerido';
    }
    return null; // Sin errores
  }

  /// Limpia los filtros aplicados
  void clearFilters() {
    _search = '';
    _filter = null;
  }
}
