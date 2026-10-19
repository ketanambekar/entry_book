import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';

import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';

class WithdrawalSchedule extends StatelessWidget {
  const WithdrawalSchedule({super.key, required this.principalPaise});

  final BigInt principalPaise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Withdrawal estimates', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Before 6 completed months: no interest, 3% principal deduction. '
          'From 6 months: 4% yearly simple interest, no deduction.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        for (var months = 1; months <= 12; months++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 4,
              children: [
                Text(
                  months < 6
                      ? '$months ${months == 1 ? 'month' : 'months'} · −3% deduction'
                      : '$months months · ${(months / 3).toStringAsFixed(months % 3 == 0 ? 0 : 4)}% interest',
                  style: AppTextStyles.bodyM.medium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Payout ₹${WithdrawalCalculator.formatPaise(WithdrawalCalculator.estimate(principalPaise, months).payoutPaise)}',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Each row applies that account-age rate to the principal shown, '
          'not a forecast of future collections. Add new collections to '
          'principal and recalculate. '
          'Interest continues after 12 months without compounding. '
          'Amounts rounded to the nearest paise; rates displayed rounded.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
