import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/open_account/open_account_controller.dart';
import 'package:entry_book/screens/open_account/widgets/account_required_fields.dart';
import 'package:entry_book/screens/open_account/widgets/account_optional_fields.dart';
import 'package:entry_book/screens/open_account/widgets/account_form_section.dart';
import 'package:entry_book/screens/open_account/widgets/account_withdrawal_estimates.dart';

class OpenAccountForm extends GetView<OpenAccountController> {
  const OpenAccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AccountFormSection(
            title: 'Account details',
            icon: Icons.person_outline_rounded,
            child: AccountRequiredFields(),
          ),
          const SizedBox(height: 20),
          const AccountFormSection(
            title: 'Optional details',
            icon: Icons.tune_rounded,
            child: AccountOptionalFields(),
          ),
          const SizedBox(height: 20),
          const AccountWithdrawalEstimates(),
        ],
      ),
    );
  }
}
