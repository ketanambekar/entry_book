import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/routes/app_routes.dart';

class LoginController extends GetxController {
  final phoneFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final otpController = TextEditingController();
  final isOtpStep = false.obs;

  String get fullPhoneNumber => '+91${phoneController.text.trim()}';

  String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Enter your phone number.';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Enter a 10-digit phone number.';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value ?? '')) {
      return 'Enter a 6-digit code.';
    }
    return null;
  }

  void continueToOtp() {
    if (!phoneFormKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    isOtpStep.value = true;
  }

  void editPhone() {
    FocusManager.instance.primaryFocus?.unfocus();
    otpController.clear();
    isOtpStep.value = false;
  }

  void enterDemoDashboard() {
    if (!otpFormKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offNamed<void>(AppRoutes.dashboard);
  }

  @override
  void onClose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    otpController.dispose();
    super.onClose();
  }
}
