import 'package:flutter/material.dart';
import '../admin/viewmodels/objects_viewmodel.dart';
import '../models/object_lost.dart';

class ObjectsViewReadOnly extends StatefulWidget {
  const ObjectsViewReadOnly({Key? key}) : super(key: key);

  @override
  State<ObjectsViewReadOnly> createState() => _ObjectsViewReadOnlyState();
}

class _ObjectsViewReadOnlyState extends State<ObjectsViewReadOnly> {
  final ObjectsViewModel _viewModel = ObjectsViewModel();
  ObjectStatus? _selectedFilter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetos Perdidos'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
                              o.name.toLowerCase().contains(
                                _search.toLowerCase(),
                              ) ||
                              o.description.toLowerCase().contains(
                                _search.toLowerCase(),
                              ) ||
                              o.location.toLowerCase().contains(
                                _search.toLowerCase(),
                              ),
                        )
                        .toList();
                  }
                  if (_selectedFilter != null) {
                    objects = objects
                        .where((o) => o.status == _selectedFilter)
                        .toList();
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
                          trailing: Container(
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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