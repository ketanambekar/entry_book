import 'package:get/get.dart';

import 'controller.dart';

class DailyEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyEntryController>(DailyEntryController.new);
  }
}
