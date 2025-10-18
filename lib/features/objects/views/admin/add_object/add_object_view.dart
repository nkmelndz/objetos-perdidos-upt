import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../../viewmodels/add_object_viewmodel.dart';
import '../../../models/object_lost.dart';
import '../../../../../services/auth_service.dart';
import 'widgets/add_object_header.dart';
import 'widgets/image_picker_banner.dart';
import 'widgets/add_object_form.dart';
import 'widgets/form_action_buttons.dart';
// La selección y subida se delega al ViewModel

class AddObjectView extends StatefulWidget {
  const AddObjectView({Key? key}) : super(key: key);

  @override
  State<AddObjectView> createState() => _AddObjectViewState();
}

class _AddObjectViewState extends State<AddObjectView>
    with TickerProviderStateMixin {
  final AddObjectViewModel _viewModel = AddObjectViewModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _encontradoPorController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _imageUrl = '';
  bool _isLoading = false; // solo para guardar
  bool _isUploadingImage = false; // para subida de imagen

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Focus nodes para mejor UX
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _encontradoPorFocus = FocusNode();

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
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _encontradoPorController.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    _locationFocus.dispose();
    _encontradoPorFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

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
              child: AddObjectHeader(isTablet: isTablet),
            ),

            // Contenido con scroll y animaciones
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
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Banner de imagen con animación
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ImagePickerBanner(
                            imageUrl: _imageUrl,
                            onTap: _handleImagePick,
                            isUploading: _isUploadingImage,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Formulario
                        AddObjectForm(
                          nameController: _nameController,
                          descController: _descController,
                          locationController: _locationController,
                          encontradoPorController: _encontradoPorController,
                          selectedDate: _selectedDate,
                          nameFocus: _nameFocus,
                          descFocus: _descFocus,
                          locationFocus: _locationFocus,
                          encontradoPorFocus: _encontradoPorFocus,
                          onDateSelected: (date) {
                            setState(() => _selectedDate = date);
                          },
                        ),

                        const SizedBox(height: 40),

                        // Botones de acción
                        FormActionButtons(
                          isLoading: _isLoading,
                          onClear: _clearForm,
                          onSubmit: _handleSubmit,
                        ),

                        const SizedBox(height: 24),
                      ],
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

  void _handleImagePick() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Elegir de la galería'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickAndUpload(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Tomar una foto'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickAndUpload(fromCamera: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload({required bool fromCamera}) async {
    setState(() => _isUploadingImage = true);
    HapticFeedback.lightImpact();
    final objectTempId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final url = await _viewModel
          .pickAndUploadImage(
            fromCamera: fromCamera,
            tempObjectId: objectTempId,
          )
          .timeout(const Duration(seconds: 35));

      if (!mounted) return;
      if (url != null) {
        setState(() => _imageUrl = url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen subida correctamente'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        _showErrorSnackBar(
          'La subida de la imagen tardó demasiado. Intenta de nuevo.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('No se pudo subir la imagen: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _locationController.clear();
    _encontradoPorController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _imageUrl = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: Color(0xFF01579B)),
            SizedBox(width: 12),
            Text(
              'Formulario limpiado',
              style: TextStyle(color: Color(0xFF01579B)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFC107),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Evitar guardar mientras se sube la imagen
    if (_isUploadingImage) {
      _showErrorSnackBar('Espera a que termine de subir la imagen.');
      return;
    }
    // Validar formulario
    final validation = _viewModel.validateFormData(
      _nameController.text,
      _descController.text,
      _locationController.text,
      _encontradoPorController.text,
      imageUrl: _imageUrl,
    );

    if (validation != null) {
      _showErrorSnackBar(validation);
      return;
    }

    // Validar fecha
    final dateValidation = _viewModel.validateFoundDate(_selectedDate);
    if (dateValidation != null) {
      _showErrorSnackBar(dateValidation);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final object = ObjectLost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        location: _locationController.text.trim(),
        foundDate: _selectedDate,
        imageUrl: _imageUrl,
        status: ObjectStatus.pendiente,
        userId: AuthService.getCurrentUserId() ?? 'unknown',
        createdAt: DateTime.now(),
      );

      await _viewModel.addObjectAndEntrega(
        object,
        _encontradoPorController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        _showSuccessDialog();
        // Limpiar formulario
        _nameController.clear();
        _descController.clear();
        _locationController.clear();
        _encontradoPorController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _imageUrl = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al guardar: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFFFFC107),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Objeto registrado!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'El objeto ha sido registrado correctamente y está disponible en la lista de objetos perdidos.',
          style: TextStyle(fontSize: 15, color: Color(0xFF5A6C7D), height: 1.5),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }
}
