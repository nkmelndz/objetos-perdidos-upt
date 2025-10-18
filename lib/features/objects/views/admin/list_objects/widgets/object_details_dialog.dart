import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/object_lost.dart';
import '../../../../models/entrega.dart';
import '../../../../utils/object_lost_utils.dart';

/// Muestra un diálogo con los detalles completos del objeto y su entrega
Future<void> showObjectDetailsDialog({
  required BuildContext context,
  required ObjectLost object,
  required Entrega? entrega,
}) async {
  return showDialog(
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
                        color: const Color(0xFF6A1B9A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.info_rounded,
                        color: Color(0xFF6A1B9A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detalles del Objeto',
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
                        // Información del objeto
                        _DetailSection(
                          title: 'Información del Objeto',
                          icon: Icons.inventory_2_rounded,
                          iconColor: const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Nombre',
                          value: object.name,
                          icon: Icons.label_rounded,
                        ),
                        _DetailRow(
                          label: 'Descripción',
                          value: object.description,
                          icon: Icons.description_rounded,
                        ),
                        _DetailRow(
                          label: 'Ubicación',
                          value: object.location,
                          icon: Icons.location_on_rounded,
                        ),
                        _DetailRow(
                          label: 'Fecha encontrado',
                          value: ObjectLostUtils.formatDate(object.foundDate),
                          icon: Icons.calendar_today_rounded,
                        ),
                        _DetailRow(
                          label: 'Estado',
                          value: ObjectLostUtils.statusToText(object.status),
                          icon: Icons.check_circle_rounded,
                          valueColor: ObjectLostUtils.statusToColor(
                            object.status,
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Información de entrega
                        _DetailSection(
                          title: 'Información de Entrega',
                          icon: Icons.assignment_turned_in_rounded,
                          iconColor: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 12),

                        if (entrega != null) ...[
                          _DetailRow(
                            label: 'Encontrado por',
                            value: entrega.nombreEncontradoPor,
                            icon: Icons.person_search_rounded,
                          ),
                          if (entrega.nombreDevueltoA != null &&
                              entrega.nombreDevueltoA!.isNotEmpty)
                            _DetailRow(
                              label: 'Devuelto a',
                              value: entrega.nombreDevueltoA!,
                              icon: Icons.person_rounded,
                            ),
                          if (entrega.codigoEstudiante != null &&
                              entrega.codigoEstudiante!.isNotEmpty)
                            _DetailRow(
                              label: 'Código estudiante',
                              value: entrega.codigoEstudiante!,
                              icon: Icons.badge_rounded,
                            ),
                          if (entrega.fechaEntrega != null)
                            _DetailRow(
                              label: 'Fecha entrega',
                              value: ObjectLostUtils.formatDate(
                                entrega.fechaEntrega!,
                              ),
                              icon: Icons.event_rounded,
                            ),
                          if (entrega.observaciones != null &&
                              entrega.observaciones!.isNotEmpty)
                            _DetailRow(
                              label: 'Observaciones',
                              value: entrega.observaciones!,
                              icon: Icons.notes_rounded,
                            ),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Sin información de entrega',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botón de cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Widget para mostrar una sección de detalles
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

/// Widget para mostrar una fila de detalle
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? const Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
