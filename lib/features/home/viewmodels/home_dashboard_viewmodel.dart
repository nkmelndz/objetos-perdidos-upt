import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../objects/models/object_lost.dart';

class HomeDashboardViewModel {
  final _db = FirebaseFirestore.instance;

  Stream<List<ObjectLost>> getObjects() {
    return _db
        .collection('objetos_perdidos')
        .orderBy('fecha_registro', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ObjectLost.fromMap(d.id, d.data())).toList());
  }
}
