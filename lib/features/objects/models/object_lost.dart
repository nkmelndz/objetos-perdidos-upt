
class ObjectLost {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime foundDate;
  final String imageUrl;
  final ObjectStatus status;
  final String userId;
  final DateTime createdAt;

  ObjectLost({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.foundDate,
    required this.imageUrl,
    required this.status,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'nombre': name,
    'descripcion': description,
    'lugar_encontrado': location,
    'fecha_encontrado': foundDate.toIso8601String(),
    'imagen_url': imageUrl,
    'estado': _statusToString(status),
    'id_user': userId,
    'fecha_registro': createdAt.toIso8601String(),
  };

  factory ObjectLost.fromMap(String id, Map<String, dynamic> map) {
    return ObjectLost(
      id: id,
      name: (map['nombre'] ?? '') as String,
      description: (map['descripcion'] ?? '') as String,
      location: (map['lugar_encontrado'] ?? '') as String,
      foundDate:
          DateTime.tryParse(map['fecha_encontrado'] ?? '') ?? DateTime.now(),
      imageUrl: (map['imagen_url'] ?? '') as String,
      status: _statusFromString(map['estado'] ?? 'encontrado'),
      userId: (map['id_user'] ?? '') as String,
      createdAt:
          DateTime.tryParse(map['fecha_registro'] ?? '') ?? DateTime.now(),
    );
  }
}

enum ObjectStatus { encontrado, entregado }

String _statusToString(ObjectStatus status) {
  switch (status) {
    case ObjectStatus.encontrado:
      return 'encontrado';
    case ObjectStatus.entregado:
      return 'entregado';
  }
}

ObjectStatus _statusFromString(String value) {
  switch (value) {
    case 'entregado':
      return ObjectStatus.entregado;
    case 'encontrado':
      return ObjectStatus.encontrado;
    case 'pendiente':
    default:
      // Backward compatibility: previously stored as 'pendiente'
      return ObjectStatus.encontrado;
  }
}
