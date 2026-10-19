import 'package:get/get.dart';

import 'package:entry_book/screens/accounts/accounts_controller.dart';

class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountsController>(() => AccountsController());
  }
}
