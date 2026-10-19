import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';

import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';

class WithdrawalBreakdown extends StatelessWidget {
  const WithdrawalBreakdown({super.key, required this.estimate});

  final WithdrawalEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return AppOverviewCard(
      title: 'Estimated payout',
      columns: 1,
      items: [
        AppOverviewItem('Completed months', '${estimate.completedMonths}'),
        AppOverviewItem(
          'Principal balance',
          '₹${WithdrawalCalculator.formatPaise(estimate.principalPaise)}',
        ),
        AppOverviewItem(
          'Interest · 4% yearly',
          '₹${WithdrawalCalculator.formatPaise(estimate.interestPaise)}',
        ),
        AppOverviewItem(
          'Early withdrawal deduction · 3%',
          '₹${WithdrawalCalculator.formatPaise(estimate.deductionPaise)}',
        ),
        AppOverviewItem(
          'You receive',
          '₹${WithdrawalCalculator.formatPaise(estimate.payoutPaise)}',
        ),
      ],
    );
  }
}
