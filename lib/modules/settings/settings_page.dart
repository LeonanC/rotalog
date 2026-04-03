import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:rotalog/data/controllers/perfilController.dart';
import 'package:rotalog/modules/settings/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "st_titulo".tr,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("st_pref_viagem".tr),
            Obx(
              () => _buildSettingTile(
                theme: theme,
                icon: RemixIcons.money_dollar_circle_line,
                title: "st_moeda_preferida".tr,
                subtitle: controller.useCurrency.value,
                onTap: () => _showCurrencyModal(context, theme),
              ),
            ),
            Obx(
              () => _buildSettingTile(
                theme: theme,
                icon: RemixIcons.ruler_2_line,
                title: "st_unidade_distancia".tr,
                subtitle: controller.useMiles.value
                    ? "st_milhas".tr
                    : "st_quilometros".tr,
                trailing: Switch(
                  value: controller.useMiles.value,
                  onChanged: controller.toggleUnit,
                  activeColor: Colors.blueAccent,
                ),
              ),
            ),
            Obx(
              () => _buildSettingTile(
                theme: theme,
                icon: RemixIcons.scales_3_line,
                title: 'st_unidade_peso'.tr,
                subtitle: controller.usePeso.value
                    ? "st_libras".tr
                    : "st_toneladas".tr,
                trailing: Switch(
                  value: controller.usePeso.value,
                  onChanged: controller.togglePeso,
                  activeColor: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle("st_aparencia".tr),
            Obx(
              () => _buildSettingTile(
                theme: theme,
                icon: controller.isDarkMode.value
                    ? RemixIcons.moon_line
                    : RemixIcons.sun_line,
                title: "st_modo_escuro".tr,
                subtitle: "st_modo_escuro_sub".tr,
                trailing: Switch(
                  value: controller.isDarkMode.value,
                  onChanged: (val) => controller.toggleTheme(),
                  activeColor: Colors.blueAccent,
                ),
              ),
            ),
            _buildSettingTile(
              theme: theme,
              icon: RemixIcons.global_line,
              title: "st_idioma".tr,
              subtitle: "st_idioma_nome".tr,
              onTap: () => _showLanguageModal(context, theme),
            ),

            const SizedBox(height: 24),
            _sectionTitle("st_conta_seguranca".tr),
            _buildSettingTile(
              theme: theme,
              icon: RemixIcons.user_settings_line,
              title: "st_perfil_motorista".tr,
              subtitle: "st_perfil_motorista_sub".tr,
              onTap: () => Get.toNamed('/perfil'),
            ),
            _buildSettingTile(
              theme: theme,
              icon: RemixIcons.shield_check_line,
              title: "st_privacidade".tr,
              subtitle: "st_privacidade_sub".tr,
              onTap: () {},
            ),
            const SizedBox(height: 30),
            _buildLogoutButton(theme),
          ],
        ),
      ),
    );
  }

  void _showCurrencyModal(BuildContext context, ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'st_selecione_moeda'.tr,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            _currencyItem(theme, "Real Brasileiro", 'R\$'),
            _currencyItem(theme, "Euro", '€'),
            _currencyItem(theme, "Dólar Americando", 'US\$'),
            _currencyItem(theme, "Libra Esterlina", '£'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _currencyItem(ThemeData theme, String name, String symbol) {
    final bool isSelected = controller.useCurrency.value == symbol;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          symbol,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontFamily: 'Montserrat',
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(RemixIcons.check_line, color: Colors.blueAccent)
          : null,
      onTap: () {
        controller.changeCurrency(symbol);
        Get.back();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void _showLanguageModal(BuildContext context, ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2938),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "st_selecione_idioma".tr,
              style: TextStyle(
                fontFamily: "Montserrat",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            _languageItem(theme, "Português", "pt", "BR", "🇧🇷"),
            _languageItem(theme, "English", "en", "US", "🇺🇸"),
            _languageItem(theme, "Español", "es", "ES", "🇪🇸"),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _languageItem(
    ThemeData theme,
    String name,
    String langCode,
    String countryCode,
    String flag,
  ) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontFamily: 'Montserrat',
        ),
      ),
      onTap: () {
        controller.changeLanguage(langCode, countryCode);
        Get.back();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.blueAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              RemixIcons.arrow_right_s_line,
              color: theme.iconTheme.color?.withOpacity(0.3),
              size: 18,
            ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    final perfilController = Get.find<PerfilController>();
    const logoutColor = Color(0xFFFB7185);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => perfilController.logout(),
        icon: Icon(RemixIcons.logout_box_r_line, color: logoutColor),
        label: Text(
          "st_logout".tr,
          style: TextStyle(color: logoutColor, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: logoutColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
