import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_input.dart';
import 'controller.dart';

class OpenAccountView extends GetView<OpenAccountController> {
  const OpenAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final merged = Listenable.merge(<Listenable>[
      controller.accountNameController,
      controller.accountNumberController,
      controller.amountController,
    ]);

    return Scaffold(
      appBar: AppBar(title: const Text('Open Account')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Create New Account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fill details carefully. Account Number must stay unique and cannot be reused.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppTextInput(
              label: 'Account Holder Name',
              controller: controller.accountNameController,
              hint: 'Ex: Rahul Sharma',
              helperText: 'Enter full name for easy search later',
              prefixIcon: const Icon(Icons.person_outline),
              validator: (value) =>
                  Validators.requiredField(value, 'Account Holder Name'),
            ),
            const SizedBox(height: 12),
            AppTextInput(
              label: 'Unique Account Number',
              controller: controller.accountNumberController,
              keyboardType: TextInputType.number,
              hint: 'Ex: 100245',
              helperText: 'Digits only. Must be unique.',
              prefixIcon: const Icon(Icons.confirmation_number_outlined),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) =>
                  Validators.requiredField(value, 'Account Number'),
            ),
            const SizedBox(height: 12),
            AppTextInput(
              label: 'Opening Amount',
              controller: controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              hint: '0.00',
              helperText: 'This becomes your first entry amount',
              prefixText: '₹ ',
              prefixIcon: const Icon(Icons.currency_rupee),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: Validators.amount,
            ),
            const SizedBox(height: 12),
            Obx(
              () => AppTextInput(
                label: 'Creation Date',
                readOnly: true,
                helperText: 'Defaults to today, tap to change',
                prefixIcon: const Icon(Icons.date_range_outlined),
                controller: TextEditingController(
                  text: Helpers.formatDate(controller.creationDate.value),
                ),
                onTap: controller.pickDate,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: merged,
              builder: (context, _) {
                final name = controller.accountNameController.text.trim();
                final number = controller.accountNumberController.text.trim();
                final amount = double.tryParse(controller.amountController.text.trim()) ?? 0;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Review Before Submit',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Text('Name: ${name.isEmpty ? '-' : name}'),
                        const SizedBox(height: 6),
                        Text('Account No: ${number.isEmpty ? '-' : number}'),
                        const SizedBox(height: 6),
                        Row(
                          children: <Widget>[
                            const Text('Opening Amount: '),
                            Helpers.amountText(amount),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Date: ${Helpers.formatDate(controller.creationDate.value)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Obx(
              () => AppButton(
                label: 'Create Account',
                icon: Icons.save,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
