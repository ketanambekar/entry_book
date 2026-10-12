import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/entry_feed_item.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_search_bar.dart';
import 'controller.dart';

class EntriesView extends GetView<EntriesController> {
  const EntriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entries')),
      body: SafeArea(
        child: Obx(() {
          final entries = controller.entries;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
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
      ),
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

