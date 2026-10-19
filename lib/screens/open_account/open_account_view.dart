import 'package:flutter/material.dart';

import 'package:entry_book/screens/open_account/widgets/open_account_form.dart';
import 'package:entry_book/screens/open_account/widgets/account_review_action.dart';

class OpenAccountView extends StatelessWidget {
  const OpenAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open an account'), centerTitle: false),
      bottomNavigationBar: const AccountReviewAction(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const OpenAccountForm(),
            ),
          ),
        ),
      ),
    );
  }
}
