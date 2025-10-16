import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';

class LoginViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user != null) {
        // Crear/actualizar perfil en Firestore
        await UserRepository().createUserProfile(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? 'Admin',
          email: userCredential.user!.email ?? email.trim(),
        );
        return null; // Éxito
      }
      return 'No se pudo iniciar sesión.';
    } catch (e) {
      return e.toString();
    }
  }
}
