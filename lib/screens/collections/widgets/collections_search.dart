import 'package:flutter/material.dart';
import 'package:entry_ui/entry_ui.dart';
import 'package:get/get.dart';

import 'package:entry_book/screens/collections/collections_controller.dart';

class CollectionsSearch extends GetView<CollectionsController> {
  const CollectionsSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppInput(
        label: 'Search accounts',
        hint: 'Account name or number',
        controller: controller.searchController,
        prefixIcon: const Icon(Icons.search_rounded),
        textInputAction: TextInputAction.search,
        onChanged: controller.updateSearch,
        suffixIcon: controller.query.value.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: controller.clearSearch,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}
