import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/models/viagem_model.dart';
import 'package:rotalog/modules/home/home_controller.dart';

class ViagemCard extends GetView<HomeController> {
  final ViagemModel viagem;
  final bool concluida;
  final VoidCallback onTap;
  const ViagemCard({
    super.key,
    required this.viagem,
    required this.concluida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 6,
                  color: concluida ? Colors.greenAccent : Colors.orangeAccent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRouteHeader(theme),
                        const SizedBox(height: 14),
                        _buildInfoFooter(theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "${viagem.origem} ➔ ${viagem.destino}",
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildInfoFooter(ThemeData theme) {
    return Row(
      children: [
        Icon(RemixIcons.box_3_line, size: 14, color: Colors.blueAccent),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            "${viagem.carga} • ${controller.formarCarga(viagem.peso)}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        _buildDistanceIndicator(theme),
      ],
    );
  }

  Widget _buildDistanceIndicator(ThemeData theme) {
    return Row(
      children: [
        Icon(
          RemixIcons.map_pin_range_line,
          size: 14,
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
        ),
        const SizedBox(width: 5),
        Text(
          controller.formatarDistancia(viagem.distancia),
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final color = concluida ? Colors.greenAccent : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        concluida ? "hp_concluido".tr : "hp_em_andamento".tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
