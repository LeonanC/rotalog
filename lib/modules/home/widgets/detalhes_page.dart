import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/models/viagem_model.dart';
import 'package:rotalog/modules/home/home_controller.dart';

class DetalhesPage extends StatefulWidget {
  final Map<String, dynamic> dados;
  final String docId;
  const DetalhesPage({super.key, required this.dados, required this.docId});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  final HomeController _controller = Get.find<HomeController>();

  static const _bgColor = Color(0xFF0F172A);
  static const _cardColor = Color(0xFF1E293B);
  static const _accentColor = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _controller.initializarRodovias(widget.dados['rodovias'] ?? []);
  }

  void _abrirDialogoAdicionarDespesa() {
    final nomeCtrl = TextEditingController();
    final valorCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Novo Gasto (Pedágio/Balsa)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nomeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Descrição",
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: Icon(RemixIcons.bill_line, color: _accentColor),
                ),
              ),
              TextField(
                controller: valorCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Valor (R\$)",
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: Icon(
                    RemixIcons.money_dollar_circle_line,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text("CANCELAR"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (nomeCtrl.text.isNotEmpty &&
                          valorCtrl.text.isNotEmpty) {
                        _salvarDespesaNoFirestore(
                          nomeCtrl.text,
                          valorCtrl.text,
                        );
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                    ),
                    child: Text(
                      "SALVAR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.85),
    );
  }

  void _salvarDespesaNoFirestore(String nome, String valor) async {
    double valorNumerico = double.tryParse(valor.replaceAll(',', '.')) ?? 0.0;

    await FirebaseFirestore.instance
        .collection('viagens')
        .doc(widget.docId)
        .update({
          'despesas': FieldValue.arrayUnion([
            {
              'descricao': nome,
              'valor': valorNumerico,
              'registrado_em': DateTime.now().toIso8601String(),
            },
          ]),
        });
  }

  void _abrirDialogoParada() {
    Get.dialog(
      Dialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "dt_registrar_parada".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _controller.itemParada(
                RemixIcons.gas_station_line,
                "Abastecimento",
                Colors.orangeAccent,
              ),
              _controller.itemParada(
                RemixIcons.rest_time_line,
                "Descanso/Sono",
                Colors.purpleAccent,
              ),
              _controller.itemParada(
                RemixIcons.e_bike_2_line,
                "Parada Operacional",
                Colors.greenAccent,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Cancelar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarTempo(int totalSegundos) {
    final duration = Duration(seconds: totalSegundos);
    return [
      duration.inHours,
      duration.inMinutes.remainder(60),
      duration.inSeconds.remainder(60),
    ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
  }

  Future<void> _confirmarFinalizacao() async {
    bool? confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "dt_finalizar".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "dt_confirmar".tr,
          style: TextStyle(fontFamily: 'Montserrat', color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('dt_btn_cancelar'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "dt_btn_finalizar".tr,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final snap = await FirebaseFirestore.instance
          .collection('viagens')
          .doc(widget.docId)
          .get();
      final viagem = ViagemModel.fromFirestore(snap.data()!, widget.docId);

      await _controller.finalizarViagem(
        docId: widget.docId,
        velocidadeMedia: "80 km/h",
        viagemCompleta: viagem,
      );
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppbar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _controller.watchViagem(widget.docId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(
              child: Text(
                "Erro ao carregar dados",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var dadosFirebase = snapshot.data!.data() as Map<String, dynamic>;
          final viagemModel = ViagemModel.fromFirestore(
            dadosFirebase,
            widget.docId,
          );

          return Obx(() {
            int xpPrevisto = _controller.calcularXPGanho(viagemModel);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  _buildRotaHeader(dadosFirebase),
                  const SizedBox(height: 15),
                  _buildFinanceiroCard(dadosFirebase),
                  const SizedBox(height: 15),
                  _buildGamificationSection(xpPrevisto),
                  _buildInfoGrid(dadosFirebase),

                  _buildBotaoAcaoRapida(),
                  const SizedBox(height: 20),
                  _buildSeletorVoz(),
                  const SizedBox(height: 30),
                  _buildTimelineSection(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          });
        },
      ),

      floatingActionButton: _buildFabFinalizar(),
    );
  }

  Widget _buildBotaoAcaoRapida() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _abrirDialogoAdicionarDespesa,
            icon: Icon(RemixIcons.money_dollar_box_line, size: 18),
            label: Text("PEDÁGIO / BALSA", style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _cardColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _abrirDialogoParada,
            icon: Icon(RemixIcons.rest_time_line, size: 18),
            label: Text("PARADA/SONO", style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent.withOpacity(0.2),
              foregroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceiroCard(Map<String, dynamic> dados) {
    double receita = (dados['receita'] ?? 0.0).toDouble();
    List despesas = dados['despesas'] ?? [];
    double totalDespesas = despesas.fold(
      0.0,
      (sum, item) => sum + (item['valor'] ?? 0.0),
    );
    double lucro = receita - totalDespesas;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _financeiroItem(
                "Receita",
                "R\$ ${receita.toStringAsFixed(2)}",
                Colors.greenAccent,
              ),
              _financeiroItem(
                "Despesas",
                "R\$ ${totalDespesas.toStringAsFixed(2)}",
                Colors.redAccent,
              ),
              _financeiroItem(
                "Lucro",
                "R\$ ${lucro.toStringAsFixed(2)}",
                Colors.blueAccent,
              ),
            ],
          ),
          if (despesas.isNotEmpty) ...[
            const Divider(color: Colors.white10, height: 20),
            Text(
              '${despesas.length} despesas registradas (Pedágios/Balsas)',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _financeiroItem(String label, String valor, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 10)),
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontFamily: 'ShareTechMono',
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFabFinalizar() {
    return Obx(
      () => _controller.cronometroAtivo.value
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: () => _confirmarFinalizacao(),
              backgroundColor: Colors.green,
              icon: Icon(RemixIcons.check_double_line, color: Colors.white),
              label: Text(
                "dt_finalizar_rota".tr,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildGamificationSection(int xp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "dt_xp_previsto".tr,
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
              Text(
                "+ $xp XP",
                style: TextStyle(
                  fontFamily: 'ShareTechMono',
                  color: Colors.yellowAccent,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "dt_xp_nivel".tr + ' ${_controller.nivel.value}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeletorVoz() {
    return Row(
      children: [
        Icon(RemixIcons.voiceprint_line, color: Colors.blueAccent, size: 20),
        const SizedBox(width: 10),
        Text(
          "dt_aviso_voz".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _controller.intervaloVozMinutos.value,
              dropdownColor: const Color(0xFF1E293B),
              icon: Icon(RemixIcons.arrow_down_fill, color: Colors.blueAccent),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              items: [1, 5, 10, 15, 30].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        RemixIcons.notification_4_line,
                        size: 16,
                        color: value == _controller.intervaloVozMinutos.value
                            ? Colors.blueAccent
                            : Colors.white24,
                      ),
                      const SizedBox(width: 10),
                      Text("$value min"),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (novo) =>
                  _controller.intervaloVozMinutos.value = novo!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRotaHeader(Map<String, dynamic> dados) {
    List rodovias = dados['rodovias'] ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withOpacity(0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 30,
              child: Column(
                children: [
                  Icon(
                    RemixIcons.map_pin_2_fill,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VerticalDivider(
                          color: Colors.white12,
                          thickness: 1.5,
                          width: 1,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(rodovias.length, (index) {
                            bool isAtiva =
                                _controller.cronometroAtivo.value &&
                                _controller.rodoviaSendoMonitorada.value ==
                                    index;
                            bool jaConcluida =
                                (rodovias[index]['duracao'] ?? 0) > 0 &&
                                !isAtiva;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isAtiva ? 10 : 6,
                              height: isAtiva ? 10 : 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAtiva
                                    ? Colors.blueAccent
                                    : (jaConcluida
                                          ? Colors.greenAccent
                                          : Colors.white24),
                                boxShadow: isAtiva
                                    ? [
                                        BoxShadow(
                                          color: Colors.blueAccent.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    RemixIcons.flag_2_fill,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _txtCidade(dados['origem'] ?? "Origem"),
                  if (rodovias.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(rodovias.length, (index) {
                          bool isAtiva =
                              _controller.cronometroAtivo.value &&
                              _controller.rodoviaSendoMonitorada.value == index;
                          return AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: isAtiva ? Colors.white : Colors.white38,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: isAtiva
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            child: Text(rodovias[index]['nome'] ?? "Rodovia"),
                          );
                        }),
                      ),
                    )
                  else
                    const SizedBox(height: 30),
                  _txtCidade(dados['destino'] ?? "Destino"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _txtCidade(String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontFamily: 'Montserrat',
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoGrid(Map<String, dynamic> dados) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoItem(
            RemixIcons.scales_line,
            "dt_peso".tr,
            "${dados['peso']} kg",
          ),
          _infoItem(RemixIcons.box_3_line, "dt_carga".tr, dados['carga']),
          _infoItem(
            RemixIcons.route_line,
            "dt_distancia".tr,
            "${dados['distancia']} km",
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icone, String label, String valor) {
    return Column(
      children: [
        Icon(icone, color: Colors.white38, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontFamily: 'ShareTechMono',
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "dt_log_rota".tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.blueAccent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            if (_controller.cronometroAtivo.value) _buildBadgeGravando(),
          ],
        ),
        const SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.rodoviasLocais.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final rodovia = _controller.rodoviasLocais[idx];
            bool isMonitorando =
                _controller.cronometroAtivo.value &&
                _controller.rodoviaSendoMonitorada.value == idx;
            int tempo = isMonitorando
                ? _controller.tempoDecorrido.value
                : (rodovia['duracao'] ?? 0);

            return _buildRodoviaTile(idx, rodovia, isMonitorando, tempo);
          },
        ),
      ],
    );
  }

  Widget _buildRodoviaTile(int idx, rodovia, bool active, int tempo) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: active
            ? _accentColor.withOpacity(0.1)
            : _cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? _accentColor : Colors.transparent),
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            active ? RemixIcons.stop_circle_fill : RemixIcons.play_circle_line,
            color: active ? Colors.redAccent : _accentColor,
          ),
          onPressed: () => _controller.toggleCronometro(
            idx,
            widget.docId,
            widget.dados['rodovias'],
          ),
        ),
        title: Text(
          rodovia['nome'],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          idx < (widget.dados['tipos_rodovias']?.length ?? 0)
              ? widget.dados['tipos_rodovia'][idx]
              : 'Rodovia',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Text(
          _formatarTempo(tempo),
          style: TextStyle(
            fontFamily: 'ShareTechMono',
            color: active ? Colors.redAccent : Colors.white70,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Container _buildBadgeGravando() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        "dt_gravando_tempo".tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "dt_titulo".tr,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
