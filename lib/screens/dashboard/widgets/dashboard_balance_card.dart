import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/dashboard/dashboard_controller.dart';

class DashboardBalanceCard extends GetView<DashboardController> {
  const DashboardBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final paise = controller.totalOpeningBalancePaise;
    final whole = localizations.formatDecimal(paise ~/ 100);
    final fraction = (paise % 100).toString().padLeft(2, '0');

    return AppOverviewCard(
      title: 'Accounts',
      columns: 1,
      items: [
        AppOverviewItem('Opening balance · Sample data', '₹$whole.$fraction'),
        AppOverviewItem('Total accounts', '${controller.accounts.length}'),
      ],
    );
  }
}
