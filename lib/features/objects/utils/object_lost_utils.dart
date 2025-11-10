import 'package:flutter/material.dart';
import '../models/object_lost.dart';

class ObjectLostUtils {
  /// Categorías canónicas disponibles
  static const List<String> categoryKeys = [
    'accesorio_personal',
    'material_academico',
    'documento',
    'electronico',
    'otros',
  ];

  /// Convierte la categoría canónica a etiqueta visible
  static String categoryToText(String key) {
    switch (key) {
      case 'accesorio_personal':
        return 'Accesorio personal';
      case 'material_academico':
        return 'Material académico';
      case 'documento':
        return 'Documento';
      case 'electronico':
        return 'Electrónico';
      case 'otros':
      default:
        return 'Otros';
    }
  }
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

  /// Filtra objetos por categoría
  static bool matchesCategory(ObjectLost object, String? categoryFilter) {
    return categoryFilter == null || object.category == categoryFilter;
  }
}