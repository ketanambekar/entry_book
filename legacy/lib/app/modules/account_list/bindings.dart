import 'package:get/get.dart';

import 'controller.dart';

class AccountListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountListController>(AccountListController.new);
  }
}
