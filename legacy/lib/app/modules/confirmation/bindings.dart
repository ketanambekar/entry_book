import 'package:get/get.dart';

import 'controller.dart';

class ConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfirmationController>(ConfirmationController.new);
  }
}
