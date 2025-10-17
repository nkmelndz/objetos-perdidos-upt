import 'package:flutter/material.dart';
import '../viewmodels/add_object_viewmodel.dart';
import '../../models/object_lost.dart';
import '../../../../services/auth_service.dart';

class AddObjectView extends StatefulWidget {
  const AddObjectView({Key? key}) : super(key: key);

  @override
  State<AddObjectView> createState() => _AddObjectViewState();
}

class _AddObjectViewState extends State<AddObjectView> {
  final AddObjectViewModel _viewModel = AddObjectViewModel();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _encontradoPorController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // Aquí iría la lógica para subir/tomar foto
            },
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey[200],
              backgroundImage: _imageUrl.isNotEmpty
                  ? NetworkImage(_imageUrl)
                  : null,
              child: _imageUrl.isEmpty
                  ? const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Color(0xFF003366),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del objeto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Descripción breve',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Lugar encontrado',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _encontradoPorController,
            decoration: const InputDecoration(
              labelText: 'Encontrado por',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Fecha encontrada: '),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Registrar objeto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                // Validar formulario
                final validation = _viewModel.validateFormData(
                  _nameController.text,
                  _descController.text,
                  _locationController.text,
                  _encontradoPorController.text,
                );
                
                if (validation != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(validation),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validar fecha
                final dateValidation = _viewModel.validateFoundDate(_selectedDate);
                if (dateValidation != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(dateValidation),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

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

                  await _viewModel.addObjectAndEntrega(object, _encontradoPorController.text.trim());

                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Objeto registrado'),
                        content: const Text(
                          'El objeto ha sido registrado correctamente.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _encontradoPorController.dispose();
    super.dispose();
  }
}