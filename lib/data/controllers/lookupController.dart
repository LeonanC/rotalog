import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rotalog/data/models/tipo_carga.dart';
import 'package:rotalog/data/models/tipo_rodovia.dart';

class Lookupcontroller extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final categoriaEntries = <TipoCarga>[].obs;
  final tiposEntries = <TipoRodovia>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLookups();
  }

  void fetchLookups() {
    _firestore.collection('cargas').snapshots().listen((snapshot) {
      categoriaEntries.value = snapshot.docs
          .map((doc) => TipoCarga.fromFirestore(doc.data(), doc.id))
          .toList();
    });
    _firestore.collection('tipo_rodovia').snapshots().listen((snapshot) {
      tiposEntries.value = snapshot.docs
          .map((doc) => TipoRodovia.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}
