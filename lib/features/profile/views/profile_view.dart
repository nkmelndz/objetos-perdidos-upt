import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/views/login_view.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_action_buttons.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  final ProfileViewModel _viewModel = ProfileViewModel();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Iniciar animaciones en secuencia
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
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
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
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
                          // Título de sección con slide
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildSectionTitle('Información personal'),
                          ),
                          const SizedBox(height: 16),

                          // Información del perfil con scale
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: ProfileInfoCard(
                              nameController: nameController,
                              phoneController: phoneController,
                              bioController: bioController,
                              isEditing: editing,
                              isTablet: isTablet,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Botones de acción con slide
                          SlideTransition(
                            position: _slideAnimation,
                            child: ProfileActionButtons(
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
                          ),
                          const SizedBox(height: 24),

                          // Sección cambiar contraseña
                          _buildSectionTitle('Seguridad'),
                          const SizedBox(height: 12),
                          _ChangePasswordCard(isTablet: isTablet),
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
            Expanded(child: Text('Función de foto próximamente disponible')),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _ChangePasswordCard extends StatefulWidget {
  final bool isTablet;
  const _ChangePasswordCard({required this.isTablet});

  @override
  State<_ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<_ChangePasswordCard> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final _vm = LoginViewModel();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      padding: EdgeInsets.all(widget.isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _passwordField(
            controller: _currentCtrl,
            label: 'Contraseña actual',
            obscure: _obscureCurrent,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _newCtrl,
            label: 'Nueva contraseña',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _confirmCtrl,
            label: 'Confirmar nueva contraseña',
            obscure: _obscureConfirm,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleChangePassword,
                    icon: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Actualizar contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    final current = _currentCtrl.text.trim();
    final newPwd = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      _showSnack('Completa todos los campos', isError: true);
      return;
    }
    if (newPwd.length < 6) {
      _showSnack(
        'La nueva contraseña debe tener al menos 6 caracteres',
        isError: true,
      );
      return;
    }
    if (newPwd != confirm) {
      _showSnack('Las contraseñas no coinciden', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final err = await _vm.changePassword(
      currentPassword: current,
      newPassword: newPwd,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (err == null) {
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
      _showSnack('Contraseña actualizada correctamente');
    } else {
      _showSnack(err, isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[600] : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
