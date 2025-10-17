import 'package:flutter/material.dart';
import '../models/object_lost.dart';
import '../utils/object_lost_utils.dart';
import '../admin/viewmodels/objects_viewmodel.dart';
import 'entrega_dialog.dart';
import 'edit_object_dialog.dart';

class ObjectCardWidget extends StatelessWidget {
  final ObjectLost object;
  final ObjectsViewModel viewModel;

  const ObjectCardWidget({
    Key? key,
    required this.object,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingImage(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        object.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Encontrado: ${ObjectLostUtils.formatDate(object.foundDate)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        object.description,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusBadge(),
                const Spacer(),
                _buildActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (object.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          object.imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF003366).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image, size: 40, color: Color(0xFF003366)),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ObjectLostUtils.statusToColor(object.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        ObjectLostUtils.statusToText(object.status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () => _handleEdit(context),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Editar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: object.status == ObjectStatus.entregado
              ? null
              : () => _handleDelivery(context),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Entregar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    final result = await showEditObjectDialog(context: context, object: object);

    if (result != null) {
      final updatedObject = ObjectLost(
        id: object.id,
        name: result['name'],
        description: result['description'],
        location: result['location'],
        foundDate: result['foundDate'],
        imageUrl: object.imageUrl,
        status: result['status'],
        userId: object.userId,
        createdAt: object.createdAt,
      );

      await viewModel.updateObject(object.id, updatedObject);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objeto actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleDelivery(BuildContext context) async {
    final entrega = await showEntregaDialog(
      context: context,
      objectId: object.id,
      viewModel: viewModel,
    );

    if (entrega != null) {
      await viewModel.addEntrega(object.id, entrega);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Objeto entregado correctamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
