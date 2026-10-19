import 'package:flutter/material.dart';

import 'package:entry_book/screens/profile/widgets/profile_form.dart';
import 'package:entry_book/screens/profile/widgets/profile_settings.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileForm(),
                  SizedBox(height: 24),
                  ProfileSettings(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
