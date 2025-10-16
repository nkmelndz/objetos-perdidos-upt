import 'package:flutter/material.dart';
import '../../objects/admin/views/objects_view.dart';
import '../../objects/admin/views/add_object_view.dart';
import '../../profile/views/profile_view.dart';
import '../viewmodels/home_dashboard_viewmodel.dart';
import '../../objects/models/object_lost.dart';


class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomeContent(onTabChange: _onItemTapped),
      ObjectsView(),
      AddObjectView(),
      ProfileView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF003366),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Objetos'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Objetos';
      case 2:
        return 'Agregar objeto';
      case 3:
        return 'Perfil';
      default:
        return '';
    }
  }
}


class _HomeContent extends StatelessWidget {
  final void Function(int) onTabChange;
  const _HomeContent({required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final viewModel = HomeDashboardViewModel();
    return StreamBuilder<List<ObjectLost>>(
      stream: viewModel.getObjects(),
      builder: (context, snapshot) {
        final objects = snapshot.data ?? <ObjectLost>[];
        final total = objects.length;
        final entregados = objects.where((o) => o.status == ObjectStatus.entregado).length;
        final pendientes = objects.where((o) => o.status == ObjectStatus.pendiente).length;
        final ultimos = objects.take(5).toList();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hola, Admin Juan 👋',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ResumenCard(
                    icon: Icons.inventory_2,
                    label: 'Objetos',
                    value: total.toString(),
                    color: Color(0xFF003366),
                  ),
                  _ResumenCard(
                    icon: Icons.check_circle,
                    label: 'Entregados',
                    value: entregados.toString(),
                    color: Colors.green,
                  ),
                  _ResumenCard(
                    icon: Icons.hourglass_top,
                    label: 'Pendientes',
                    value: pendientes.toString(),
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Últimos objetos registrados:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...ultimos.map((o) => ListTile(
                    leading: const Icon(Icons.label_outline, color: Color(0xFF003366)),
                    title: Text(o.name),
                    subtitle: Text(_formatDate(o.foundDate)),
                  )),
              if (ultimos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No hay objetos registrados.'),
                ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: Color(0xFF003366),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () => onTabChange(2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: const [
                              Icon(Icons.add, color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text('Registrar nuevo objeto', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => onTabChange(1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Column(
                            children: const [
                              Icon(Icons.list, color: Color(0xFF003366), size: 32),
                              SizedBox(height: 8),
                              Text('Ver lista completa', style: TextStyle(color: Color(0xFF003366))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _ResumenCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}
