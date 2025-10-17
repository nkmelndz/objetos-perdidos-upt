import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/views/login_view.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_action_buttons.dart';
import 'widgets/profile_stats_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  final ProfileViewModel _viewModel = ProfileViewModel();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _viewModel.userProfileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final data = snapshot.data ?? {};
        return _buildContent(context, data, isTablet);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF0277BD), Color(0xFFF8F9FA)],
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, dynamic> data,
    bool isTablet,
  ) {
    final nameController = TextEditingController(text: data['nombre'] ?? '');
    final phoneController = TextEditingController(text: data['telefono'] ?? '');
    final bioController = TextEditingController(text: data['bio'] ?? '');
    final photoUrl = data['fotoUrl'] ?? '';
    final userName = data['nombre'] ?? '';
    final userEmail = data['email'] ?? '';
    final isEditing = ValueNotifier(false);

    // Stats simuladas (puedes obtenerlas del viewModel)
    final objectsFound = data['objetosEncontrados'] ?? 0;
    final objectsClaimed = data['objetosEntregados'] ?? 0;
    final daysActive = data['diasActivo'] ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF0277BD), Color(0xFFF8F9FA)],
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header con animación
            FadeTransition(
              opacity: _fadeAnimation,
              child: ProfileHeader(
                photoUrl: photoUrl,
                userName: userName,
                userEmail: userEmail,
                isTablet: isTablet,
                onEditPhoto: _handleEditPhoto,
              ),
            ),

            // Contenido con scroll
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32.0 : 24.0,
                    32.0,
                    isTablet ? 32.0 : 24.0,
                    32.0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isEditing,
                      builder: (context, editing, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tarjeta de estadísticas
                          ProfileStatsCard(
                            objectsFound: objectsFound,
                            objectsClaimed: objectsClaimed,
                            daysActive: daysActive,
                            isTablet: isTablet,
                          ),

                          // Título de sección
                          _buildSectionTitle('Información personal'),
                          const SizedBox(height: 16),

                          // Información del perfil
                          ProfileInfoCard(
                            nameController: nameController,
                            phoneController: phoneController,
                            bioController: bioController,
                            isEditing: editing,
                            isTablet: isTablet,
                          ),

                          const SizedBox(height: 32),

                          // Botones de acción
                          ProfileActionButtons(
                            isEditing: editing,
                            onEdit: () {
                              HapticFeedback.lightImpact();
                              isEditing.value = true;
                            },
                            onSave: () {
                              _saveProfile(
                                nameController,
                                phoneController,
                                bioController,
                                isEditing,
                              );
                            },
                            onLogout: _handleLogout,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF1565C0),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  void _handleEditPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.photo_camera_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Función de foto próximamente disponible'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveProfile(
    TextEditingController nameController,
    TextEditingController phoneController,
    TextEditingController bioController,
    ValueNotifier<bool> isEditing,
  ) {
    // Validar que el nombre no esté vacío
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('El nombre no puede estar vacío')),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    _viewModel.updateProfile({
      'nombre': nameController.text.trim(),
      'telefono': phoneController.text.trim(),
      'bio': bioController.text.trim(),
    });

    isEditing.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Perfil actualizado correctamente'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }
}
