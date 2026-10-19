---
description: "Use when writing or editing Dart/Flutter code: strict import style rule requiring package: imports instead of relative paths."
applyTo: "**/*.dart"
---
# Dart import rule (strict)

- Always import project files with the `package:` scheme: `import 'package:entry_book/app/app.dart';`
- Never use relative imports such as `import 'app/app.dart';`, `import '../foo.dart';` or `import '../../bar/baz.dart';`.
- This also applies to `export` and `part` directives.
- Enforced by the `always_use_package_imports` lint (set to `error`) in `analysis_options.yaml`.
