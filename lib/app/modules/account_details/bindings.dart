import 'package:get/get.dart';

import 'controller.dart';

class AccountDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountDetailsController>(AccountDetailsController.new);
  }
}
