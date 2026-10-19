import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/dashboard/dashboard_controller.dart';

class OpenAccountCard extends GetView<DashboardController> {
  const OpenAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppAlertCard(
      title: 'Open an account',
      illustration: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.person_add_alt_1_outlined,
          size: 28,
          color: colors.primary,
        ),
      ),
      action: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AppButton(
          label: 'Open',
          variant: AppButtonVariant.tertiary,
          size: AppButtonSize.large,
          expanded: true,
          onPressed: controller.openAccount,
        ),
      ),
    );
  }
}
