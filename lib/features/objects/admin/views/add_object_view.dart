import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/add_object_viewmodel.dart';
import '../../models/object_lost.dart';
import '../../../../services/auth_service.dart';

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
  bool _isLoading = false;

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
              child: _buildHeader(isTablet),
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
                          child: _buildImagePickerBanner(),
                        ),
                        const SizedBox(height: 32),

                        // Sección: Información básica
                        _buildSectionTitle(
                          icon: Icons.info_outline_rounded,
                          title: 'Información del objeto',
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _nameController,
                          focusNode: _nameFocus,
                          label: 'Nombre del objeto',
                          icon: Icons.inventory_2_rounded,
                          hint: 'Ej: Celular Samsung, Mochila azul',
                          onSubmitted: (_) => _descFocus.requestFocus(),
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _descController,
                          focusNode: _descFocus,
                          label: 'Descripción detallada',
                          icon: Icons.description_rounded,
                          hint: 'Describe características del objeto',
                          maxLines: 4,
                          onSubmitted: (_) => _locationFocus.requestFocus(),
                        ),

                        const SizedBox(height: 32),

                        // Sección: Ubicación y persona
                        _buildSectionTitle(
                          icon: Icons.place_outlined,
                          title: 'Ubicación y registro',
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _locationController,
                          focusNode: _locationFocus,
                          label: 'Lugar encontrado',
                          icon: Icons.location_on_rounded,
                          hint: 'Ej: Biblioteca, Lab 3, Cafetería',
                          onSubmitted: (_) =>
                              _encontradoPorFocus.requestFocus(),
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _encontradoPorController,
                          focusNode: _encontradoPorFocus,
                          label: 'Encontrado por',
                          icon: Icons.person_rounded,
                          hint: 'Nombre completo',
                          onSubmitted: (_) => _encontradoPorFocus.unfocus(),
                        ),

                        const SizedBox(height: 16),

                        // Selector de fecha mejorado
                        _buildDatePicker(),

                        const SizedBox(height: 40),

                        // Botones de acción
                        Row(
                          children: [
                            Expanded(child: _buildSecondaryButton()),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: _buildSubmitButton()),
                          ],
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

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32.0 : 24.0,
        20.0,
        isTablet ? 32.0 : 24.0,
        32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_box_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuevo objeto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registra un objeto encontrado',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Título de sección
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
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

  /// Banner horizontal para selección de imagen
  Widget _buildImagePickerBanner() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.1),
            const Color(0xFF0277BD).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Implementar selección de imagen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.photo_camera_rounded, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Función de imagen próximamente disponible'),
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
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Vista previa de imagen o icono
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _imageUrl.isEmpty
                        ? const Color(0xFF1565C0).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: _imageUrl.isEmpty
                        ? Border.all(
                            color: const Color(0xFF1565C0).withOpacity(0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  child: _imageUrl.isEmpty
                      ? Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 36,
                          color: const Color(0xFF1565C0).withOpacity(0.6),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(width: 20),
                // Texto descriptivo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Foto del objeto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _imageUrl.isEmpty
                            ? 'Toca para añadir una imagen (opcional)'
                            : 'Toca para cambiar la imagen',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icono de acción
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _imageUrl.isEmpty
                        ? Icons.camera_alt_rounded
                        : Icons.edit_rounded,
                    color: const Color(0xFF1565C0),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
  }) {
    // Asignar colores diferentes según el icono
    Color iconColor;
    switch (icon) {
      case Icons.inventory_2_rounded:
        iconColor = const Color(0xFF1565C0); // Azul principal
        break;
      case Icons.description_rounded:
        iconColor = const Color(0xFF6A1B9A); // Púrpura
        break;
      case Icons.location_on_rounded:
        iconColor = const Color(0xFFE91E63); // Rosa
        break;
      case Icons.person_rounded:
        iconColor = const Color(0xFF00897B); // Verde azulado
        break;
      default:
        iconColor = const Color(0xFF1565C0);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        textInputAction: maxLines > 1
            ? TextInputAction.newline
            : TextInputAction.next,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        HapticFeedback.selectionClick();
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFFF6F00), // Naranja para el calendario
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFFF6F00),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha encontrado',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_calendar_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1565C0), width: 2),
      ),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _clearForm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1565C0),
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Limpiar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0277BD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.check_circle_rounded, size: 24),
        label: Text(
          _isLoading ? 'Guardando...' : 'Registrar objeto',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
        onPressed: _isLoading
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                await _handleSubmit();
              },
      ),
    );
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
            Icon(Icons.refresh_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Formulario limpiado'),
          ],
        ),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Validar formulario
    final validation = _viewModel.validateFormData(
      _nameController.text,
      _descController.text,
      _locationController.text,
      _encontradoPorController.text,
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
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
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
