import 'package:get/get.dart';

import 'package:entry_book/screens/collections/collections_controller.dart';

class CollectionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CollectionsController>(() => CollectionsController());
  }
}
