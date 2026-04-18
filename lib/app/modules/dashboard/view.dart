import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers.dart';
import 'controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Book'),
      ),
      body: _HomeTab(controller: controller),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 760;
          final gap = isCompact ? 7.0 : 10.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                children: <Widget>[
                  SizedBox(height: gap),
                  Expanded(
                    flex: isCompact ? 10 : 10,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _StatBoxCard(
                            label: 'No Of Deposits',
                            value: '${controller.summary['totalEntries'] ?? 0}',
                            onTap: controller.openEntries,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _StatBoxCard(
                            label: 'Deposit Amount',
                            value: Helpers.formatAmount(
                              (controller.summary['totalBalance'] ?? 0).toDouble(),
                            ),
                            onTap: controller.openReports,
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: _StatBoxCard(
                            label: 'Account Opened',
                            value: '${controller.summary['activeAccounts'] ?? 0}',
                            onTap: controller.openAccounts,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: gap),
                  SizedBox(
                    height: isCompact ? 46 : 50,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: controller.openAccount,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Open Account'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  Expanded(
                    flex: isCompact ? 40 : 42,
                    child: LayoutBuilder(
                      builder: (context, gridConstraints) {
                        const itemCount = 6;
                        const crossAxisCount = 2;
                        final rowCount = (itemCount / crossAxisCount).ceil();
                        final tileHeight = (gridConstraints.maxHeight - (rowCount - 1) * gap) / rowCount;
                        final isDense = isCompact || tileHeight < 130;

                        return GridView(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: gap,
                            crossAxisSpacing: gap,
                            mainAxisExtent: tileHeight > 0 ? tileHeight : 1,
                          ),
                          children: <Widget>[
                            _GridNavigationCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Pigmy Deposit',
                              onTap: controller.openDailyEntry,
                              dense: isDense,
                            ),
                            _GridNavigationCard(
                              icon: Icons.account_balance_outlined,
                              label: 'Balance Enquiry',
                              onTap: controller.openReports,
                              dense: isDense,
                            ),
                            _GridNavigationCard(
                              icon: Icons.receipt_long_outlined,
                              label: 'Mini Statement',
                              onTap: controller.openEntries,
                              dense: isDense,
                            ),
                            _GridNavigationCard(
                              icon: Icons.assessment_outlined,
                              label: 'Report',
                              onTap: controller.openReports,
                              dense: isDense,
                            ),
                            _GridNavigationCard(
                              icon: Icons.people_outline,
                              label: 'Accounts',
                              onTap: controller.openAccounts,
                              dense: isDense,
                            ),
                            _GridNavigationCard(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onTap: controller.openSettings,
                              dense: isDense,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }
}

class _StatBoxCard extends StatelessWidget {
  const _StatBoxCard({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
            width: 1.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridNavigationCard extends StatelessWidget {
  const _GridNavigationCard({
    required this.icon,
    required this.label,
    this.onTap,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final iconSize = dense ? 30.0 : 36.0;
    final textGap = dense ? 8.0 : 12.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: textGap),
            Text(
              label,
              style: (dense ? Theme.of(context).textTheme.labelMedium : Theme.of(context).textTheme.labelLarge)?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

