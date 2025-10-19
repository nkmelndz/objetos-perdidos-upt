import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/entrega.dart';
import '../../../../viewmodels/objects_viewmodel.dart';
import '../../../../../../services/auth_service.dart';

/// Muestra un diálogo para registrar la entrega de un objeto
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
    builder: (dialogContext) {
      final screenWidth = MediaQuery.of(dialogContext).size.width;
      final dialogWidth = screenWidth * 0.85; // 85% del ancho de la pantalla

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: dialogWidth,
          constraints: const BoxConstraints(
            maxWidth: 900, // Ancho máximo del diálogo
            maxHeight: 700, // Altura máxima
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_rounded,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Registrar Entrega',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Contenido
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de información
                        _DetailSection(
                          title: 'Información de Entrega',
                          icon: Icons.info_rounded,
                          iconColor: const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 16),
                        // Campos del formulario
                        _FormField(
                          controller: nombreEncontradoPorController,
                          label: 'Encontrado por',
                          icon: Icons.person_search_rounded,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: nombreDevueltoAController,
                          label: 'Devuelto a',
                          icon: Icons.person_rounded,
                          hint: 'Nombre completo del propietario',
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: codigoEstudianteController,
                          label: 'Código estudiante',
                          icon: Icons.badge_rounded,
                          hint: 'Código UPT (opcional)',
                        ),
                        const SizedBox(height: 16),
                        _DatePickerField(
                          fechaEntrega: fechaEntrega,
                          onDateChanged: (newDate) => fechaEntrega = newDate,
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: observacionesController,
                          label: 'Observaciones',
                          icon: Icons.notes_rounded,
                          hint: 'Detalles adicionales (opcional)',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6A1B9A),
                          side: const BorderSide(
                            color: Color(0xFF6A1B9A),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          final entrega = Entrega(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            nombreEncontradoPor:
                                nombreEncontradoPorController.text,
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
                            observaciones:
                                observacionesController.text.isNotEmpty
                                ? observacionesController.text
                                : null,
                          );
                          Navigator.pop(dialogContext, entrega);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Guardar entrega',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Widget para mostrar una sección de título
class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar un campo de formulario
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool enabled;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: enabled ? const Color(0xFF4CAF50) : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(
            color: enabled ? const Color(0xFF2C3E50) : Colors.grey[600],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
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
              borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para seleccionar fecha
class _DatePickerField extends StatefulWidget {
  final DateTime fechaEntrega;
  final Function(DateTime) onDateChanged;

  const _DatePickerField({
    required this.fechaEntrega,
    required this.onDateChanged,
  });

  @override
  State<_DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<_DatePickerField> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.fechaEntrega;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_rounded, color: Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 8),
            Text(
              'Fecha de entrega',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4CAF50),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF2C3E50),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
