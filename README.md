# entry_book

Entry Book app. Theme, fonts, icons, widgets and the playground come from
[entry_ui](../entry_ui): `import 'package:entry_ui/entry_ui.dart';`.
After pushing entry_ui to GitHub, switch the `path:` dependency in
`pubspec.yaml` to `git:`.

## Automatic versioning

The `version:` in `pubspec.yaml` (`major.minor.patch+build`) is bumped
automatically on every run/build:

- Every run or build increments **patch**.
- When patch reaches 100, **minor** is incremented and patch resets to 0.
- Only release **builds** also increment the **build** number (never `run`).

Use the wrapper instead of calling `flutter` directly:

```sh
./tool/flutter.sh run                # 1.0.0+1 -> 1.0.1+1
./tool/flutter.sh run --release      # 1.0.1+1 -> 1.0.2+1
./tool/flutter.sh build apk          # release by default -> 1.0.3+2
./tool/flutter.sh build apk --debug  # 1.0.3+2 -> 1.0.4+2
```

On Windows use `tool\flutter.bat`. The VS Code launch configurations in
`.vscode/launch.json` bump the version automatically via `preLaunchTask`.
To bump manually: `dart run tool/bump_version.dart [--release]`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
