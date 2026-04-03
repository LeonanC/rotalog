import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/models/viagem_model.dart';
import 'package:rotalog/modules/home/home_controller.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  static const Color primaryAccent = Color(0xFF2563EB); // Blue
  static const Color successAccent = Color(0xFF10B981); // Green
  static const Color warningAccent = Color(0xFFF59E0B); // Orange

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, isDarkMode),
      body: Column(
        children: [
          _buildHeader(),
          _buildQuickStats(theme),
          _buildSectionTitle(theme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.buscarViagens(),
              color: primaryAccent,
              backgroundColor: theme.cardColor,
              displacement: 20,
              child: _buildListaViagens(theme),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context, theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 25,
      title: Text(
        "hp_titulo".tr.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
          color: theme.textTheme.titleLarge?.color,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            children: [
              _appBarActionButton(
                theme,
                isDarkMode,
                RemixIcons.notification_3_line,
                () {},
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Get.toNamed('/perfil'),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryAccent.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: primaryAccent.withOpacity(0.1),
                    child: Icon(
                      RemixIcons.user_3_fill,
                      color: primaryAccent,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _appBarActionButton(
    ThemeData theme,
    bool isDarkMode,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: theme.iconTheme.color?.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2563EB).withOpacity(0.4),
              blurRadius: 25,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${'hp_total_percorrido'.tr} (${controller.diasFiltro.value}d)",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.formatarDistancia(
                          controller.totalDistancia.value,
                        ),
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    RemixIcons.truck_line,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _filterButton("7D", 7),
                  _filterButton("30D", 30),
                  _filterButton("90D", 90),
                  _filterButton("TUDO", 3650),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label, int dias) {
    return Obx(() {
      bool ativo = controller.diasFiltro.value == dias;
      return GestureDetector(
        onTap: () => controller.mudarFiltro(dias),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: ativo
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: ativo ? primaryAccent : Colors.white70,
              fontWeight: ativo ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFAB(BuildContext context, ThemeData theme) {
    final Rx<double> _scale = 1.0.obs;

    return Obx(
      () => AnimatedScale(
        scale: _scale.value,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Listener(
          onPointerDown: (_) => _scale.value = 0.9,
          onPointerUp: (_) => _scale.value = 1.0,
          child: FloatingActionButton.extended(
            onPressed: () => Get.toNamed('/registro'),
            backgroundColor: primaryAccent,
            elevation: 8,
            highlightElevation: 3,
            focusElevation: 3,
            hoverElevation: 3,
            splashColor: Colors.white24,
            icon: Icon(RemixIcons.add_line, color: Colors.white),
            label: Text(
              'hp_novo_registro'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildSectionTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 15),
      child: Row(
        children: [
          Icon(RemixIcons.history_fill, color: primaryAccent, size: 18),
          const SizedBox(width: 12),
          Text(
            'hp_ultimos_trabalhos'.tr,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: primaryAccent.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(
            theme,
            "hp_viagens".tr,
            controller.viagens.length.toString(),
            RemixIcons.route_line,
            warningAccent,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            theme,
            "hp_media".tr,
            "${(controller.totalDistancia.value / (controller.diasFiltro.value == 3650 ? 30 : controller.diasFiltro.value)).toStringAsFixed(1)} KM",
            RemixIcons.flashlight_line,
            successAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<ViagemModel>> _agruparViagensPorData(
    List<ViagemModel> viagens,
  ) {
    Map<String, List<ViagemModel>> grupos = {};

    for (var viagem in viagens) {
      String dataFormatada;
      DateTime hoje = DateTime.now();
      DateTime dataViagem = viagem.data;

      if (DateFormat('yyyy-MM-dd').format(dataViagem) ==
          DateFormat('yyyy-MM-dd').format(hoje)) {
        dataFormatada = "hp_hoje".tr;
      } else if (DateFormat('yyyy-MM-dd').format(dataViagem) ==
          DateFormat(
            'yyyy-MM-dd',
          ).format(hoje.subtract(const Duration(days: 1)))) {
        dataFormatada = "hp_ontem".tr;
      } else {
        dataFormatada = DateFormat('dd MMMM', 'pt_BR').format(dataViagem);
      }

      if (grupos[dataFormatada] == null) grupos[dataFormatada] = [];
      grupos[dataFormatada]!.add(viagem);
    }
    return grupos;
  }

  Widget _buildListaViagens(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerList(theme);
      }

      if (controller.viagens.isEmpty) {
        return _buildEmptyState(theme);
      }

      final listaParaExibir = controller.viagensFiltradas;
      if (listaParaExibir.isEmpty) return _buildEmptyState(theme);

      final viagensAgrupadas = _agruparViagensPorData(listaParaExibir);
      final categorias = viagensAgrupadas.keys.toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          List<ViagemModel> viagensDaCategoria = viagensAgrupadas[categoria]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(theme, categoria),
              ...viagensDaCategoria
                  .map(
                    (v) => _buildViagemCard(theme, v, v.status == 'Finalizada'),
                  )
                  .toList(),
            ],
          );
        },
      );
    });
  }

  Widget _buildDateHeader(ThemeData theme, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 4),
      child: Text(
        titulo.toUpperCase(),
        style: TextStyle(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildShimmerList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: theme.cardColor,
        highlightColor: theme.highlightColor,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RemixIcons.ghost_line,
              size: 50,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.1),
            ),
            const SizedBox(height: 10),
            Text(
              "hp_nenhuma_viagem".tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViagemCard(ThemeData theme, ViagemModel viagem, bool concluida) {
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
          onTap: () => Get.toNamed('/detail', arguments: viagem),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 6,
                  color: concluida ? Colors.greenAccent : Colors.orangeAccent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            _buildStatusBadge(concluida),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              RemixIcons.box_3_line,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${viagem.carga} • ${controller.formarCarga(viagem.peso)}",
                                maxLines: 2,
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              RemixIcons.map_pin_range_line,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.5),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${controller.formatarDistancia(viagem.distancia)}',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildStatusBadge(bool finalizada) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: finalizada
            ? Colors.greenAccent.withOpacity(0.1)
            : Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        finalizada ? "hp_concluido".tr : "hp_em_andamento".tr,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: finalizada ? Colors.greenAccent : Colors.orangeAccent,
        ),
      ),
    );
  }
}
