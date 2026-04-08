import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/account_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/helpers.dart';
import 'controller.dart';

class AccountListView extends GetView<AccountListController> {
  const AccountListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Listing')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.dailyEntry),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
      body: Obx(
        () {
          if (controller.accounts.isEmpty) {
            return const Center(child: Text('No accounts found'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortAscending: controller.ascending.value,
              columns: <DataColumn>[
                DataColumn(
                  label: const Text('Account No'),
                  onSort: (_, __) => controller.sortBy(AccountSortField.number),
                ),
                DataColumn(
                  label: const Text('Account Name'),
                  onSort: (_, __) => controller.sortBy(AccountSortField.name),
                ),
                DataColumn(
                  label: const Text('Total Amount'),
                  onSort: (_, __) => controller.sortBy(AccountSortField.amount),
                ),
                DataColumn(
                  label: const Text('Status'),
                  onSort: (_, __) => controller.sortBy(AccountSortField.status),
                ),
              ],
              rows: controller.accounts
                  .map(
                    (AccountModel account) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Text(account.accountNumber),
                          onTap: () => Get.toNamed(
                            AppRoutes.accountDetails,
                            arguments: account.accountNumber,
                          ),
                        ),
                        DataCell(Text(account.accountName)),
                        DataCell(Helpers.amountText(account.totalAmount)),
                        DataCell(Text(account.status.name.toUpperCase())),
                      ],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
