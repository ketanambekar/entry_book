import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';

import 'package:entry_book/data/accounts/account.dart';

class AccountListItem extends StatelessWidget {
  const AccountListItem({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final whole = localizations.formatDecimal(
      account.openingBalancePaise ~/ 100,
    );
    final fraction = (account.openingBalancePaise % 100).toString().padLeft(
      2,
      '0',
    );
    final secondaryStyle = AppTextStyles.bodyS.medium.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            account.name,
            style: AppTextStyles.subtitleS.semiBold.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text('Account ${account.number}', style: secondaryStyle),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 20,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Opening balance', style: secondaryStyle),
                  const SizedBox(height: 4),
                  Text(
                    '₹$whole.$fraction',
                    style: AppTextStyles.subtitleS.semiBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created', style: secondaryStyle),
                  const SizedBox(height: 4),
                  Text(
                    localizations.formatMediumDate(account.createdAt),
                    style: AppTextStyles.bodyM.medium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
