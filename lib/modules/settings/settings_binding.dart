import 'package:get/get.dart';
import 'package:rotalog/data/controllers/perfilController.dart';
import 'package:rotalog/modules/settings/settings_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<PerfilController>(() => PerfilController());
  }
}
