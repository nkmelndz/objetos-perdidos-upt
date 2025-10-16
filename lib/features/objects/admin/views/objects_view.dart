import 'package:flutter/material.dart';

class ObjectsView extends StatelessWidget {
  const ObjectsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.list, size: 80, color: Color(0xFF003366)),
          SizedBox(height: 24),
          Text(
            'Listado de objetos',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Aquí irá el listado y gestión de objetos perdidos.'),
        ],
      ),
    );
  }
}
