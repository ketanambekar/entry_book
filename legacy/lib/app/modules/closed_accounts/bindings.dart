import 'package:get/get.dart';

import 'controller.dart';

class ClosedAccountsBinding extends Bindings {
  ClosedAccountsBinding({this.showCloseFlow = false});

  final bool showCloseFlow;

  @override
  void dependencies() {
    Get.lazyPut<ClosedAccountsController>(
      () => ClosedAccountsController(showCloseFlow: showCloseFlow),
    );
  }
}
