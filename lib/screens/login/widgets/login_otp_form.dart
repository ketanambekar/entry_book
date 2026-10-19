import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/login/login_controller.dart';

class LoginOtpForm extends GetView<LoginController> {
  const LoginOtpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: controller.otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Verify your number', style: textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'OTP preview for ${controller.fullPhoneNumber}',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          AppOtp(
            length: 6,
            label: 'Verification code',
            controller: controller.otpController,
            validator: controller.validateOtp,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 24),
          Text(
            'Demo only. Enter any 6 digits to explore the dashboard. '
            'No SMS is sent and this does not sign you in.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Continue to demo',
            expanded: true,
            size: AppButtonSize.large,
            onPressed: controller.enterDemoDashboard,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Change phone number',
            variant: AppButtonVariant.link,
            onPressed: controller.editPhone,
          ),
        ],
      ),
    );
  }
}
