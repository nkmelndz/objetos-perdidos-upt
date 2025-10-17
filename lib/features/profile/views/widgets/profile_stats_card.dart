import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int objectsFound;
  final int objectsClaimed;
  final int daysActive;
  final bool isTablet;

  const ProfileStatsCard({
    Key? key,
    required this.objectsFound,
    required this.objectsClaimed,
    required this.daysActive,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1565C0).withOpacity(0.1),
            const Color(0xFF0277BD).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            icon: Icons.inventory_2_rounded,
            label: 'Encontrados',
            value: objectsFound.toString(),
            color: const Color(0xFF1565C0),
          ),
          _buildDivider(),
          _buildStat(
            icon: Icons.check_circle_rounded,
            label: 'Entregados',
            value: objectsClaimed.toString(),
            color: const Color(0xFF4CAF50),
          ),
          _buildDivider(),
          _buildStat(
            icon: Icons.calendar_today_rounded,
            label: 'Días activo',
            value: daysActive.toString(),
            color: const Color(0xFFFF6F00),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 60,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
