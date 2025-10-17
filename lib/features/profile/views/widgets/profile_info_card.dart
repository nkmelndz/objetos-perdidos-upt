import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final bool isEditing;
  final bool isTablet;

  const ProfileInfoCard({
    Key? key,
    required this.nameController,
    required this.phoneController,
    required this.bioController,
    required this.isEditing,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoItem(
          icon: Icons.person_rounded,
          label: 'Nombre completo',
          controller: nameController,
          enabled: isEditing,
          iconColor: const Color(0xFF1565C0),
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          icon: Icons.phone_rounded,
          label: 'Teléfono',
          controller: phoneController,
          enabled: isEditing,
          iconColor: const Color(0xFF4CAF50),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          icon: Icons.description_rounded,
          label: 'Biografía',
          controller: bioController,
          enabled: isEditing,
          iconColor: const Color(0xFF6A1B9A),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required Color iconColor,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? iconColor.withOpacity(0.3) : Colors.grey[200]!,
          width: enabled ? 2 : 1.5,
        ),
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
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 15,
          color: enabled ? const Color(0xFF2C3E50) : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? iconColor : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          suffixIcon: enabled
              ? Icon(Icons.edit_rounded, color: iconColor, size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 18 : 20,
          ),
        ),
      ),
    );
  }
}
