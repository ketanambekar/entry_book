import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_input.dart';
import 'controller.dart';

class DailyEntryView extends GetView<DailyEntryController> {
  const DailyEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Entry')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextInput(
                    label: 'Account Number',
                    controller: controller.searchController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.requiredField(value, 'Account Number'),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: controller.searchAccount,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final account = controller.searchedAccount.value;
              if (account == null) {
                return const SizedBox.shrink();
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Name: ${account.accountName}'),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          const Text('Total: '),
                          Helpers.amountText(account.totalAmount),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Status: ${account.status.name.toUpperCase()}'),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            AppTextInput(
              label: 'Entry Amount',
              controller: controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.amount,
            ),
            const SizedBox(height: 20),
            Obx(
              () => AppButton(
                label: 'Submit Entry',
                icon: Icons.check,
                isLoading: controller.isLoading.value,
                onPressed: controller.submitEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
