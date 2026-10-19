import 'dart:io';

/// Bumps the `version:` in pubspec.yaml.
///
/// Every invocation increments the patch number. When the patch reaches 100,
/// the minor number is incremented and the patch resets to 0.
/// With `--release`, the build number is incremented as well.
void main(List<String> args) {
  final release = args.contains('--release');
  final pubspec = File.fromUri(Platform.script.resolve('../pubspec.yaml'));
  final content = pubspec.readAsStringSync();

  final versionLine = RegExp(
    r'^version:\s*(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?[ \t]*$',
    multiLine: true,
  );
  final match = versionLine.firstMatch(content);
  if (match == null) {
    stderr.writeln('Could not find a valid "version:" line in pubspec.yaml');
    exit(1);
  }

  final oldVersion = match.group(0)!.substring('version:'.length).trim();
  final major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!) + 1;
  var build = int.parse(match.group(4) ?? '0');

  if (patch >= 100) {
    minor++;
    patch = 0;
  }
  if (release) build++;

  final newVersion = '$major.$minor.$patch+$build';
  pubspec.writeAsStringSync(
    content.replaceRange(match.start, match.end, 'version: $newVersion'),
  );
  stdout.writeln('Version bumped: $oldVersion -> $newVersion');
}
