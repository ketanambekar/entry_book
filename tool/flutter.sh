#!/usr/bin/env bash
# Wrapper around `flutter` that bumps the pubspec version before run/build.
# Usage: ./tool/flutter.sh run [args...] | ./tool/flutter.sh build <target> [args...]
set -euo pipefail

cd "$(dirname "$0")/.."

command="${1:-}"
if [[ "$command" == "run" || "$command" == "build" ]]; then
  # Build number only increases on release *builds*, never on `run`.
  release_build=false
  if [[ "$command" == "build" ]]; then
    # `flutter build` defaults to release mode when no mode flag is given.
    release_build=true
    for arg in "$@"; do
      case "$arg" in
        --debug|--profile) release_build=false ;;
      esac
    done
  fi

  if [[ "$release_build" == true ]]; then
    dart run tool/bump_version.dart --release
  else
    dart run tool/bump_version.dart
  fi
fi

exec flutter "$@"
