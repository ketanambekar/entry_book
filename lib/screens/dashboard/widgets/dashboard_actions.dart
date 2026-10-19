import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/dashboard/dashboard_controller.dart';
import 'package:entry_book/screens/dashboard/widgets/dashboard_action_tile.dart';

class DashboardActions extends GetView<DashboardController> {
  const DashboardActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionSection(
          title: 'Transaction',
          children: [
            DashboardActionTile(
              label: 'Collections',
              icon: Icons.payments_outlined,
              onTap: controller.showCollections,
            ),
            DashboardActionTile(
              label: 'Reports',
              icon: Icons.assessment_outlined,
              onTap: controller.showReports,
            ),
            DashboardActionTile(
              label: 'Withdrawal calculator',
              icon: Icons.calculate_outlined,
              onTap: controller.showWithdrawalCalculator,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ActionSection(
          title: 'Customer & account opening',
          children: [
            DashboardActionTile(
              label: 'Open account',
              icon: Icons.person_add_alt_1_outlined,
              onTap: controller.openAccount,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyL.semiBold.copyWith(
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: children),
        ],
      ),
    );
  }
}
