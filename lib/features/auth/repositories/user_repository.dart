import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
    String? bio,
    String? theme,
  }) async {
    final ref = _db.collection('usuarios').doc(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      // Crear perfil por primera vez
      await ref.set({
        'nombre': name,
        'email': email,
        'telefono': phone ?? '',
        'fotoUrl': photoUrl ?? '',
        'bio': bio ?? '',
        'tema': theme ?? 'light',
        'creadoEn': FieldValue.serverTimestamp(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
    } else {
      // Actualizar solo lo necesario sin pisar cambios previos del usuario
      final current = snap.data() ?? <String, dynamic>{};
      final Map<String, dynamic> updateData = {
        'email': email,
        'actualizadoEn': FieldValue.serverTimestamp(),
      };

      // Solo establecer nombre si no existe o está vacío
      final currentName = (current['nombre'] as String?)?.trim() ?? '';
      if (currentName.isEmpty && name.trim().isNotEmpty) {
        updateData['nombre'] = name.trim();
      }

      // Solo actualizar campos opcionales si vienen provistos (no null)
      if (phone != null) updateData['telefono'] = phone;
      if (photoUrl != null) updateData['fotoUrl'] = photoUrl;
      if (bio != null) updateData['bio'] = bio;
      if (theme != null) updateData['tema'] = theme;

      if (updateData.length > 2) {
        // hay algo más que email / actualizadoEn para actualizar
        await ref.update(updateData);
      } else {
        // Asegura al menos la marca de tiempo de actualización
        await ref.update({
          'actualizadoEn': FieldValue.serverTimestamp(),
          'email': email,
        });
      }
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
