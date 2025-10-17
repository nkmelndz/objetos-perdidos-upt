import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/objects_viewmodel.dart';
import '../../models/object_lost.dart';
import '../../models/entrega.dart';
import '../../utils/object_lost_utils.dart';
import '../../../../services/auth_service.dart';

class ObjectsView extends StatefulWidget {
  const ObjectsView({Key? key}) : super(key: key);

  @override
  State<ObjectsView> createState() => _ObjectsViewState();
}

class _ObjectsViewState extends State<ObjectsView>
    with TickerProviderStateMixin {
  final ObjectsViewModel _viewModel = ObjectsViewModel();
  final TextEditingController _searchController = TextEditingController();
  ObjectStatus? _selectedFilter;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
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

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
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
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 32.0 : 24.0,
                  20.0,
                  isTablet ? 32.0 : 24.0,
                  24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objetos Perdidos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestiona y busca objetos registrados',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Barra de búsqueda y filtros
            SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 24.0,
                ),
                child: Column(
                  children: [
                    // Campo de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Buscar objeto...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF1565C0),
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _viewModel.setSearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          _viewModel.setSearch(value);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filtros de estado
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Todos',
                            isSelected: _selectedFilter == null,
                            onTap: () {
                              setState(() => _selectedFilter = null);
                              _viewModel.setFilter(null);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Pendientes',
                            isSelected:
                                _selectedFilter == ObjectStatus.pendiente,
                            onTap: () {
                              setState(
                                () => _selectedFilter = ObjectStatus.pendiente,
                              );
                              _viewModel.setFilter(ObjectStatus.pendiente);
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Entregados',
                            isSelected:
                                _selectedFilter == ObjectStatus.entregado,
                            onTap: () {
                              setState(
                                () => _selectedFilter = ObjectStatus.entregado,
                              );
                              _viewModel.setFilter(ObjectStatus.entregado);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Lista de objetos
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
                child: StreamBuilder<List<ObjectLost>>(
                  stream: _viewModel.objectsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState();
                    }

                    final objects = snapshot.data ?? [];

                    if (objects.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32.0 : 24.0,
                        24.0,
                        isTablet ? 32.0 : 24.0,
                        24.0,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: objects.length,
                      itemBuilder: (context, index) {
                        return _buildObjectCard(objects[index], index);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un chip de filtro
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta de objeto
  Widget _buildObjectCard(ObjectLost obj, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen o icono
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1565C0).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: obj.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            obj.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.inventory_2_rounded,
                                color: const Color(0xFF1565C0),
                                size: 32,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.inventory_2_rounded,
                          color: const Color(0xFF1565C0),
                          size: 32,
                        ),
                ),

                const SizedBox(width: 16),

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obj.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        obj.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ObjectLostUtils.statusToColor(
                      obj.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ObjectLostUtils.statusToColor(
                        obj.status,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ObjectLostUtils.statusToText(obj.status),
                    style: TextStyle(
                      color: ObjectLostUtils.statusToColor(obj.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: const Color(0xFF1565C0),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      obj.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_rounded,
                    color: const Color(0xFF1565C0),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ObjectLostUtils.formatDate(obj.foundDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Editar',
                    color: const Color(0xFF1565C0),
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final edited = await _showEditObjectDialog(context, obj);
                      if (edited != null) {
                        await _viewModel.updateObject(obj.id, edited);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.check_circle_rounded,
                    label: obj.status == ObjectStatus.entregado
                        ? 'Entregado'
                        : 'Entregar',
                    color: obj.status == ObjectStatus.entregado
                        ? Colors.grey
                        : const Color(0xFF4CAF50),
                    onTap: obj.status == ObjectStatus.entregado
                        ? null
                        : () async {
                            HapticFeedback.lightImpact();
                            final entrega = await _showEntregaDialog(
                              context,
                              obj.id,
                            );
                            if (entrega != null) {
                              await _viewModel.addEntrega(obj.id, entrega);
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un botón de acción
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isDisabled
                ? color.withOpacity(0.1)
                : color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? color.withOpacity(0.2)
                  : color.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: const Color(0xFF1565C0)),
          const SizedBox(height: 16),
          Text(
            'Cargando objetos...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar objetos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor, intenta de nuevo más tarde',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: const Color(0xFF1565C0).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No se encontraron objetos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'No hay objetos registrados aún',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Diálogo para editar objeto
  Future<ObjectLost?> _showEditObjectDialog(
    BuildContext context,
    ObjectLost object,
  ) async {
    final nameController = TextEditingController(text: object.name);
    final descController = TextEditingController(text: object.description);
    final locationController = TextEditingController(text: object.location);
    DateTime foundDate = object.foundDate;

    return showDialog<ObjectLost>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF1565C0),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Editar Objeto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogTextField(
                      controller: nameController,
                      label: 'Nombre del objeto',
                      icon: Icons.label_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      controller: descController,
                      label: 'Descripción',
                      icon: Icons.description_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      controller: locationController,
                      label: 'Lugar encontrado',
                      icon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fecha encontrada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: foundDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF1565C0),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setStateDialog(() => foundDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF1565C0),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${foundDate.day.toString().padLeft(2, '0')}/${foundDate.month.toString().padLeft(2, '0')}/${foundDate.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(dialogContext);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El nombre es requerido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    final edited = ObjectLost(
                      id: object.id,
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                      location: locationController.text.trim(),
                      foundDate: foundDate,
                      imageUrl: object.imageUrl,
                      status: object.status,
                      userId: object.userId,
                      createdAt: object.createdAt,
                    );
                    Navigator.pop(dialogContext, edited);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Construye un campo de texto para diálogos
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF8F9FA) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 15,
          color: enabled ? const Color(0xFF2C3E50) : Colors.grey[600],
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? Colors.grey[600] : Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF1565C0) : Colors.grey[400],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  /// Diálogo para registrar entrega
  Future<Entrega?> _showEntregaDialog(
    BuildContext context,
    String objectId,
  ) async {
    // Obtener el nombreEncontradoPor de la base de datos
    final nombreEncontradoPor = await _viewModel.getNombreEncontradoPor(
      objectId,
    );
    final nombreEncontradoPorController = TextEditingController(
      text: nombreEncontradoPor,
    );
    final nombreDevueltoAController = TextEditingController();
    final codigoEstudianteController = TextEditingController();
    final observacionesController = TextEditingController();
    DateTime fechaEntrega = DateTime.now();

    return showDialog<Entrega>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Registrar Entrega',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogTextField(
                      controller: nombreEncontradoPorController,
                      label: 'Encontrado por',
                      icon: Icons.person_search_rounded,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      controller: nombreDevueltoAController,
                      label: 'Devuelto a',
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      controller: codigoEstudianteController,
                      label: 'Código estudiante',
                      icon: Icons.badge_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      controller: observacionesController,
                      label: 'Observaciones',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fecha de entrega',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fechaEntrega,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF4CAF50),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setStateDialog(() => fechaEntrega = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${fechaEntrega.day.toString().padLeft(2, '0')}/${fechaEntrega.month.toString().padLeft(2, '0')}/${fechaEntrega.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(dialogContext);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (nombreDevueltoAController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El nombre de quien recibe es requerido',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    final entrega = Entrega(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nombreEncontradoPor: nombreEncontradoPorController.text,
                      nombreDevueltoA: nombreDevueltoAController.text.trim(),
                      codigoEstudiante:
                          codigoEstudianteController.text.trim().isNotEmpty
                          ? codigoEstudianteController.text.trim()
                          : null,
                      fotoEntregaUrl: null,
                      fechaEntrega: fechaEntrega,
                      userId: AuthService.getCurrentUserId(),
                      observaciones:
                          observacionesController.text.trim().isNotEmpty
                          ? observacionesController.text.trim()
                          : null,
                    );
                    Navigator.pop(dialogContext, entrega);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
