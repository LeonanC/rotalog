import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rotalog/data/models/user_model.dart';

class PerfilController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = true.obs;
  var userModel = Rxn<UserModel2>();

  @override
  void onInit() {
    super.onInit();
    carregarDadosMotorista();
  }

  void carregarDadosMotorista() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('motoristas')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          userModel.value = UserModel2.fromFirestore(doc);
        } else {
          print("Documento do motorista não encontrado no banco.");
        }
      }
    } catch (e) {
      print("Erro ao carregar perfil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    try {
      await _auth.signOut();
      userModel.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Erro", "Não foi possível sair");
    }
  }
}
