@echo off
rem Wrapper around `flutter` that bumps the pubspec version before run/build.
setlocal EnableDelayedExpansion
cd /d "%~dp0.."

set "CMD=%~1"
if /I not "%CMD%"=="run" if /I not "%CMD%"=="build" goto runflutter

rem Build number only increases on release builds, never on `run`.
set RELEASE=0
if /I "%CMD%"=="build" (
  set RELEASE=1
  for %%A in (%*) do (
    if /I "%%~A"=="--debug" set RELEASE=0
    if /I "%%~A"=="--profile" set RELEASE=0
  )
)

if !RELEASE!==1 (
  call dart run tool/bump_version.dart --release || exit /b 1
) else (
  call dart run tool/bump_version.dart || exit /b 1
)

:runflutter
call flutter %*
