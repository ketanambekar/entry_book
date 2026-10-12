import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/app_text_input.dart';
import 'controller.dart';

class ClosedAccountsView extends GetView<ClosedAccountsController> {
  const ClosedAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.showCloseFlow ? 'Close Account' : 'Closed Accounts'),
      ),
      body: controller.showCloseFlow
          ? _CloseFlow(controller: controller)
          : _ClosedList(controller: controller),
    );
  }
}

class _CloseFlow extends StatelessWidget {
  const _CloseFlow({required this.controller});

  final ClosedAccountsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedAccountNumber.value == null
          ? null
          : controller.activeAccounts.firstWhereOrNull(
              (a) => a.accountNumber == controller.selectedAccountNumber.value,
            );

      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          DropdownButtonFormField<String>(
            initialValue: controller.selectedAccountNumber.value,
            items: controller.activeAccounts
                .map(
                  (a) => DropdownMenuItem<String>(
                    value: a.accountNumber,
                    child: Text('${a.accountNumber} - ${a.accountName}'),
                  ),
                )
                .toList(),
            onChanged: (value) => controller.selectedAccountNumber.value = value,
            decoration: const InputDecoration(labelText: 'Select Account'),
          ),
          const SizedBox(height: 12),
          if (selected != null) ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Name: ${selected.accountName}'),
                    const SizedBox(height: 6),
                    Text('Creation Date: ${Helpers.formatDate(selected.creationDate)}'),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        const Text('Total Amount: '),
                        Helpers.amountText(selected.totalAmount),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppTextInput(
            label: 'Closing Amount',
            controller: controller.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Close Account',
            icon: Icons.lock,
            onPressed: controller.closeSelectedAccount,
            isLoading: controller.isProcessing.value,
          ),
        ],
      );
    });
  }
}

class _ClosedList extends StatelessWidget {
  const _ClosedList({required this.controller});

  final ClosedAccountsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          AppSearchBar(
            controller: controller.searchController,
            hintText: 'Search by account number or name',
            onChanged: controller.filterClosed,
          ),
          const SizedBox(height: 12),
          ...controller.closedAccounts.map(
            (account) => Card(
              child: ListTile(
                title: Text('${account.accountName} (${account.accountNumber})'),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(text: 'Total: '),
                      TextSpan(
                        text: '${Helpers.formatAmount(account.totalAmount)}\n',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: 'Created: ${Helpers.formatDate(account.creationDate)}',
                      ),
                    ],
                  ),
                ),
                isThreeLine: true,
                onTap: () => Get.toNamed(
                  AppRoutes.accountDetails,
                  arguments: account.accountNumber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
