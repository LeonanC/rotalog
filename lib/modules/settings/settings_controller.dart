import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();

  var isDarkMode = true.obs;
  var language = 'pt_BR'.obs;
  var useCurrency = 'R\$'.obs;
  var useMiles = false.obs;
  var usePeso = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('dark_mode') ?? true;
    useMiles.value = _box.read('use_miles') ?? false;
    usePeso.value = _box.read('use_toneladas') ?? false;
    useCurrency.value = _box.read('currency_symbol') ?? 'R\$';
  }

  void changeLanguage(String langCode, String countryCode) {
    var locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);

    _box.write('lang', langCode);
    _box.write('country', countryCode);
  }

  void changeCurrency(String symbol) {
    useCurrency.value = symbol;
    _box.write('currency_symbol', symbol);
    update();
  }

  String formatarCurrency(double valor) {
    return "${useCurrency.value} ${valor.toStringAsFixed(3)}";
  }

  String formatarDistancia(double km) {
    if (useMiles.value) {
      double milhas = km * 0.621371;
      return "${milhas.toStringAsFixed(1)} mi";
    }
    return "${km.toStringAsFixed(0)} km";
  }

  String formatarPeso(double pesoEmKg) {
    if (usePeso.value) {
      double libras = pesoEmKg * 2.20462;
      return "${libras.toStringAsFixed(0)} lb";
    } else {
      if (pesoEmKg < 1000) {
        return "${pesoEmKg.toStringAsFixed(0)} kg";
      }
      double toneladas = pesoEmKg / 1000;

      return "${toneladas.toStringAsFixed(1)} t";
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _box.write('dark_mode', isDarkMode.value);
  }

  void toggleUnit(bool value) {
    useMiles.value = value;
    _box.write('use_miles', value);
  }

  void togglePeso(bool value) {
    usePeso.value = value;
    _box.write('use_toneladas', value);
  }
}
