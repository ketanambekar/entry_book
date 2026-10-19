import 'package:get/get.dart';

import 'package:entry_book/screens/dashboard/dashboard_controller.dart';
import 'package:entry_book/screens/profile/profile_binding.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    ProfileBinding().dependencies();
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
