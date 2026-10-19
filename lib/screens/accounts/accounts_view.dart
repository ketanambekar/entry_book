import 'package:flutter/material.dart';

import 'package:entry_book/screens/accounts/widgets/accounts_list.dart';

class AccountsView extends StatelessWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All accounts'), centerTitle: false),
      body: const SafeArea(child: AccountsList()),
    );
  }
}
