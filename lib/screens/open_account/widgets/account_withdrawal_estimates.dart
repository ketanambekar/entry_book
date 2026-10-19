import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';
import 'package:entry_book/screens/open_account/open_account_controller.dart';
import 'package:entry_book/widgets/withdrawal/withdrawal_schedule.dart';

class AccountWithdrawalEstimates extends GetView<OpenAccountController> {
  const AccountWithdrawalEstimates({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.openingAmountController,
      builder: (context, _) {
        final amount = controller.openingAmountController.text.trim();
        if (controller.validateOpeningAmount(amount) != null) {
          return const Text(
            'Enter a valid opening amount to see withdrawal estimates.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Based on the opening collection only. Future daily/monthly '
              'collections increase principal; recalculate using the total collected.',
            ),
            const SizedBox(height: 12),
            WithdrawalSchedule(
              principalPaise: amount.isEmpty
                  ? BigInt.zero
                  : WithdrawalCalculator.parsePaise(amount),
            ),
          ],
        );
      },
    );
  }
}
