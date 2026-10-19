import 'package:get/get.dart';

import 'package:entry_ui/entry_ui.dart';

/// Registers app-wide GetX dependencies (services, controllers) at startup.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
  }
}
