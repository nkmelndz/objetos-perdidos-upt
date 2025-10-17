import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/object_lost.dart';
import '../../models/entrega.dart';

class AddObjectViewModel {
  final _db = FirebaseFirestore.instance;

  /// Guarda un objeto individual
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

  /// Valida los datos del formulario antes de guardar
  String? validateFormData(String name, String description, String location, String nombreEncontradoPor) {
    if (name.trim().isEmpty) {
      return 'El nombre del objeto es requerido';
    }
    if (name.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    if (description.trim().isEmpty) {
      return 'La descripción es requerida';
    }
    if (description.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    if (location.trim().isEmpty) {
      return 'El lugar donde se encontró es requerido';
    }
    if (nombreEncontradoPor.trim().isEmpty) {
      return 'El nombre de quien encontró el objeto es requerido';
    }
    if (nombreEncontradoPor.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null; // Sin errores
  }

  /// Valida la fecha encontrada
  String? validateFoundDate(DateTime foundDate) {
    final now = DateTime.now();
    if (foundDate.isAfter(now)) {
      return 'La fecha no puede ser en el futuro';
    }
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (foundDate.isBefore(oneYearAgo)) {
      return 'La fecha no puede ser mayor a un año atrás';
    }
    return null; // Sin errores
  }
}
