import 'package:flutter/material.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/views/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = ProfileViewModel();
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<Map<String, dynamic>?>(
      stream: viewModel.userProfileStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final nameController = TextEditingController(text: data['nombre'] ?? '');
        final emailController = TextEditingController(text: data['email'] ?? '');
        final phoneController = TextEditingController(text: data['telefono'] ?? '');
        final bioController = TextEditingController(text: data['bio'] ?? '');
        final photoUrl = data['fotoUrl'] ?? '';
        final isEditing = ValueNotifier(false);
        void saveProfile() {
          viewModel.updateProfile({
            'nombre': nameController.text,
            'telefono': phoneController.text,
            'bio': bioController.text,
          });
          isEditing.value = false;
        }
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ValueListenableBuilder<bool>(
              valueListenable: isEditing,
              builder: (context, editing, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty ? const Icon(Icons.person, size: 60, color: Color(0xFF003366)) : null,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    enabled: editing,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                    enabled: false,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                    enabled: editing,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    enabled: editing,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: Icon(editing ? Icons.save : Icons.edit),
                        label: Text(editing ? 'Guardar' : 'Personalizar'),
                        onPressed: () {
                          if (editing) {
                            saveProfile();
                          } else {
                            isEditing.value = true;
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          // Ignora el stack y navega a login
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginView()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
