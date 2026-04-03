import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/models/viagem_model.dart';

class RegistroController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();

  final origemController = TextEditingController();
  final destinoController = TextEditingController();
  final cargaController = TextEditingController();

  final receitaController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 3,
    leftSymbol: 'R\$ ',
  );

  final pesoController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 3,
    leftSymbol: '',
  );
  final distanciaController = MoneyMaskedTextController(
    decimalSeparator: ',',
    thousandSeparator: '.',
    precision: 1,
    leftSymbol: '',
  );
  final rodoviasInputController = TextEditingController();

  var cargaSelecionada = <Map<String, dynamic>>[].obs;
  var rodoviasSelecionadas = <Map<String, dynamic>>[].obs;
  var tipoRodoviaDisponiveis = <QueryDocumentSnapshot>[].obs;
  final RxMap<int, String> tipoRodovia = <int, String>{}.obs;
  var tipoCategoriaSelecionada = <String>[].obs;
  var tipoRodoviaSelecionada = <String>[].obs;
  var isLoading = false.obs;
  var localSelecionadoId = Rxn<int>();

  double _calcularMultiplicador() {
    double multi = 1.0;
    if (tipoCategoriaSelecionada.contains("ADR")) multi += 0.21;
    if (tipoCategoriaSelecionada.contains("FRÁGIL")) multi += 0.22;
    if (tipoCategoriaSelecionada.contains("URGENTE")) multi += 0.30;
    return multi;
  }

  @override
  void onInit() {
    super.onInit();
    loadAuxiliaryData();
  }

  Future<void> loadAuxiliaryData() async {
    var tipoRodo = await _firestore.collection('tipo_rodovia').get();
    for (var doc in tipoRodo.docs) {
      tipoRodovia[doc.data()['id']] = doc.data()['nome'];
    }
  }

  void selecionarLocal(int id) {
    if (localSelecionadoId.value == id) {
      localSelecionadoId.value = null;
    } else {
      localSelecionadoId.value = id;
    }
  }

  void adicionarRodovia() {
    String nome = rodoviasInputController.text.trim().toUpperCase();

    if (nome.isNotEmpty) {
      String tipoPrincipal = tipoRodoviaSelecionada.isNotEmpty
          ? tipoRodoviaSelecionada.first
          : 'Rodovia';

      rodoviasSelecionadas.add({
        'nome': nome,
        'tipo': tipoPrincipal,
        'duracao': 0,
      });
      rodoviasInputController.clear();
      tipoRodoviaSelecionada.clear();
    }
  }

  void removerRodovia(Map<String, dynamic> rodovia) {
    rodoviasSelecionadas.remove(rodovia);
  }

  void alternarCategoria(String nome) {
    if (tipoCategoriaSelecionada.contains(nome)) {
      tipoCategoriaSelecionada.remove(nome);
    } else {
      tipoCategoriaSelecionada.add(nome);
    }
  }

  void alternarTipoRodovia(String nome) {
    if (tipoRodoviaSelecionada.contains(nome)) {
      tipoRodoviaSelecionada.remove(nome);
    } else {
      tipoRodoviaSelecionada.add(nome);
    }
  }

  Future<void> salvarTrabalho() async {
    try {
      if (!formKey.currentState!.validate()) {
        _showCustomSnackbar(
          titulo: "Ops!",
          mensagem: "Verifique os campos marcados em vermelho.",
          isError: true,
        );
        return;
      }

      if (tipoCategoriaSelecionada.isEmpty) {
        _showCustomSnackbar(
          titulo: "Categoria",
          mensagem: "Selecione o tipo de carga transportada.",
          isError: true,
        );
        return;
      }

      if (rodoviasSelecionadas.isEmpty) {
        _showCustomSnackbar(
          titulo: "Rota Vazia",
          mensagem: "Adicione as rodovias clicando no botão '+'.",
          isError: true,
        );
        return;
      }

      final String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        _showCustomSnackbar(
          titulo: "Erro de Sessão",
          mensagem: "Usuário não identificado. Tente fazer login novamente.",
          isError: true,
        );
        return;
      }

      isLoading.value = true;

      double distanciaNumerica = distanciaController.numberValue;

      double multiplicador = _calcularMultiplicador();
      int xpBase = (distanciaNumerica * 10).toInt();
      int xpFinal = (xpBase * multiplicador).toInt() + 40;

      final novaViagem = ViagemModel(
        id: "",
        motoristaId: uid,
        origem: origemController.text,
        destino: destinoController.text,
        categoria: tipoCategoriaSelecionada.toList(),
        carga: cargaController.text,
        peso: pesoController.numberValue,
        distancia: distanciaController.numberValue,
        data: DateTime.now(),
        receita: receitaController.numberValue,
        rodovias: rodoviasSelecionadas.toList(),
        tiposRodovias: tipoRodoviaSelecionada.toList(),
      );

      WriteBatch batch = _firestore.batch();
      DocumentReference viagemRef = _firestore.collection('viagens').doc();
      batch.set(viagemRef, novaViagem.toMap());

      DocumentReference motoristaRef = _firestore
          .collection('motoristas')
          .doc(uid);

      batch.update(motoristaRef, {
        'total_km': FieldValue.increment(distanciaNumerica),
        'xp_atual': FieldValue.increment(xpFinal),
        'total_viagens': FieldValue.increment(1),
      });

      for (var car in tipoCategoriaSelecionada) {
        DocumentReference statRef = motoristaRef
            .collection('estatisticas_carga')
            .doc(car.toLowerCase().replaceAll(' ', '_'));

        batch.set(statRef, {
          'quantidade': FieldValue.increment(1),
          'xp_acumulado': FieldValue.increment(
            xpFinal ~/ tipoCategoriaSelecionada.length,
          ),
          'km_total': FieldValue.increment(distanciaNumerica),
          'ultima_entrega': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      Get.back();

      _showCustomSnackbar(
        titulo: "Sucesso!",
        mensagem: "Trabalho registrado com sucesso!",
        isError: false,
      );
    } catch (e) {
      print(e);
      _showCustomSnackbar(
        titulo: "Erro no Banco",
        mensagem: "Não foi possível salvar. Verique sua conexão. $e",
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showCustomSnackbar({
    required String titulo,
    required String mensagem,
    required bool isError,
  }) {
    Get.snackbar(
      titulo,
      mensagem,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError
          ? const Color(0xFF991B1B)
          : const Color(0xFF065F46),
      colorText: Colors.white,
      icon: Icon(
        isError
            ? RemixIcons.error_warning_fill
            : RemixIcons.checkbox_circle_fill,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(15),
      borderRadius: 20,
      duration: const Duration(seconds: 3),
      barBlur: 20,
      overlayBlur: 1,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  @override
  void onClose() {
    origemController.dispose();
    destinoController.dispose();
    cargaController.dispose();
    pesoController.dispose();
    distanciaController.dispose();
    rodoviasInputController.dispose();
    super.onClose();
  }
}
