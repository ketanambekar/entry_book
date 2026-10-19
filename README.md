# Daily Collection

Daily Collection app. Theme, fonts, icons, widgets and the playground come from
[entry_ui](../entry_ui): `import 'package:entry_ui/entry_ui.dart';`.
After pushing entry_ui to GitHub, switch the `path:` dependency in
`pubspec.yaml` to `git:`.

## Application identifiers

- Android application ID and namespace: `com.krdlabs.daily_collection`.
- iOS and macOS bundle ID: `com.krdlabs.daily-collection` (Apple does not allow
  underscores). Test targets append `.RunnerTests`.
- The Dart package name remains `entry_book`.

## Screens and startup

- Native macOS opens the shared UI playground.
- Other platforms open the phone-number login screen.
- Login groups its branding and form near the top with consistent spacing,
  uses the mobile screen width (capped at 480 on larger screens), and keeps the
  version footer at the bottom. Content scrolls on small screens and with the
  keyboard open.
- The login footer shows the installed app version and build number, read from
  platform package information so automatic version bumps are reflected.
- Feature screens live in `lib/screens/<feature>/`, with their GetX controller
  and route binding alongside the view.
- Keep screen views focused on layout and composition. Put feature-specific
  UI components in the feature's `widgets/` folder; login separates its header,
  phone form/input, OTP form, and version footer this way. Validation and flow
  state remain in the controller.
- `lib/screens/login/` contains a fixed `+91` prefix, a 10-digit phone input,
  and six-digit OTP UI with local validation only.
  It does not send SMS, verify codes, or create authenticated
  sessions. An authentication repository can be added when a backend is ready.
- After entering a phone number and any six-digit OTP, **Continue to demo**
  opens `/dashboard`. This explicitly labelled preview does not authenticate.
  Native macOS still starts at the playground.
- Dashboard keeps the themed welcome header and two action sections using
  shared `AppMiniCard.icon` tiles: Transaction (Collections, Reports) and
  Customer & account opening (Open account). Reports shows an explicit
  coming-soon message; Open account opens `/open-account`.
  Collections opens `/collections`: pending instalments by default, or all
  matching accounts when searching by name (case-insensitive) or account
  number (including partial matches). Clearing search restores pending only.
  Instalment statuses are explicit sample data, unrelated to opening balances.
  Balance summaries and recent accounts are hidden from the dashboard for now.
  The account form groups required and optional details in separate
  cards with a bottom Review details action and a brief unsaved-demo notice.
- Account opening requires a holder name and a manually entered, digits-only
  account number (no fixed length). The optional INR opening amount defaults
  to 0 and accepts non-negative values with up to two decimal places. The
  optional phone number uses `+91` and ten digits.
- **Review details** only previews the validated form. No account is opened
  or persisted; leaving the form discards its contents.
- The existing `/accounts` route retains the full sample list, newest first.
  Both screens share the account row: name, number, opening balance in INR,
  and created date. These labelled samples are not live balances or saved
  accounts; opening an account in the demo does not modify them.

## Withdrawal estimates

- Full current principal balance earns simple interest from account opening.
  This is a daily/monthly collection product, not a fixed deposit: principal
  is the sum of collections received up to withdrawal, including varied/zero
  entries. The account age sets the rate on the entire total, even recently
  received collections; deposits are not aged individually.
  Before six completed calendar months: no interest, deduct 3% of principal.
  From six months: interest = principal × completed months / 300, no deduction.
  This gives 2% at six months, 3% at nine, and 4% at twelve; interest continues
  beyond twelve months without compounding.
- Shorter-month anniversaries use that month's last day (31 August to
  28 February is six months in a non-leap year). Time of day is ignored.
- Money uses integer paise with exact arithmetic; interest/deduction is rounded
  once to nearest paise, half up. Displayed percentage rates may be rounded.
- Open account and review show a live 1–12 month payout schedule based on the
  opening collection only, excluding future collections. Each schedule row
  applies an account-age rate to the same entered total, not a projection of
  future contributions. Dashboard's Withdrawal calculator accepts varying
  collection amounts (or a known total entered once) and both dates, and shows the
  full principal/interest/deduction/payout breakdown. This is an estimate only;
  it does not make withdrawals, track deposits, or persist financial records.
- Months 1–5 each show the 3% deduction. Any non-negative principal is supported,
  including ₹0, ₹100, ₹200, ₹300, and amounts with up to two decimal places.

## Profile

- Tap the dashboard avatar to open `/profile`. Name and photo are kept only
  in memory for the demo session and cleared on logout or app restart.
- Profile keeps one Save action and compact Appearance/Logout rows. Tap the
  photo's camera badge for photo choices, or Appearance for theme choices;
  these options appear in bottom sheets rather than crowding the page.
- Choose an image from the gallery/files, or use the camera on Android/iOS
  (web support depends on the browser). Desktop camera capture is disabled.
- Appearance uses the existing `ThemeController`: System, Light, and Dark.
  Theme preference persists using the existing theme storage.
- Profile shows the installed version/build. Logout clears the demo profile
  and replaces navigation with login; there is no backend session to revoke.
- Photo selection requires a full app restart after installing the plugin.

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
