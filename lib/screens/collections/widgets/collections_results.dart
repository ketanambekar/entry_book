import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/collections/collections_controller.dart';
import 'package:entry_book/screens/collections/widgets/collection_account_card.dart';

class CollectionsResults extends GetView<CollectionsController> {
  const CollectionsResults({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final accounts = controller.filteredAccounts;
      return ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: accounts.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isSearching
                      ? 'Search results (${accounts.length})'
                      : 'Pending instalments (${accounts.length})',
                  style: AppTextStyles.subtitleM.semiBold.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sample data',
                  style: AppTextStyles.bodyS.medium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (accounts.isEmpty) ...[
                  const SizedBox(height: 32),
                  Text(
                    controller.isSearching
                        ? 'No accounts found. Try another name or number.'
                        : 'No pending instalments.',
                    style: AppTextStyles.bodyL.medium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          }
          return CollectionAccountCard(account: accounts[index - 1]);
        },
      );
    });
  }
}
