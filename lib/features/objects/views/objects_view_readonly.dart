import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../viewmodels/objects_viewmodel.dart';
import '../models/object_lost.dart';
import '../utils/object_lost_utils.dart';

class ObjectsViewReadOnly extends StatefulWidget {
  const ObjectsViewReadOnly({Key? key}) : super(key: key);

  @override
  State<ObjectsViewReadOnly> createState() => _ObjectsViewReadOnlyState();
}

class _ObjectsViewReadOnlyState extends State<ObjectsViewReadOnly>
    with TickerProviderStateMixin {
  final ObjectsViewModel _viewModel = ObjectsViewModel();
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

    // Iniciar animaciones
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0), // Azul suave
              Color(0xFF0277BD), // Azul medio
              Color(0xFFF8F9FA), // Blanco suave en la parte inferior
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header simplificado
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      // Botón de regreso solo ícono (sin fondo ni contorno)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                        splashRadius: 22,
                      ),
                      const SizedBox(width: 16),
                      // Título simplificado
                      Text(
                        'Objetos Perdidos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 26 : 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido principal
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Barra de búsqueda y filtros mejorados
                        Padding(
                          padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
                          child: Column(
                            children: [
                              // Campo de búsqueda
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE9ECEF),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar objeto perdido...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 15,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: const Color(0xFF1565C0),
                                      size: 22,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _viewModel.setSearch(value);
                                    setState(() {});
                                  },
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Filtros mejorados como segmented control
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildSegmentedButton(
                                        label: 'Todos',
                                        isSelected:
                                            _viewModel.currentFilter == null,
                                        onTap: () {
                                          _viewModel.setFilter(null);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildSegmentedButton(
                                        label: 'Encontrado',
                                        isSelected:
                                            _viewModel.currentFilter ==
                                            ObjectStatus.encontrado,
                                        onTap: () {
                                          _viewModel.setFilter(
                                            ObjectStatus.encontrado,
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildSegmentedButton(
                                        label: 'Entregado',
                                        isSelected:
                                            _viewModel.currentFilter ==
                                            ObjectStatus.entregado,
                                        onTap: () {
                                          _viewModel.setFilter(
                                            ObjectStatus.entregado,
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lista de objetos
                        Expanded(
                          child: StreamBuilder<List<ObjectLost>>(
                            stream: _viewModel.objectsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1565C0),
                                  ),
                                );
                              }

                              final objects = snapshot.data ?? [];

                              if (objects.isEmpty) {
                                return _buildEmptyState();
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 32.0 : 24.0,
                                  vertical: 8.0,
                                ),
                                physics: const BouncingScrollPhysics(),
                                itemCount: objects.length,
                                itemBuilder: (context, index) {
                                  final obj = objects[index];
                                  return _buildObjectCard(obj, index);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              color: isSelected ? const Color(0xFF1565C0) : Colors.grey[600],
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectCard(ObjectLost obj, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del card
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen o icono
                  Container(
                    width: 60,
                    height: 60,
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
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_rounded,
                            color: const Color(0xFF1565C0),
                            size: 30,
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
                        const SizedBox(height: 4),
                        Text(
                          obj.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
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

              const SizedBox(height: 16),

              // Footer del card
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
            ],
          ),
        ),
      ),
    );
  }

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
              'Intenta ajustar los filtros de búsqueda',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
