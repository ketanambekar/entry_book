import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/withdrawal/withdrawal_controller.dart';
import 'package:entry_book/widgets/withdrawal/withdrawal_breakdown.dart';
import 'package:entry_book/widgets/withdrawal/withdrawal_schedule.dart';
import 'package:entry_book/screens/withdrawal/widgets/collection_amounts.dart';

class WithdrawalForm extends GetView<WithdrawalController> {
  const WithdrawalForm({super.key});

  Future<void> _pickDate(BuildContext context, {required bool opening}) async {
    final selected = opening ? controller.openedAt : controller.withdrawnAt;
    final date = await showDatePicker(
      context: context,
      initialDate: selected.value ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (date != null) {
      selected.value = date;
      controller.invalidate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CollectionAmounts(),
          const SizedBox(height: 16),
          for (final opening in [true, false])
            Obx(() {
              final date = opening
                  ? controller.openedAt.value
                  : controller.withdrawnAt.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(
                  opening ? 'Account opening date' : 'Withdrawal date',
                ),
                subtitle: Text(
                  date == null
                      ? 'Choose date'
                      : localizations.formatMediumDate(date),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _pickDate(context, opening: opening),
              );
            }),
          Obx(
            () => controller.dateError.value == null
                ? const SizedBox.shrink()
                : Text(
                    controller.dateError.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Calculate',
            size: AppButtonSize.large,
            expanded: true,
            onPressed: controller.calculate,
          ),
          const SizedBox(height: 20),
          Text(
            'Estimate only · No withdrawal is made. Principal is the sum of '
            'all entered collections. The account age determines the rate on '
            'that entire total, including recently added collections—not each '
            'deposit’s age. Completed calendar months; '
            'month-end anniversaries use the last day of shorter months.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Obx(() {
            final result = controller.result.value;
            if (result == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                WithdrawalBreakdown(estimate: result),
                const SizedBox(height: 24),
                WithdrawalSchedule(principalPaise: result.principalPaise),
              ],
            );
          }),
        ],
      ),
    );
  }
}
