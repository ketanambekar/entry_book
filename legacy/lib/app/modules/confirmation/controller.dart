import 'dart:async';

import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class ConfirmationController extends GetxController {
  late final String title;
  late final String message;
  Timer? _autoCloseTimer;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map<String, dynamic>? ?? <String, dynamic>{});
    title = args['title'] as String? ?? 'Success';
    message = args['message'] as String? ?? 'Operation completed successfully';

    final autoCloseSeconds = args['autoCloseSeconds'] as int?;
    if (autoCloseSeconds != null && autoCloseSeconds > 0) {
      _autoCloseTimer = Timer(Duration(seconds: autoCloseSeconds), () {
        if (Get.currentRoute == AppRoutes.confirmation) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      });
    }
  }

  @override
  void onClose() {
    _autoCloseTimer?.cancel();
    super.onClose();
  }
}
