import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/dashboard/dashboard_controller.dart';
import 'package:entry_book/widgets/accounts/account_list_item.dart';

class RecentAccountsCard extends GetView<DashboardController> {
  const RecentAccountsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accounts = controller.recentAccounts;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recent accounts',
            style: AppTextStyles.subtitleM.semiBold.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sample data · Newest first',
            style: AppTextStyles.bodyS.medium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          for (var index = 0; index < accounts.length; index++) ...[
            AccountListItem(account: accounts[index]),
            if (index < accounts.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
          if (controller.accounts.length > accounts.length) ...[
            const SizedBox(height: 8),
            AppButton(
              label: 'Show more',
              variant: AppButtonVariant.tertiary,
              size: AppButtonSize.large,
              expanded: true,
              onPressed: controller.showAllAccounts,
            ),
          ],
        ],
      ),
    );
  }
}
