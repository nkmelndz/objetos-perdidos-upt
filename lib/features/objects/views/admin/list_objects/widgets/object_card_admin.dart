import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/object_lost.dart';
import '../../../../utils/object_lost_utils.dart';
import '../../../../viewmodels/objects_viewmodel.dart';
import 'object_details_dialog.dart';
import 'entrega_dialog.dart';
import 'edit_object_dialog.dart';

/// Tarjeta de objeto para la vista de administración
class ObjectCardAdmin extends StatelessWidget {
  final ObjectLost object;
  final ObjectsViewModel viewModel;

  const ObjectCardAdmin({
    Key? key,
    required this.object,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                _buildImage(),
                const SizedBox(width: 16),
                // Información principal
                Expanded(child: _buildInfo()),
                // Estado
                _buildStatus(),
              ],
            ),
            const SizedBox(height: 12),
            // Información adicional
            _buildAdditionalInfo(),
            const SizedBox(height: 12),
            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Construye la imagen o icono del objeto
  Widget _buildImage() {
    return Container(
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
      child: object.imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                object.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.inventory_2_rounded,
                    color: Color(0xFF1565C0),
                    size: 32,
                  );
                },
              ),
            )
          : const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFF1565C0),
              size: 32,
            ),
    );
  }

  /// Construye la información principal
  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          object.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          object.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.3),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Construye el badge de estado y categoría
  Widget _buildStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ObjectLostUtils.statusToColor(
              object.status,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ObjectLostUtils.statusToColor(
                object.status,
              ).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            ObjectLostUtils.statusToText(object.status),
            style: TextStyle(
              color: ObjectLostUtils.statusToColor(object.status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category_rounded,
                color: const Color(0xFF1565C0),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                ObjectLostUtils.categoryToText(object.category),
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF1565C0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye la información adicional (ubicación y fecha)
  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: Color(0xFF1565C0),
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              object.location,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.calendar_today_rounded,
            color: Color(0xFF1565C0),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            ObjectLostUtils.formatDate(object.foundDate),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: object.status == ObjectStatus.entregado
                ? Icons.visibility_rounded
                : Icons.edit_rounded,
            label: object.status == ObjectStatus.entregado
                ? 'Ver detalles'
                : 'Editar',
            color: object.status == ObjectStatus.entregado
                ? const Color(0xFF6A1B9A)
                : const Color(0xFF1565C0),
            onTap: () => _handleEditOrViewDetails(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.check_circle_rounded,
            label: object.status == ObjectStatus.entregado
                ? 'Entregado'
                : 'Entregar',
            color: object.status == ObjectStatus.entregado
                ? Colors.grey
                : const Color(0xFF4CAF50),
            onTap: object.status == ObjectStatus.entregado
                ? null
                : () => _handleEntrega(context),
          ),
        ),
      ],
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

  /// Maneja la acción de editar o ver detalles
  Future<void> _handleEditOrViewDetails(BuildContext context) async {
    HapticFeedback.lightImpact();
    if (object.status == ObjectStatus.entregado) {
      // Obtener datos de entrega
      final entrega = await viewModel.getEntregaByObjectId(object.id);
      if (context.mounted) {
        await showObjectDetailsDialog(
          context: context,
          object: object,
          entrega: entrega,
        );
      }
    } else {
      final edited = await showEditObjectDialog(
        context: context,
        object: object,
      );
      if (edited != null) {
        await viewModel.updateObject(object.id, edited);
      }
    }
  }

  /// Maneja la acción de registrar entrega
  Future<void> _handleEntrega(BuildContext context) async {
    HapticFeedback.lightImpact();
    final entrega = await showEntregaDialog(
      context: context,
      objectId: object.id,
      viewModel: viewModel,
    );
    if (entrega != null) {
      await viewModel.addEntrega(object.id, entrega);
    }
  }
}
