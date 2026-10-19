import 'package:flutter/material.dart';

import 'package:entry_book/app/app.dart';

Future<void> main() async {
  await App.init();
  runApp(const App());
}
