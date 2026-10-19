import 'package:get/get.dart';

import 'package:entry_book/screens/open_account/open_account_controller.dart';

class OpenAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OpenAccountController>(() => OpenAccountController());
  }
}
