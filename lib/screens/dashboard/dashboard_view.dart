import 'package:flutter/material.dart';
import 'package:entry_book/screens/dashboard/widgets/dashboard_intro.dart';
import 'package:entry_book/screens/dashboard/widgets/dashboard_actions.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardIntro(),
                  SizedBox(height: 24),
                  DashboardActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
