import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rotalog/data/controllers/update_controller.dart';

class AboutController extends GetxController {
  final UpdateController updateController = Get.put(UpdateController());
  Color primaryAccent = Color(0xFF2563EB);
  Color bgDark = Color(0xFF0F172A);
  Color cardDark = Color(0xFF1E293B);

  var appVersion = 'Carregando...'.obs;
  var isCheckingForUpdate = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = "${packageInfo.version}+${packageInfo.buildNumber}";
    } catch (e) {
      appVersion.value = 'Erro ao carregar';
    }
  }

  void setChecking(bool value) {
    isCheckingForUpdate.value = value;
  }

  Future<void> checkForUpdate() async {
    setChecking(true);
    try {
      updateController.checkForUpdate();
    } finally {
      setChecking(false);
    }
  }
}
