import 'package:get/get.dart';
import 'package:rotalog/data/controllers/authController.dart';
import 'package:rotalog/data/controllers/perfilController.dart';
import 'package:rotalog/modules/home/home_controller.dart';
import 'package:rotalog/modules/settings/settings_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<PerfilController>(() => PerfilController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
