import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/login/login_controller.dart';
import 'package:entry_book/screens/login/widgets/login_phone_input.dart';

class LoginPhoneForm extends GetView<LoginController> {
  const LoginPhoneForm({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: controller.phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome back', style: AppTextStyles.displayT.bold),
          const SizedBox(height: 12),
          Text(
            'Sign in with your phone number to get started.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          LoginPhoneInput(
            controller: controller.phoneController,
            focusNode: controller.phoneFocusNode,
            validator: controller.validatePhone,
            onSubmitted: controller.continueToOtp,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Continue',
            expanded: true,
            size: AppButtonSize.large,
            onPressed: controller.continueToOtp,
          ),
        ],
      ),
    );
  }
}
