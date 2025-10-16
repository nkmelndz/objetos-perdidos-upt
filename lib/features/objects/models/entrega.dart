class Entrega {
  final String id;
  final String nombreEncontradoPor;
  final String nombreDevueltoA;
  final String codigoEstudiante;
  final String fotoEntregaUrl;
  final DateTime fechaEntrega;
  final String adminId;
  final String observaciones;

  Entrega({
    required this.id,
    required this.nombreEncontradoPor,
    required this.nombreDevueltoA,
    required this.codigoEstudiante,
    required this.fotoEntregaUrl,
    required this.fechaEntrega,
    required this.adminId,
    required this.observaciones,
  });

  Map<String, dynamic> toMap() => {
    'nombre_encontrado_por': nombreEncontradoPor,
    'nombre_devuelto_a': nombreDevueltoA,
    'codigo_estudiante': codigoEstudiante,
    'foto_entrega_url': fotoEntregaUrl,
    'fecha_entrega': fechaEntrega.toIso8601String(),
    'id_admin': adminId,
    'observaciones': observaciones,
  };
}
