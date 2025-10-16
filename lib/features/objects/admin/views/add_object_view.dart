import 'package:flutter/material.dart';

class AddObjectView extends StatelessWidget {
  const AddObjectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_box, size: 80, color: Color(0xFF003366)),
          SizedBox(height: 24),
          Text(
            'Agregar objeto',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text('Aquí irá el formulario para agregar un objeto perdido.'),
        ],
      ),
    );
  }
}
