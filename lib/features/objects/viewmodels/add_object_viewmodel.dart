import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/object_lost.dart';
import '../models/entrega.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/storage_service.dart';

class AddObjectViewModel {
  final _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storage = StorageService();

  /// Guarda un objeto individual
  Future<void> addObject(ObjectLost object) async {
    final data = object.toMap();
    await _db.collection('objetos_perdidos').add(data);
  }

  /// Guarda el objeto y crea la entrega inicial (solo con nombreEncontradoPor)
  Future<void> addObjectAndEntrega(
    ObjectLost object,
    String nombreEncontradoPor,
  ) async {
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
  String? validateFormData(
    String name,
    String description,
    String location,
    String nombreEncontradoPor, {
    String? imageUrl,
  }) {
    if (name.trim().isEmpty) {
      return 'El nombre del objeto es requerido';
    }
    if (name.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    // La descripción es opcional, pero si se proporciona debe tener contenido válido
    if (description.trim().isNotEmpty && description.trim().length < 5) {
      return 'La descripción debe tener al menos 5 caracteres';
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
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'La foto del objeto es obligatoria';
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

  /// Abre la galería o cámara, sube a Storage y devuelve la URL
  Future<String?> pickAndUploadImage({
    required bool fromCamera,
    required String tempObjectId,
  }) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null) return null;
    final url = await _storage.uploadObjectImage(
      file: picked,
      objectId: tempObjectId,
    );
    return url;
  }
}
