import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:rotalog/data/models/viagem_model.dart';
import 'package:rotalog/modules/settings/settings_controller.dart';

class HomeController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterTts _tts = FlutterTts();
  final settingsCtrl = Get.find<SettingsController>();

  var viagens = <ViagemModel>[].obs;
  var diasFiltro = 30.obs;
  var isLoading = false.obs;
  var totalDistancia = 0.0.obs;
  var seachText = ''.obs;
  var filterStatus = ''.obs;
  Timer? _timer;
  final receitaController = TextEditingController();

  var despesas = <Map<String, dynamic>>[].obs;

  var tempoDecorrido = 0.obs;
  var cronometroAtivo = false.obs;
  var rodoviaSendoMonitorada = (-1).obs;
  var intervaloVozMinutos = 5.obs;
  var rodoviasLocais = <dynamic>[].obs;
  var tipoCategoria = <String, String>{}.obs;

  var xpAtual = 0.obs;
  var nivel = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _configurarTTS();
    loadAuxiliaryData();
    _carregarDadosMotorista();
    ever(viagens, (_) => _calcularTotalDistancia());
    ever(diasFiltro, (_) => _calcularTotalDistancia());
    bindViagens();
  }

  void removerDespesa(int index) => despesas.removeAt(index);

  Widget itemParada(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: () {
        Get.back();
      },
    );
  }

  String formatarDistancia(double km) {
    if (settingsCtrl.useMiles.value) {
      double milhas = km * 0.621371;
      return "${milhas.toStringAsFixed(1)} mi";
    }
    return "${km.toStringAsFixed(1)} km";
  }

  String formarCarga(double toneladas) {
    if (settingsCtrl.usePeso.value) {
      double libras = toneladas * 2204.62;
      return "${libras.toStringAsFixed(1)} lbs";
    }
    return "${toneladas.toStringAsFixed(1)} t";
  }

  Future<void> _configurarTTS() async {
    await _tts.setLanguage("pt-BR");
    await _tts.setSpeechRate(0.5);
  }

  void alterarIntervalo(int novoValor) {
    intervaloVozMinutos.value = novoValor;
  }

  void initializarRodovias(List<dynamic> dadosOiginal) {
    rodoviasLocais.assignAll(List.from(dadosOiginal));
  }

  Future<void> _carregarDadosMotorista() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      var doc = await _firestore.collection('motoristas').doc(uid).get();
      if (doc.exists) {
        nivel.value = doc.data()?['nivel'] ?? 1;
        xpAtual.value = doc.data()?['xp_atual'] ?? 0;
      }
    }
  }

  List<ViagemModel> get viagensFiltradas {
    return viagens.where((v) {
      final matchesSearch =
          v.origem.toLowerCase().contains(seachText.value.toLowerCase()) ||
          v.destino.toLowerCase().contains(seachText.value.toLowerCase()) ||
          v.carga.toLowerCase().contains(seachText.value.toLowerCase());
      final matchesStatus =
          filterStatus.value.isEmpty || v.status == filterStatus.value;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> buscarViagens() async {
    bindViagens();
    await _carregarDadosMotorista();
    return Future.value();
  }

  Future<void> loadAuxiliaryData() async {
    var cargaRodo = await _firestore.collection('cargas').get();
    for (var doc in cargaRodo.docs) {
      tipoCategoria[doc.id.toString()] = doc.data()['nome'];
    }
  }

  void toggleCronometro(int index, String docId, List<dynamic> rodovias) {
    if (cronometroAtivo.value && rodoviaSendoMonitorada.value == index) {
      _timer?.cancel();
      cronometroAtivo.value = false;
      _salvarNoFirestore(docId, index, rodovias);
    } else {
      _timer?.cancel();
      rodoviaSendoMonitorada.value = index;
      cronometroAtivo.value = true;
      tempoDecorrido.value = rodovias[index]['duracao'] ?? 0;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        tempoDecorrido.value++;

        if (tempoDecorrido.value % (intervaloVozMinutos.value * 60) == 0) {
          _falarTempo();
        }
      });
    }
  }

  void _falarTempo() {
    int m = (tempoDecorrido.value / 60).floor();
    _tts.speak("Atenção motorista: tempo de percurso em $m minutos");
  }

  int calcularXPGanho(ViagemModel viagem) {
    double distancia = viagem.distancia;
    double xpBase = distancia * 10;

    double multiplicadorCarga = 1.0;
    for (var cat in viagem.categoria) {
      String c = cat.toString().toLowerCase();
      if (c.contains('perigosa')) multiplicadorCarga += 0.50; // +50%
      if (c.contains('pesada')) multiplicadorCarga += 0.30; // +30%
      if (c.contains('fragil')) multiplicadorCarga += 0.20; // +20%
      if (c.contains('urgente')) multiplicadorCarga += 0.40; // +40%
    }

    double bonusRodovias = viagem.rodovias.length * 50.0;

    double velMedia =
        double.tryParse(
          viagem.velocidadeMedia.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;

    double penalty = (velMedia > 100) ? 0.7 : 1.0;

    int totalGeral = (((xpBase * multiplicadorCarga) + bonusRodovias) * penalty)
        .toInt();

    return totalGeral;
  }

  Future<void> adicionarXP(int pontos) async {
    await _carregarDadosMotorista();
    xpAtual.value += pontos;

    bool subiuDeNivel = false;
    while (nivel.value > 0 && xpAtual.value >= (nivel.value * 1700)) {
      int proximoNivelXP = nivel.value * 1700;
      xpAtual.value -= proximoNivelXP;
      nivel.value++;
      subiuDeNivel = true;
    }

    if (subiuDeNivel) {
      _showLevelUpDialog();
    }

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('motoristas').doc(uid).update({
        'nivel': nivel.value,
        'xp_atual': xpAtual.value,
      });
    }
  }

  void _showLevelUpDialog() {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: "🚀 LEVEL UP!",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      middleText: "Parabéns! Você subiu para o Nível ${nivel.value}",
      middleTextStyle: const TextStyle(color: Colors.white70),
      confirmTextColor: Colors.white,
      buttonColor: Colors.blueAccent,
      onConfirm: () => Get.back(),
    );
  }

  Future<void> _salvarNoFirestore(
    String docId,
    int index,
    List rodovias,
  ) async {
    rodovias[index]['duracao'] = tempoDecorrido.value;
    await atualizarTemposRodovias(docId, rodovias);
  }

  void bindViagens() {
    final String? uid = _auth.currentUser?.uid;

    if (uid == null) {
      print("Nenhum usuário logado");
      return;
    }

    viagens.bindStream(
      _firestore
          .collection('viagens')
          .where('motorista_id', isEqualTo: uid)
          .orderBy('data', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return ViagemModel.fromFirestore(doc.data(), doc.id);
            }).toList();
          })
          .handleError((error) {
            print("Erro de conexão: $error");
            Get.snackbar(
              "Modo Offline",
              "Não foi possível sincronizar com o servidor",
              backgroundColor: Colors.orangeAccent,
              snackPosition: SnackPosition.BOTTOM,
            );
          }),
    );
  }

  void _calcularTotalDistancia() {
    DateTime limite = DateTime.now().subtract(Duration(days: diasFiltro.value));

    double soma = viagens.where((v) => v.data.isAfter(limite)).fold(0.0, (
      soma,
      v,
    ) {
      final distStr = v.distancia;
      return soma + (distStr);
    });

    totalDistancia.value = soma;
  }

  void mudarFiltro(int dias) => diasFiltro.value = dias;

  Future<void> atualizarTemposRodovias(
    String docId,
    List<dynamic> rodovias,
  ) async {
    try {
      await _firestore.collection('viagens').doc(docId).update({
        'rodovias': rodovias,
      });
    } catch (e) {
      Get.snackbar("Erro", "Erro ao atualizar rodovias: $e");
      rethrow;
    }
  }

  Future<void> finalizarViagem({
    required String docId,
    required String velocidadeMedia,
    required ViagemModel viagemCompleta,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('viagens').doc(docId).update({
        'status': 'Finalizada',
        'velocidade_media': velocidadeMedia,
        'finalizada_em': FieldValue.serverTimestamp(),
      });
      int xpGanho = calcularXPGanho(viagemCompleta);
      await adicionarXP(xpGanho);

      Get.snackbar(
        "Viagem Concluída!",
        "Você ganhou $xpGanho pontos de experiência.",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Erro", "Erro ao finalizar viagem: $e");
      rethrow;
    }
  }

  Stream<DocumentSnapshot> watchViagem(String docId) {
    return _firestore.collection('viagens').doc(docId).snapshots();
  }
}
