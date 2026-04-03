import 'package:get/get.dart';
import 'package:rotalog/data/controllers/lookupController.dart';
import 'package:rotalog/modules/registro/registro_controller.dart';

class RegistroBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Lookupcontroller>(() => Lookupcontroller());
    Get.lazyPut<RegistroController>(() => RegistroController());
  }
}
