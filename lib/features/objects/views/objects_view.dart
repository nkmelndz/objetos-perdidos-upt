import 'package:flutter/material.dart';
import '../admin/viewmodels/objects_viewmodel.dart';
import '../models/object_lost.dart';
import '../utils/object_lost_utils.dart';
import '../widgets/object_card_widget.dart';

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
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          Expanded(child: _buildObjectsList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
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
                child: Text(ObjectLostUtils.statusToText(status)),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _selectedFilter = value),
        ),
      ],
    );
  }

  Widget _buildObjectsList() {
    return StreamBuilder<List<ObjectLost>>(
      stream: _viewModel.objectsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final objects = _getFilteredObjects(snapshot.data ?? []);

        if (objects.isEmpty) {
          return const Center(child: Text('Sin objetos registrados'));
        }

        return ListView.builder(
          itemCount: objects.length,
          itemBuilder: (context, index) {
            return ObjectCardWidget(
              object: objects[index],
              viewModel: _viewModel,
            );
          },
        );
      },
    );
  }

  List<ObjectLost> _getFilteredObjects(List<ObjectLost> objects) {
    var filtered = objects;

    // Aplicar búsqueda
    if (_search.isNotEmpty) {
      filtered = filtered
          .where(
            (o) =>
                o.name.toLowerCase().contains(_search.toLowerCase()) ||
                o.description.toLowerCase().contains(_search.toLowerCase()) ||
                o.location.toLowerCase().contains(_search.toLowerCase()),
          )
          .toList();
    }

    // Aplicar filtro de estado
    if (_selectedFilter != null) {
      filtered = filtered.where((o) => o.status == _selectedFilter).toList();
    }

    return filtered;
  }
}
