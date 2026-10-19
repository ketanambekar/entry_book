import 'package:flutter/material.dart';
import 'package:entry_book/screens/withdrawal/widgets/withdrawal_form.dart';

class WithdrawalView extends StatelessWidget {
  const WithdrawalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Withdrawal calculator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const WithdrawalForm(),
            ),
          ),
        ),
      ),
    );
  }
}
