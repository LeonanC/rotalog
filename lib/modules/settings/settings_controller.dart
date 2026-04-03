import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();

  var isDarkMode = true.obs;
  var language = 'pt_BR'.obs;
  var useMiles = false.obs;
  var usePeso = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('dark_mode') ?? true;
    useMiles.value = _box.read('use_miles') ?? false;
    usePeso.value = _box.read('use_toneladas') ?? false;
  }

  void changeLanguage(String langCode, String countryCode) {
    var locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);

    _box.write('lang', langCode);
    _box.write('country', countryCode);
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
