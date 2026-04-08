import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/account_model.dart';
import '../../data/models/entry_feed_item.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_search_bar.dart';
import 'controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(controller: controller),
      _EntriesTab(controller: controller),
      _AccountsTab(controller: controller),
      _ReportsTab(controller: controller),
      _SettingsTab(controller: controller),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentTabIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.currentTabIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Entries'),
            NavigationDestination(icon: Icon(Icons.people_outline), label: 'Accounts'),
            NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Reports'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: <Color>[
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome to Entry Book',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage accounts and entries from a single view',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: controller.openAccount,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Open an Account'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Existing Accounts'),
                trailing: Text(
                  '${controller.summary['totalAccounts'] ?? 0}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                onTap: controller.goToExistingAccountsPage,
              ),
            ),
            const SizedBox(height: 10),
            _SectionHeader(
              title: 'Recently Added Accounts',
              onViewMore: controller.goToAccountsTab,
            ),
            ...controller.recentAccounts.map(
              (a) => Card(
                child: ListTile(
                  title: Text(a.accountName),
                  subtitle: Text('A/C ${a.accountNumber}'),
                  trailing: Helpers.amountText(a.totalAmount),
                  onTap: () => controller.openAccountDetails(a.accountNumber),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SectionHeader(
              title: 'Recent Entries',
              onViewMore: controller.goToEntriesTab,
            ),
            ...controller.recentEntries.map(
              (e) => Card(
                child: ListTile(
                  title: Text('${e.accountName} (${e.accountNumber})'),
                  subtitle: Text(DateFormat('dd MMM yyyy - EEEE').format(e.date)),
                  trailing: Helpers.amountText(e.amount),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SummarySmallCard(
                    label: 'Active',
                    value: '${controller.summary['activeAccounts'] ?? 0}',
                    color: Colors.green,
                    onTap: controller.goToActiveAccountsTab,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummarySmallCard(
                    label: 'Closed',
                    value: '${controller.summary['closedAccounts'] ?? 0}',
                    color: Colors.orange,
                    onTap: controller.goToClosedAccountsTab,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntriesTab extends StatelessWidget {
  const _EntriesTab({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final entries = controller.entries;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Entries', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            AppSearchBar(
              controller: controller.entriesSearchController,
              hintText: 'Search by account name or number',
              onChanged: (value) => controller.entrySearch.value = value,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('No entries found')),
              )
            else
              ..._buildEntryTimeline(entries),
          ],
        );
      }),
    );
  }

  List<Widget> _buildEntryTimeline(List<EntryFeedItem> entries) {
    final widgets = <Widget>[];
    var index = 0;

    while (index < entries.length) {
      final item = entries[index];
      final currentDayKey = DateFormat('yyyy-MM-dd').format(item.date);
      final dayEntries = <EntryFeedItem>[];
      var dayTotal = 0.0;

      while (index < entries.length &&
          DateFormat('yyyy-MM-dd').format(entries[index].date) == currentDayKey) {
        dayEntries.add(entries[index]);
        dayTotal += entries[index].amount;
        index++;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  DateFormat('dd MMMM yyyy - EEEE').format(item.date),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Helpers.amountText(dayTotal),
            ],
          ),
        ),
      );

      for (final dayItem in dayEntries) {
        widgets.add(
          Card(
            child: ListTile(
              title: Text('${dayItem.accountName} (${dayItem.accountNumber})'),
              subtitle: Text(DateFormat('hh:mm a').format(dayItem.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Helpers.amountText(dayItem.amount),
                  PopupMenuButton<String>(
                    itemBuilder: (_) => const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(value: 'edit', child: Text('Edit Entry')),
                      PopupMenuItem<String>(value: 'delete', child: Text('Delete Entry')),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        controller.promptEditEntry(dayItem);
                      } else if (value == 'delete') {
                        controller.deleteEntry(dayItem);
                      }
                    },
                  ),
                ],
              ),
              onTap: () => controller.openAccountDetails(dayItem.accountNumber),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class _AccountsTab extends StatelessWidget {
  const _AccountsTab({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: controller.accountsTabInitialIndex.value,
      key: ValueKey<int>(controller.accountsTabInitialIndex.value),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppSearchBar(
                controller: controller.accountSearchController,
                hintText: 'Search account name or number',
                onChanged: (value) => controller.accountSearch.value = value,
              ),
            ),
            TabBar(
              onTap: (index) => controller.accountsTabInitialIndex.value = index,
              tabs: const <Tab>[
                Tab(text: 'Active Accounts'),
                Tab(text: 'Closed Accounts'),
              ],
            ),
            Expanded(
              child: Obx(
                () => TabBarView(
                  children: <Widget>[
                    _AccountsList(
                      accounts: controller.activeAccounts,
                      onTap: controller.openAccountDetails,
                      onEdit: controller.promptEditAccount,
                    ),
                    _AccountsList(
                      accounts: controller.closedAccounts,
                      onTap: controller.openAccountDetails,
                      onEdit: controller.promptEditAccount,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Reports', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _SummaryTile(
              title: 'Total Accounts',
              value: '${controller.summary['totalAccounts'] ?? 0}',
            ),
            _SummaryTile(
              title: 'Active Accounts',
              value: '${controller.summary['activeAccounts'] ?? 0}',
            ),
            _SummaryTile(
              title: 'Closed Accounts',
              value: '${controller.summary['closedAccounts'] ?? 0}',
            ),
            _SummaryTile(
              title: 'Total Balance',
              trailing: Helpers.amountText(
                (controller.summary['totalBalance'] ?? 0).toDouble(),
              ),
            ),
            _SummaryTile(
              title: 'Total Entries',
              value: '${controller.summary['totalEntries'] ?? 0}',
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: controller.isDownloadingReport.value
                  ? null
                  : controller.downloadReport,
              icon: controller.isDownloadingReport.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: const Text('Download Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settingsService;
    return SafeArea(
      child: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(controller.appName.value),
                subtitle: Text(controller.appVersion.value),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Theme Mode'),
                subtitle: Text(_themeLabel(settings.themeMode.value)),
                onTap: () => _showThemePicker(context, controller),
              ),
            ),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.view_stream_outlined),
                title: const Text('Compact Entries View'),
                value: settings.compactEntries.value,
                onChanged: controller.setCompactEntries,
              ),
            ),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.warning_amber_outlined),
                title: const Text('Confirm Before Closing Account'),
                value: settings.confirmBeforeClose.value,
                onChanged: controller.setConfirmBeforeClose,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                trailing: Text(controller.appVersion.value),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Import CSV Backup'),
                subtitle: const Text('Restore accounts and entries from CSV file'),
                trailing: controller.isImportingCsv.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: controller.isImportingCsv.value ? null : controller.importCsv,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.download_for_offline_outlined),
                title: const Text('Take Backup'),
                subtitle: const Text('Download all app data as CSV backup'),
                trailing: controller.isTakingBackup.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: controller.isTakingBackup.value ? null : controller.takeBackup,
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.update_outlined),
                title: const Text('Last Updated Time'),
                subtitle: Text(
                  controller.lastUpdatedAt == null
                      ? 'No data yet'
                      : DateFormat('dd MMM yyyy, hh:mm a').format(controller.lastUpdatedAt!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> _showThemePicker(
    BuildContext context,
    DashboardController controller,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('System Default'),
                onTap: () => Navigator.of(context).pop(ThemeMode.system),
              ),
              ListTile(
                title: const Text('Light'),
                onTap: () => Navigator.of(context).pop(ThemeMode.light),
              ),
              ListTile(
                title: const Text('Dark'),
                onTap: () => Navigator.of(context).pop(ThemeMode.dark),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await controller.setThemeMode(selected);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewMore});

  final String title;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        IconButton(
          onPressed: onViewMore,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _SummarySmallCard extends StatelessWidget {
  const _SummarySmallCard({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountsList extends StatelessWidget {
  const _AccountsList({
    required this.accounts,
    required this.onTap,
    required this.onEdit,
  });

  final List<AccountModel> accounts;
  final ValueChanged<String> onTap;
  final ValueChanged<AccountModel> onEdit;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const Center(child: Text('No accounts found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Card(
          child: ListTile(
            title: Text(account.accountName),
            subtitle: Text(
              'A/C ${account.accountNumber}\n${account.status.name.toUpperCase()}',
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Helpers.amountText(account.totalAmount),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(account);
                    }
                  },
                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'edit', child: Text('Edit Account')),
                  ],
                ),
              ],
            ),
            onTap: () => onTap(account.accountNumber),
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    this.value,
    this.trailing,
  });

  final String title;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: trailing ??
            Text(
              value ?? '-',
              style: Theme.of(context).textTheme.titleLarge,
            ),
      ),
    );
  }
}
