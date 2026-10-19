import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/domain/withdrawal/withdrawal_calculator.dart';
import 'package:entry_book/screens/withdrawal/withdrawal_controller.dart';

class CollectionAmounts extends GetView<WithdrawalController> {
  const CollectionAmounts({super.key});

  @override
  Widget build(BuildContext context) {
    Widget amountField(TextEditingController entry, int index) => AppInput(
      label: 'Collection ${index + 1}',
      hint: '0.00',
      prefixIcon: const Text('₹'),
      controller: entry,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: WithdrawalCalculator.validateAmount,
      onChanged: (_) => controller.invalidate(),
      suffixIcon: index == 0
          ? null
          : IconButton(
              tooltip: 'Remove collection ${index + 1}',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => controller.removeCollection(entry),
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Daily / monthly collections',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter amounts collected up to withdrawal, including ₹0 for skipped '
          'collections. If you already know the total, enter it once.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        amountField(controller.balanceController, 0),
        Obx(
          () => Column(
            children: [
              for (
                var index = 0;
                index < controller.additionalCollections.length;
                index++
              )
                Padding(
                  key: ObjectKey(controller.additionalCollections[index]),
                  padding: const EdgeInsets.only(top: 12),
                  child: amountField(
                    controller.additionalCollections[index],
                    index + 1,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Add collection',
          variant: AppButtonVariant.tertiary,
          leading: const Icon(Icons.add_rounded),
          onPressed: controller.addCollection,
        ),
      ],
    );
  }
}
