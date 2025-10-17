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
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _encontradoPorController.dispose();
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
            // Header
            _buildHeader(isTablet),

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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32.0 : 24.0,
                        32.0,
                        isTablet ? 32.0 : 24.0,
                        24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Avatar de imagen
                          _buildImagePicker(),

                          const SizedBox(height: 32),

                          // Campos del formulario
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nombre del objeto',
                            icon: Icons.inventory_2_rounded,
                            hint: 'Ej: Celular Samsung, Mochila azul',
                          ),

                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _descController,
                            label: 'Descripción',
                            icon: Icons.description_rounded,
                            hint: 'Describe el objeto encontrado',
                            maxLines: 3,
                          ),

                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _locationController,
                            label: 'Lugar encontrado',
                            icon: Icons.location_on_rounded,
                            hint: 'Ej: Biblioteca, Lab 3, Auditorio',
                          ),

                          const SizedBox(height: 20),

                          _buildTextField(
                            controller: _encontradoPorController,
                            label: 'Encontrado por',
                            icon: Icons.person_rounded,
                            hint: 'Nombre de quien encontró el objeto',
                          ),

                          const SizedBox(height: 20),

                          // Selector de fecha
                          _buildDatePicker(),

                          const SizedBox(height: 32),

                          // Botón de guardar
                          _buildSubmitButton(),

                          const SizedBox(height: 32),
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

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32.0 : 24.0,
        20.0,
        isTablet ? 32.0 : 24.0,
        32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Registrar objeto',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 32 : 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Completa la información del objeto encontrado',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Implementar selección de imagen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Función de imagen próximamente'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF1565C0),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _imageUrl.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 48,
                          color: const Color(0xFF1565C0).withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Añadir foto',
                          style: TextStyle(
                            color: const Color(0xFF1565C0).withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : ClipOval(
                      child: Image.network(_imageUrl, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Opcional',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
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
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: iconColor, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFFFF6F00), // Naranja
              size: 22,
            ),
            const SizedBox(width: 12),
            Column(
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.edit_calendar_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
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
          colors: [Color(0xFF1565C0), Color(0xFF0277BD)], // Degradado azul
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_rounded, size: 22),
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Objeto registrado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: const Text(
          'El objeto ha sido registrado correctamente y está disponible en la lista.',
          style: TextStyle(fontSize: 15, color: Color(0xFF5A6C7D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
