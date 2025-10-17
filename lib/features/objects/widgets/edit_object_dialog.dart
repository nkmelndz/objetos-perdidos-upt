import 'package:flutter/material.dart';
import '../models/object_lost.dart';

Future<Map<String, dynamic>?> showEditObjectDialog({
  required BuildContext context,
  required ObjectLost object,
}) async {
  final nameController = TextEditingController(text: object.name);
  final descriptionController = TextEditingController(text: object.description);
  final locationController = TextEditingController(text: object.location);
  DateTime foundDate = object.foundDate;
  ObjectStatus selectedStatus = object.status;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.075,
          vertical: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Editar objeto',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: nameController,
                            label: 'Nombre del objeto',
                            icon: Icons.inventory_2,
                            hint: 'Ej: Celular Samsung',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: descriptionController,
                            label: 'Descripción',
                            icon: Icons.description,
                            hint: 'Detalles del objeto encontrado',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: locationController,
                            label: 'Lugar encontrado',
                            icon: Icons.location_on,
                            hint: 'Ej: Biblioteca, Laboratorio 3',
                          ),
                          const SizedBox(height: 16),
                          _buildDatePicker(
                            context: context,
                            selectedDate: foundDate,
                            onDateChanged: (newDate) {
                              setState(() => foundDate = newDate);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildStatusDropdown(
                            selectedStatus: selectedStatus,
                            onChanged: (newStatus) {
                              setState(() => selectedStatus = newStatus!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (nameController.text.isEmpty ||
                              descriptionController.text.isEmpty ||
                              locationController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor completa todos los campos',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final result = {
                            'name': nameController.text,
                            'description': descriptionController.text,
                            'location': locationController.text,
                            'foundDate': foundDate,
                            'status': selectedStatus,
                          };
                          Navigator.pop(context, result);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Guardar cambios',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? hint,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

Widget _buildDatePicker({
  required BuildContext context,
  required DateTime selectedDate,
  required Function(DateTime) onDateChanged,
}) {
  return InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
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
        onDateChanged(picked);
      }
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha encontrado',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.edit_calendar, color: Colors.grey[400], size: 20),
        ],
      ),
    ),
  );
}

Widget _buildStatusDropdown({
  required ObjectStatus selectedStatus,
  required Function(ObjectStatus?) onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ObjectStatus>(
              value: selectedStatus,
              isExpanded: true,
              items: ObjectStatus.values.map((status) {
                return DropdownMenuItem<ObjectStatus>(
                  value: status,
                  child: Text(
                    _statusToText(status),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    ),
  );
}

String _statusToText(ObjectStatus status) {
  switch (status) {
    case ObjectStatus.pendiente:
      return 'Pendiente';
    case ObjectStatus.entregado:
      return 'Entregado';
  }
}
