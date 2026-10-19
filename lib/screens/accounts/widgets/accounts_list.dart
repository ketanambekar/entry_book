import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/accounts/accounts_controller.dart';
import 'package:entry_book/widgets/accounts/account_list_item.dart';

class AccountsList extends GetView<AccountsController> {
  const AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          itemCount: controller.accounts.length + 1,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: colors.outlineVariant),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${controller.accounts.length} accounts · Sample data · Newest first',
                  style: AppTextStyles.bodyS.medium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              );
            }
            return AccountListItem(account: controller.accounts[index - 1]);
          },
        ),
      ),
    );
  }
}
