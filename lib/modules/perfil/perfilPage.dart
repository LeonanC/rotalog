import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/controllers/perfilController.dart';

class PerfilPage extends GetView<PerfilController> {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "pr_titulo".tr,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }
        final user = controller.userModel.value;
        if (user == null)
          return Center(
            child: Text(
              "pr_usuario_nao_encontrado".tr,
              style: TextStyle(color: Colors.white),
            ),
          );

        double progressoSeguro = (user.xpNecessarioParaProxNivel > 0)
            ? user.progressNivel
            : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(user, progressoSeguro),
              const SizedBox(height: 24),
              _buildCNHCard(user),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2938),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      RemixIcons.truck_line,
                      "pr_veiculo_modelo".tr,
                      user.modeloCaminhao ?? "pr_nao_informado".tr,
                    ),
                    const Divider(color: Colors.white10, height: 30),
                    _buildInfoTile(
                      RemixIcons.steering_2_line,
                      "pr_veiculo_placa".tr,
                      user.placa,
                    ),
                    const Divider(color: Colors.white10, height: 30),
                    _buildInfoTile(
                      RemixIcons.calendar_event_line,
                      "pr_membro_desde".tr,
                      user.criadoEm != null ? "${user.criadoEm?.year}" : "2024",
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCNHCard(user) {
    bool isExpired = user.cnhVencida;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpired
              ? [const Color(0xFF451A1A), const Color(0xFF1E2938)]
              : [
                  const Color(0xFF1E3A8A).withOpacity(0.5),
                  const Color(0xFF1E2938),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpired
              ? Colors.redAccent.withOpacity(0.5)
              : Colors.blueAccent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "pr_cnh_titulo".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
              Icon(
                isExpired
                    ? RemixIcons.error_warning_line
                    : RemixIcons.checkbox_circle_line,
                color: isExpired ? Colors.redAccent : Colors.greenAccent,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(RemixIcons.id_card_fill, color: Colors.white24, size: 40),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "pr_cnh_registro".tr,
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    user.cnhNumero ?? "---",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "pr_cnh_validade".tr,
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                  Text(
                    user.cnhValidade != null
                        ? DateFormat('dd/MM/yyyy').format(user.cnhValidade!)
                        : "---",
                    style: TextStyle(
                      color: isExpired ? Colors.redAccent : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                "pr_cnh_ear".tr,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(user, double progresso) {
    bool isElite = user.nivel >= 30;
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: user.corDoRank, width: 3),
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blueAccent,
                child: Text(
                  user.nome.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: user.corDoRank,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                "${user.nivel}",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isElite) ...[
              Icon(RemixIcons.medal_fill, color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              user.nome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isElite) ...[
              const SizedBox(width: 8),
              Icon(RemixIcons.medal_fill, color: Color(0xFFFFD700), size: 24),
            ],
          ],
        ),
        Text(
          user.tituloMotorista,
          style: TextStyle(
            color: user.corDoRank,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2938),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: user.corDoRank.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "pr_progresso_carreira".tr,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    "${user.xpAtual}/${user.xpNecessarioParaProxNivel} XP",
                    style: TextStyle(
                      color: user.corDoRank,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progresso.clamp(0.0, 16.0),
                  backgroundColor: Colors.white10,
                  color: user.corDoRank,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isWarning ? const Color(0xFFFB7185) : Colors.blueAccent,
          size: 24,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(
                color: isWarning ? const Color(0xFFFB7185) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
