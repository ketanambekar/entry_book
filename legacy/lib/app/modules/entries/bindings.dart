import 'package:get/get.dart';

import 'controller.dart';

class EntriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EntriesController>(EntriesController.new);
  }
}

