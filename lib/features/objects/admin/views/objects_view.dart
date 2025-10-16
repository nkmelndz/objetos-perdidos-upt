import 'package:flutter/material.dart';
import '../viewmodels/objects_viewmodel.dart';
import '../../models/object_lost.dart';
import '../../models/entrega.dart';

class ObjectsView extends StatefulWidget {
  const ObjectsView({Key? key}) : super(key: key);

  @override
  State<ObjectsView> createState() => _ObjectsViewState();
}

class _ObjectsViewState extends State<ObjectsView> {
  final ObjectsViewModel _viewModel = ObjectsViewModel();
  ObjectStatus? _selectedFilter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar objeto...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<ObjectStatus?>(
                value: _selectedFilter,
                hint: const Text('Filtro'),
                items: [
                  const DropdownMenuItem<ObjectStatus?>(
                    value: null,
                    child: Text('Todos'),
                  ),
                  ...ObjectStatus.values.map(
                    (status) => DropdownMenuItem<ObjectStatus?>(
                      value: status,
                      child: Text(_statusText(status)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedFilter = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<ObjectLost>>(
              stream: _viewModel.objectsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var objects = snapshot.data ?? [];

                // aplicar búsqueda y filtro locales
                if (_search.isNotEmpty) {
                  objects = objects
                      .where(
                        (o) =>
                            o.name.toLowerCase().contains(_search.toLowerCase()) ||
                            o.description.toLowerCase().contains(_search.toLowerCase()) ||
                            o.location.toLowerCase().contains(_search.toLowerCase()),
                      )
                      .toList();
                }

                if (_selectedFilter != null) {
                  objects = objects.where((o) => o.status == _selectedFilter).toList();
                }

                if (objects.isEmpty) {
                  return const Center(child: Text('Sin objetos registrados'));
                }

                return ListView.builder(
                  itemCount: objects.length,
                  itemBuilder: (context, index) {
                    final obj = objects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: obj.imageUrl.isNotEmpty
                            ? Image.network(
                                obj.imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.image,
                                size: 48,
                                color: Color(0xFF003366),
                              ),
                        title: Text(obj.name),
                        subtitle: Text(
                          'Encontrado: ${_formatDate(obj.foundDate)}\n${obj.description}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(obj.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusText(obj.status),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Botón editar
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final edited =
                                    await _showEditObjectDialog(context, obj);
                                if (edited != null) {
                                  await _viewModel.updateObject(obj.id, edited);
                                }
                              },
                            ),

                            // Botón entrega
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed: obj.status == ObjectStatus.entregado
                                  ? null
                                  : () async {
                                      final entrega =
                                          await _showEntregaDialog(context);
                                      if (entrega != null) {
                                        await _viewModel.addEntrega(obj.id, entrega);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Diálogo para editar objeto
  Future<ObjectLost?> _showEditObjectDialog(
      BuildContext context, ObjectLost object) async {
    final nameController = TextEditingController(text: object.name);
    final descController = TextEditingController(text: object.description);
    final locationController = TextEditingController(text: object.location);
    DateTime foundDate = object.foundDate;

    return showDialog<ObjectLost>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar objeto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Lugar encontrado'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Fecha encontrada: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: foundDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => foundDate = picked);
                        }
                      },
                      child: Text(
                        '${foundDate.day.toString().padLeft(2, '0')}/${foundDate.month.toString().padLeft(2, '0')}/${foundDate.year}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final edited = ObjectLost(
                  id: object.id,
                  name: nameController.text,
                  description: descController.text,
                  location: locationController.text,
                  foundDate: foundDate,
                  imageUrl: object.imageUrl,
                  status: object.status,
                  adminId: object.adminId,
                  createdAt: object.createdAt,
                );
                Navigator.pop(context, edited);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  /// Diálogo para registrar entrega
  Future<Entrega?> _showEntregaDialog(BuildContext context) async {
    final nombreEncontradoPorController = TextEditingController();
    final nombreDevueltoAController = TextEditingController();
    final codigoEstudianteController = TextEditingController();
    final observacionesController = TextEditingController();
    DateTime fechaEntrega = DateTime.now();

    return showDialog<Entrega>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar entrega'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreEncontradoPorController,
                  decoration: const InputDecoration(labelText: 'Encontrado por'),
                ),
                TextField(
                  controller: nombreDevueltoAController,
                  decoration: const InputDecoration(labelText: 'Devuelto a'),
                ),
                TextField(
                  controller: codigoEstudianteController,
                  decoration: const InputDecoration(labelText: 'Código estudiante'),
                ),
                TextField(
                  controller: observacionesController,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Fecha: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fechaEntrega,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => fechaEntrega = picked);
                        }
                      },
                      child: Text(
                        '${fechaEntrega.day.toString().padLeft(2, '0')}/${fechaEntrega.month.toString().padLeft(2, '0')}/${fechaEntrega.year}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final entrega = Entrega(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nombreEncontradoPor: nombreEncontradoPorController.text,
                  nombreDevueltoA: nombreDevueltoAController.text,
                  codigoEstudiante: codigoEstudianteController.text,
                  fotoEntregaUrl: '',
                  fechaEntrega: fechaEntrega,
                  adminId: '',
                  observaciones: observacionesController.text,
                );
                Navigator.pop(context, entrega);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  /// Métodos auxiliares
  static String _statusText(ObjectStatus status) {
    switch (status) {
      case ObjectStatus.pendiente:
        return 'Pendiente';
      case ObjectStatus.entregado:
        return 'Entregado';
      case ObjectStatus.reclamado:
        return 'Reclamado';
    }
  }

  static Color _statusColor(ObjectStatus status) {
    switch (status) {
      case ObjectStatus.pendiente:
        return Colors.orange;
      case ObjectStatus.entregado:
        return Colors.green;
      case ObjectStatus.reclamado:
        return Colors.blueGrey;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
