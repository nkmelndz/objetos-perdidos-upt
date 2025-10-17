import 'package:flutter/material.dart';
import '../models/entrega.dart';
import '../admin/viewmodels/objects_viewmodel.dart';
import '../../../services/auth_service.dart';

Future<Entrega?> showEntregaDialog({
  required BuildContext context,
  required String objectId,
  required ObjectsViewModel viewModel,
}) async {
  final nombreEncontradoPor = await viewModel.getNombreEncontradoPor(objectId);
  final nombreEncontradoPorController = TextEditingController(
    text: nombreEncontradoPor,
  );
  final nombreDevueltoAController = TextEditingController();
  final codigoEstudianteController = TextEditingController();
  final observacionesController = TextEditingController();
  DateTime fechaEntrega = DateTime.now();

  return showDialog<Entrega>(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.075,
          vertical: 24,
        ),
        child: Container(
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Registrar entrega',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: nombreEncontradoPorController,
                        label: 'Encontrado por',
                        icon: Icons.person,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: nombreDevueltoAController,
                        label: 'Devuelto a',
                        icon: Icons.person_outline,
                        hint: 'Nombre completo del propietario',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: codigoEstudianteController,
                        label: 'Código estudiante',
                        icon: Icons.badge,
                        hint: 'Código UPT (opcional)',
                      ),
                      const SizedBox(height: 16),
                      _DatePickerRow(
                        fechaEntrega: fechaEntrega,
                        onDateChanged: (newDate) => fechaEntrega = newDate,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: observacionesController,
                        label: 'Observaciones',
                        icon: Icons.notes,
                        hint: 'Detalles adicionales (opcional)',
                        maxLines: 3,
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
                      final entrega = Entrega(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombreEncontradoPor: nombreEncontradoPorController.text,
                        nombreDevueltoA:
                            nombreDevueltoAController.text.isNotEmpty
                            ? nombreDevueltoAController.text
                            : null,
                        codigoEstudiante:
                            codigoEstudianteController.text.isNotEmpty
                            ? codigoEstudianteController.text
                            : null,
                        fotoEntregaUrl: null,
                        fechaEntrega: fechaEntrega,
                        userId: AuthService.getCurrentUserId(),
                        observaciones: observacionesController.text.isNotEmpty
                            ? observacionesController.text
                            : null,
                      );
                      Navigator.pop(context, entrega);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Guardar entrega',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
  bool enabled = true,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    enabled: enabled,
    maxLines: maxLines,
    style: TextStyle(
      color: enabled ? Colors.black : Colors.grey[600],
      fontSize: 16,
    ),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: enabled ? Colors.green : Colors.grey),
      filled: true,
      fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
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
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

class _DatePickerRow extends StatefulWidget {
  final DateTime fechaEntrega;
  final Function(DateTime) onDateChanged;

  const _DatePickerRow({
    required this.fechaEntrega,
    required this.onDateChanged,
  });

  @override
  State<_DatePickerRow> createState() => _DatePickerRowState();
}

class _DatePickerRowState extends State<_DatePickerRow> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.fechaEntrega;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.green,
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
          setState(() => _selectedDate = picked);
          widget.onDateChanged(picked);
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
            const Icon(Icons.calendar_today, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de entrega',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
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
}
