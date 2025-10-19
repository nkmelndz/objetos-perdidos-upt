import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../objects/models/object_lost.dart';
import '../models/dashboard_data.dart';

/// ViewModel responsable de la lógica de negocio del dashboard
class HomeDashboardViewModel {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream que combina los datos del usuario y los objetos
  /// Retorna un DashboardData con toda la información procesada
  Stream<DashboardData> getDashboardDataStream() {
    final user = _auth.currentUser;

    if (user == null) {
      // Si no hay usuario autenticado, retorna datos vacíos
      return Stream.value(DashboardData.empty());
    }

    // Combina el stream del usuario con el stream de objetos
    return _getUserNameStream(user.uid).asyncMap((userName) async {
      // Obtiene los objetos una vez por cada cambio de nombre
      final objectsSnapshot = await _db
          .collection('objetos_perdidos')
          .orderBy('fecha_registro', descending: true)
          .get();

      final objects = objectsSnapshot.docs
          .map((d) => ObjectLost.fromMap(d.id, d.data()))
          .toList();

      return DashboardData.fromObjects(
        userName: userName,
        objects: objects,
        recentLimit: 5,
      );
    });
  }

  /// Stream reactivo que escucha cambios en objetos y usuario
  Stream<DashboardData> getDashboardDataStreamReactive() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(DashboardData.empty());
    }

    // Combina ambos streams de forma reactiva
    return _getUserNameStream(user.uid).switchMap((userName) {
      return _getObjectsStream().map((objects) {
        return DashboardData.fromObjects(
          userName: userName,
          objects: objects,
          recentLimit: 5,
        );
      });
    });
  }

  /// Obtiene el stream de objetos desde Firestore
  Stream<List<ObjectLost>> _getObjectsStream() {
    return _db
        .collection('objetos_perdidos')
        .orderBy('fecha_registro', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ObjectLost.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Obtiene el nombre del usuario desde Firestore
  /// Retorna el primer nombre o un fallback si no existe
  Stream<String> _getUserNameStream(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .map((doc) => _extractUserName(doc));
  }

  /// Extrae y procesa el nombre del usuario del documento
  String _extractUserName(DocumentSnapshot doc) {
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final nombre = data['nombre'] as String?;

      if (nombre != null && nombre.isNotEmpty) {
        return _getFirstName(nombre);
      }
    }

    // Fallback al email si no hay nombre
    final user = _auth.currentUser;
    if (user?.email != null) {
      return _getEmailUsername(user!.email!);
    }

    return 'Admin';
  }

  /// Extrae el primer nombre de un nombre completo
  String _getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  /// Extrae el nombre de usuario de un email
  String _getEmailUsername(String email) {
    return email.split('@').first;
  }

  /// Método legacy para compatibilidad
  /// Se recomienda usar getDashboardDataStreamReactive() en su lugar
  @Deprecated('Use getDashboardDataStreamReactive() instead')
  Stream<List<ObjectLost>> getObjects() {
    return _getObjectsStream();
  }
}

/// Extensión para operaciones avanzadas de streams
extension StreamExtensions<T> on Stream<T> {
  /// Similar a flatMap pero cancela el stream anterior cuando llega uno nuevo
  Stream<S> switchMap<S>(Stream<S> Function(T) mapper) {
    return asyncExpand((value) => mapper(value));
  }
}
