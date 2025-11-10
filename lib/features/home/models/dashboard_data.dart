import '../../objects/models/object_lost.dart';

/// Modelo que encapsula todos los datos necesarios para el dashboard
class DashboardData {
  final String userName;
  final List<ObjectLost> allObjects;
  final List<ObjectLost> recentObjects;
  final int totalCount;
  final int deliveredCount;
  final int pendingCount;

  DashboardData({
    required this.userName,
    required this.allObjects,
    required this.recentObjects,
    required this.totalCount,
    required this.deliveredCount,
    required this.pendingCount,
  });

  /// Constructor vacío para estado inicial
  factory DashboardData.empty() {
    return DashboardData(
      userName: 'Admin',
      allObjects: [],
      recentObjects: [],
      totalCount: 0,
      deliveredCount: 0,
      pendingCount: 0,
    );
  }

  /// Crea una instancia con datos calculados
  factory DashboardData.fromObjects({
    required String userName,
    required List<ObjectLost> objects,
    int recentLimit = 5,
  }) {
    final delivered = objects
        .where((o) => o.status == ObjectStatus.entregado)
        .length;
    final pending = objects
      .where((o) => o.status == ObjectStatus.encontrado)
        .length;
    final recent = objects.take(recentLimit).toList();

    return DashboardData(
      userName: userName,
      allObjects: objects,
      recentObjects: recent,
      totalCount: objects.length,
      deliveredCount: delivered,
      pendingCount: pending,
    );
  }

  bool get isEmpty => allObjects.isEmpty;
}
