import 'package:flutter/material.dart';
import '../models/object_lost.dart';

class ObjectLostUtils {
  /// Convierte el estado a texto legible
  static String statusToText(ObjectStatus status) {
    switch (status) {
      case ObjectStatus.encontrado:
        return 'Encontrado';
      case ObjectStatus.entregado:
        return 'Entregado';
    }
  }

  /// Obtiene el color asociado al estado
  static Color statusToColor(ObjectStatus status) {
    switch (status) {
      case ObjectStatus.encontrado:
        return Colors.orange;
      case ObjectStatus.entregado:
        return Colors.green;
    }
  }

  /// Formatea una fecha a formato dd/MM/yyyy
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Valida si un objeto coincide con el término de búsqueda
  static bool matchesSearch(ObjectLost object, String searchTerm) {
    if (searchTerm.isEmpty) return true;
    
    final term = searchTerm.toLowerCase();
    return object.name.toLowerCase().contains(term) ||
           object.description.toLowerCase().contains(term) ||
           object.location.toLowerCase().contains(term);
  }

  /// Filtra objetos por estado
  static bool matchesStatus(ObjectLost object, ObjectStatus? statusFilter) {
    return statusFilter == null || object.status == statusFilter;
  }
}