import 'package:flutter/material.dart';

import 'package:entry_book/screens/collections/widgets/collections_results.dart';
import 'package:entry_book/screens/collections/widgets/collections_search.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collections'), centerTitle: false),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: CollectionsSearch(),
                ),
                Expanded(child: CollectionsResults()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
