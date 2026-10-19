import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/open_account/open_account_controller.dart';

class AccountOptionalFields extends GetView<OpenAccountController> {
  const AccountOptionalFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          label: 'Opening amount (optional)',
          hint: '0.00',
          prefixIcon: const Text('₹'),
          controller: controller.openingAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: controller.validateOpeningAmount,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 20),
        AppInput(
          label: 'Phone number (optional)',
          hint: 'Enter 10-digit phone number',
          prefixIcon: const Text('+91'),
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: controller.validatePhone,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onSubmitted: (_) => controller.previewAccount(),
        ),
      ],
    );
  }
}
