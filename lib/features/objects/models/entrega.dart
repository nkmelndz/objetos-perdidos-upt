class Entrega {
  final String id;
  final String nombreEncontradoPor;
  final String? nombreDevueltoA;
  final String? codigoEstudiante;
  final String? fotoEntregaUrl;
  final DateTime? fechaEntrega;
  final String? adminId;
  final String? observaciones;

  Entrega({
    required this.id,
    required this.nombreEncontradoPor,
    this.nombreDevueltoA,
    this.codigoEstudiante,
    this.fotoEntregaUrl,
    this.fechaEntrega,
    this.adminId,
    this.observaciones,
  });

  // Constructor para entrega inicial (solo con nombreEncontradoPor)
  Entrega.inicial({
    required this.nombreEncontradoPor,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(),
       nombreDevueltoA = null,
       codigoEstudiante = null,
       fotoEntregaUrl = null,
       fechaEntrega = null,
       adminId = null,
       observaciones = null;

  Map<String, dynamic> toMap() => {
    'nombre_encontrado_por': nombreEncontradoPor,
    'nombre_devuelto_a': nombreDevueltoA ?? '',
    'codigo_estudiante': codigoEstudiante ?? '',
    'foto_entrega_url': fotoEntregaUrl ?? '',
    'fecha_entrega': fechaEntrega?.toIso8601String() ?? '',
    'id_admin': adminId ?? '',
    'observaciones': observaciones ?? '',
  };

  factory Entrega.fromMap(String id, Map<String, dynamic> map) {
    return Entrega(
      id: id,
      nombreEncontradoPor: (map['nombre_encontrado_por'] ?? '') as String,
      nombreDevueltoA: map['nombre_devuelto_a']?.isEmpty == true ? null : map['nombre_devuelto_a'] as String?,
      codigoEstudiante: map['codigo_estudiante']?.isEmpty == true ? null : map['codigo_estudiante'] as String?,
      fotoEntregaUrl: map['foto_entrega_url']?.isEmpty == true ? null : map['foto_entrega_url'] as String?,
      fechaEntrega: map['fecha_entrega']?.isEmpty == true ? null : DateTime.tryParse(map['fecha_entrega'] ?? ''),
      adminId: map['id_admin']?.isEmpty == true ? null : map['id_admin'] as String?,
      observaciones: map['observaciones']?.isEmpty == true ? null : map['observaciones'] as String?,
    );
  }
}
