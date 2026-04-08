import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/account_model.dart';
import '../../utils/helpers.dart';
import 'controller.dart';

class AccountDetailsView extends GetView<AccountDetailsController> {
  const AccountDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
        actions: <Widget>[
          IconButton(
            onPressed: controller.promptEditAccount,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Account',
          ),
        ],
      ),
      body: Obx(() {
        final account = controller.account.value;
        if (account == null) {
          return const Center(child: Text('Account not found'));
        }

        final entries = account.entries.reversed.toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isDark
                      ? <Color>[scheme.surfaceContainerHighest, scheme.surfaceContainer]
                      : <Color>[scheme.primary, scheme.secondary],
                ),
                border: Border.all(
                  color: isDark ? scheme.outlineVariant : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    account.accountName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: isDark ? scheme.onSurface : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A/C ${account.accountNumber}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: isDark
                              ? scheme.onSurface.withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      Chip(
                        label: Text(
                          account.status == AccountStatus.active ? 'ACTIVE' : 'CLOSED',
                        ),
                        backgroundColor: account.status == AccountStatus.active
                            ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
                            : (isDark ? Colors.orange.shade900 : Colors.orange.shade100),
                      ),
                      Chip(
                        label: Text('Created ${Helpers.formatDate(account.creationDate)}'),
                        backgroundColor: isDark
                            ? scheme.surfaceContainerHighest
                            : Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Helpers.amountText(
                    account.totalAmount,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: isDark ? Colors.green.shade300 : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MetricCard(
                    title: 'Total Entries',
                    value: '${controller.totalEntries}',
                    icon: Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: 'Avg Entry',
                    valueWidget: Helpers.amountText(controller.averageEntryAmount),
                    icon: Icons.auto_graph,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Latest Entry Date'),
                subtitle: Text(
                  controller.latestEntryDate == null
                      ? 'No entries available'
                      : DateFormat('dd MMM yyyy, hh:mm a').format(controller.latestEntryDate!),
                ),
              ),
            ),
            if (account.isClosed && account.closingAmount != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Closing Amount'),
                  trailing: Helpers.amountText(account.closingAmount!),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: account.isClosed ? null : controller.openAddEntry,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Entry'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: account.isClosed ? null : controller.openCloseAccountFlow,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Close Account'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Entries', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No entries yet for this account.'),
                ),
              )
            else
              ...entries.asMap().entries.map((item) {
                final index = item.key + 1;
                final entry = item.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isDark ? scheme.surfaceContainerHighest : scheme.primaryContainer,
                      child: Text('$index'),
                    ),
                    title: Helpers.amountText(entry.amount),
                    subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(entry.date)),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (_) => const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(value: 'edit', child: Text('Edit Entry')),
                        PopupMenuItem<String>(value: 'delete', child: Text('Delete Entry')),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          controller.promptEditEntry(entry);
                        } else if (value == 'delete') {
                          controller.deleteEntry(entry);
                        }
                      },
                    ),
                  ),
                );
              }),
          ],
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    this.value,
    this.valueWidget,
    required this.icon,
  });

  final String title;
  final String? value;
  final Widget? valueWidget;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 6),
            valueWidget ??
                Text(
                  value ?? '-',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
          ],
        ),
      ),
    );
  }
}
