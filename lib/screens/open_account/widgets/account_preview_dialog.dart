import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';
import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';
import 'package:entry_book/widgets/withdrawal/withdrawal_schedule.dart';

class AccountPreviewDialog extends StatelessWidget {
  const AccountPreviewDialog({
    super.key,
    required this.name,
    required this.accountNumber,
    required this.openingAmount,
    required this.phone,
  });

  final String name;
  final String accountNumber;
  final String openingAmount;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      scrollable: true,
      title: const Text('Review details'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, value) in [
            ('Account holder name', name),
            ('Account number', accountNumber),
            ('Opening amount', '₹$openingAmount'),
            ('Phone number', phone.isEmpty ? 'Not provided' : '+91$phone'),
          ]) ...[
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            const Text(
              'Opening collection only. Future collections are not included.',
            ),
            const SizedBox(height: 8),
          ],
          const Text('Demo only. No account is opened or saved.'),
          const SizedBox(height: 20),
          WithdrawalSchedule(
            principalPaise: WithdrawalCalculator.parsePaise(openingAmount),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Back to form',
          size: AppButtonSize.large,
          variant: AppButtonVariant.tertiary,
          onPressed: () => Get.back<void>(),
        ),
      ],
    );
  }
}
