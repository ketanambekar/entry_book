import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/open_account/open_account_controller.dart';

class AccountRequiredFields extends GetView<OpenAccountController> {
  const AccountRequiredFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          label: 'Account holder name',
          isRequired: true,
          hint: 'Enter full name',
          controller: controller.nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          validator: controller.validateName,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 20),
        AppInput(
          label: 'Account number',
          isRequired: true,
          hint: 'Enter account number',
          controller: controller.accountNumberController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: controller.validateAccountNumber,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}
