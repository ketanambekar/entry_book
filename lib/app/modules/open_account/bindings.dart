import 'package:get/get.dart';

import 'controller.dart';

class OpenAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OpenAccountController>(OpenAccountController.new);
  }
}
