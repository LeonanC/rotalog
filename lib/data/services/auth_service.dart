import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rotalog/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cadastrarMotorista({
    required UserModel2 userModel,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: userModel.email,
      password: password,
    );

    UserModel2 novoMotorista = UserModel2(
      id: userCredential.user!.uid,
      nome: userModel.nome,
      email: userModel.email,
      placa: userModel.placa,
      modeloCaminhao: userModel.modeloCaminhao,
      cnhNumero: userModel.cnhNumero,
      cnhValidade: userModel.cnhValidade,
      totalKmAcumulado: userModel.totalKmAcumulado,
    );

    await _firestore
        .collection('motoristas')
        .doc(novoMotorista.id)
        .set(novoMotorista.toMap());
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
