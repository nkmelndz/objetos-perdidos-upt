class AdminProfile {
  final String name;
  final String email;

  AdminProfile({required this.name, required this.email});
}

// Simulación de datos de admin (en un caso real, obtendría de auth o base de datos)
final adminProfile = AdminProfile(
  name: 'Juan Pérez',
  email: 'admin@upt.edu.pe',
);
