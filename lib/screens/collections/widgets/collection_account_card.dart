import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';

import 'package:entry_book/data/accounts/account.dart';

class CollectionAccountCard extends StatelessWidget {
  const CollectionAccountCard({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.name,
            style: AppTextStyles.subtitleS.semiBold.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Account ${account.number}',
            style: AppTextStyles.bodyM.medium.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            account.hasPendingInstalment
                ? 'Instalment pending'
                : 'No pending instalment',
            style: AppTextStyles.bodyS.medium.copyWith(
              color: account.hasPendingInstalment
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
