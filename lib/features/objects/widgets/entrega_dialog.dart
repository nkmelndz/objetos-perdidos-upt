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
      return AlertDialog(
        title: const Text('Registrar entrega'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreEncontradoPorController,
                decoration: const InputDecoration(labelText: 'Encontrado por'),
                enabled: false,
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextField(
                controller: nombreDevueltoAController,
                decoration: const InputDecoration(labelText: 'Devuelto a'),
              ),
              TextField(
                controller: codigoEstudianteController,
                decoration: const InputDecoration(
                  labelText: 'Código estudiante',
                ),
              ),
              TextField(
                controller: observacionesController,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 8),
              _DatePickerRow(
                fechaEntrega: fechaEntrega,
                onDateChanged: (newDate) => fechaEntrega = newDate,
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
                nombreDevueltoA: nombreDevueltoAController.text.isNotEmpty
                    ? nombreDevueltoAController.text
                    : null,
                codigoEstudiante: codigoEstudianteController.text.isNotEmpty
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
            child: const Text('Guardar'),
          ),
        ],
      );
    },
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
    return Row(
      children: [
        const Text('Fecha: '),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
              widget.onDateChanged(picked);
            }
          },
          child: Text(
            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
          ),
        ),
      ],
    );
  }
}
