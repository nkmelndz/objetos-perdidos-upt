import 'package:flutter/material.dart';
import '../models/object_lost.dart';
import '../utils/object_lost_utils.dart';
import '../admin/viewmodels/objects_viewmodel.dart';
import 'entrega_dialog.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _buildLeadingImage(),
        title: Text(object.name),
        subtitle: Text(
          'Encontrado: ${ObjectLostUtils.formatDate(object.foundDate)}\n${object.description}',
        ),
        trailing: _buildTrailingActions(context),
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (object.imageUrl.isNotEmpty) {
      return Image.network(
        object.imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      );
    }
    return const Icon(Icons.image, size: 48, color: Color(0xFF003366));
  }

  Widget _buildTrailingActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusBadge(),
        const SizedBox(width: 8),
        _buildEditButton(),
        _buildDeliveryButton(context),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ObjectLostUtils.statusToColor(object.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ObjectLostUtils.statusToText(object.status),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () {
        // TODO: Implementar edición
      },
    );
  }

  Widget _buildDeliveryButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.check_circle, color: Colors.green),
      onPressed: object.status == ObjectStatus.entregado
          ? null
          : () => _handleDelivery(context),
    );
  }

  Future<void> _handleDelivery(BuildContext context) async {
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
