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
        // Obtener los claims del token
        final user = userCredential.user!;
        final tokenResult = await user.getIdTokenResult();
        print('Token claims:');
        print(tokenResult.claims);
        
        // Crear/actualizar perfil en Firestore
        await UserRepository().createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Admin',
          email: user.email ?? email.trim(),
        );
        return null; // Éxito
      }
      return 'No se pudo iniciar sesión.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'No se pudo enviar el correo de restablecimiento.';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return 'Sesión no válida. Vuelve a iniciar sesión.';
      }

      // Reautenticar
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Actualizar contraseña
      await user.updatePassword(newPassword.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'No se pudo actualizar la contraseña.';
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña actual incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas.';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde.';
      case 'weak-password':
        return 'La nueva contraseña es demasiado débil.';
      case 'requires-recent-login':
        return 'Por seguridad, vuelve a iniciar sesión y reintenta.';
      case 'invalid-email':
        return 'Correo inválido.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }
}
