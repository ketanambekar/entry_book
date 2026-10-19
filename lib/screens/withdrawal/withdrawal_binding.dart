import 'package:get/get.dart';
import 'package:entry_book/screens/withdrawal/withdrawal_controller.dart';

class WithdrawalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawalController>(() => WithdrawalController());
  }
}
