import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/object_lost_utils.dart';

class AddObjectForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController locationController;
  final TextEditingController encontradoPorController;
  final DateTime selectedDate;
  final FocusNode nameFocus;
  final FocusNode descFocus;
  final FocusNode locationFocus;
  final FocusNode encontradoPorFocus;
  final Function(DateTime) onDateSelected;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const AddObjectForm({
    Key? key,
    required this.nameController,
    required this.descController,
    required this.locationController,
    required this.encontradoPorController,
    required this.selectedDate,
    required this.nameFocus,
    required this.descFocus,
    required this.locationFocus,
    required this.encontradoPorFocus,
    required this.onDateSelected,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(
          icon: Icons.info_outline_rounded,
          title: 'Información del objeto',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: nameController,
          focusNode: nameFocus,
          label: 'Nombre del objeto',
          icon: Icons.inventory_2_rounded,
          hint: 'Ej: Celular Samsung, Mochila azul',
          onSubmitted: (_) => descFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: descController,
          focusNode: descFocus,
          label: 'Descripción detallada (Opcional)',
          icon: Icons.description_rounded,
          hint: 'Describe características del objeto',
          maxLines: 4,
          onSubmitted: (_) => locationFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _buildCategorySelector(context),
        const SizedBox(height: 32),
        _buildSectionTitle(
          icon: Icons.place_outlined,
          title: 'Ubicación y registro',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: locationController,
          focusNode: locationFocus,
          label: 'Lugar encontrado',
          icon: Icons.location_on_rounded,
          hint: 'Ej: Biblioteca, Lab C, Cafetería',
          onSubmitted: (_) => encontradoPorFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: encontradoPorController,
          focusNode: encontradoPorFocus,
          label: 'Encontrado por',
          icon: Icons.person_rounded,
          hint: 'Nombre completo',
          onSubmitted: (_) => encontradoPorFocus.unfocus(),
        ),
        const SizedBox(height: 16),
        _buildDatePicker(context),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.category_rounded,
                color: Color(0xFF1565C0),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.list_rounded, color: Colors.grey[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ObjectLostUtils.categoryKeys.contains(selectedCategory)
                        ? selectedCategory
                        : 'otros',
                    isExpanded: true,
                    items: ObjectLostUtils.categoryKeys
                        .map(
                          (key) => DropdownMenuItem<String>(
                            value: key,
                            child: Text(
                              ObjectLostUtils.categoryToText(key),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        HapticFeedback.selectionClick();
                        onCategorySelected(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFFFC107), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
  }) {
    Color iconColor;
    switch (icon) {
      case Icons.inventory_2_rounded:
        iconColor = const Color(0xFF1565C0);
        break;
      case Icons.description_rounded:
        iconColor = const Color(0xFF6A1B9A);
        break;
      case Icons.location_on_rounded:
        iconColor = const Color(0xFFE91E63);
        break;
      case Icons.person_rounded:
        iconColor = const Color(0xFF00897B);
        break;
      default:
        iconColor = const Color(0xFF1565C0);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        textInputAction: maxLines > 1
            ? TextInputAction.newline
            : TextInputAction.next,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        HapticFeedback.selectionClick();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFFF6F00),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6F00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFFFF6F00),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha encontrado',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_calendar_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
