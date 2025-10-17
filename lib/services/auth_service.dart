import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene el ID del usuario actual autenticado
  static String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }

  /// Obtiene el email del usuario actual autenticado
  static String? getCurrentUserEmail() {
    final user = _auth.currentUser;
    return user?.email;
  }

  /// Obtiene el usuario actual completo
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Verifica si hay un usuario autenticado
  static bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Stream del estado de autenticación
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}