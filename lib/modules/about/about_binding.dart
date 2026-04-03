import 'package:get/get.dart';
import 'package:rotalog/data/controllers/update_controller.dart';
import 'package:rotalog/modules/about/about_controller.dart';

class AboutBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutController>(() => AboutController());
    Get.lazyPut<UpdateController>(() => UpdateController());
  }
}
