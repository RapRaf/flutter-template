# Flutter Template

This Flutter template project is designed to provide a simple starting point for Flutter applications, with core features already implemented out of the box.

## Requirements

- Flutter **3.41.6** or newer (Dart 3.11+)
- Android: minSdk 24, AGP 8.12.1, Kotlin 2.2.20, Gradle 8.14, JDK 17
- iOS 13.0+ / macOS 10.15+

## Features

- `Themes`: Supports dark, light, and system themes.
- `Localization`: Handles language changes between Italian and English. For each language supported by the app,
  there is a corresponding .arb file in `./lib/localization`; the language picker is built from those files automatically.
- `Authentication`: Login and logout functionality is already implemented (adjust the .env file and the requests).
  Saved accounts can log in again with fingerprint / face / device PIN.

This template includes two main ChangeNotifier classes for managing app state and providing essential services:

- `AuthProvider` is the primary class responsible for handling the low-level state of the app. It includes:

  1. `Http Service`: Manages a serial queue of HTTP requests (one in flight at a time, in order).
     Network errors and timeouts never block the queue; `401` closes the session (or logs in again when
     "keep logged" is enabled); `403` refreshes the session token and retries once; a ping keeps the session alive.

  2. `Storage Service`:
     Fetches and stores persistent app state such as tokens and the currently logged-in user, in the platform secure storage.

  3. `Snackbar Service`: Allows triggering snackbar messages from anywhere in the app for user notifications.

  4. `Fingerprint Service`:
     Provides authentication services using fingerprint, face ID, passcode, etc., to protect user data. This service is accessible throughout the project.

- `AppProvider` holds the state of the logged-in part of the app (e.g. the selected tab) and is reset every time
  the user leaves the logged-in state: add your session data there and clear it in `_reset()`.

### App state

`AuthProvider.loginState` drives the root page:

| `LoginState` | Page | When |
|---|---|---|
| `loading` | `LoadingScreen` | app start / after login: the saved token is checked with a ping |
| `loggedOut` | `AccessView` | no token, token refused, logout, session expired |
| `loggedIn` | `MainActivity` | ping OK |

Logout is immediate (also offline): pending requests are dropped and the server is notified on a best-effort basis.

Prefer `context.select` over `context.watch` on `AuthProvider`, because it also notifies on every request queue change:

```dart
final theme = context.select<AuthProvider, ThemeMode>((p) => p.theme);
```

## SETUP

```bash
cp lib/.env.example lib/.env
```

Adjust the ENV variables (see the comments in `lib/.env.example`) and get dependencies:

```bash
flutter pub get
```

> **Warning:** `lib/.env` is bundled in plain text inside the app. Use it only for public configuration
> (hosts, ports...), never for secrets.

### Supported platforms

The accepted platforms are listed in `supportedOperatingSystems` (`lib/providers/storage_service.dart`).
By default only Android and iOS are enabled.

## HTTP REQUESTS

Define the requests in `lib/http_requests/` and send them through the queue:

```dart
context.read<AuthProvider>().sendRequest(HttpEntry(
  method: 'GET',
  path: 'orders',
  params: {'page': 1},
  responseListener: (response) { /* response['data'] */ },
  // Optional: when omitted the error message is shown in a snackbar.
  errorListener: (response, statusCode) { /* statusCode 0 = network error */ },
));
```

Responses are expected as `{"status": true|false, "data": ...}`.

## GENERATE LOCALIZED TEXTS

Edit the `*.arb` files in `./lib/localization/`, then regenerate the Dart files
(this also happens automatically on `flutter pub get` / `flutter run`):

```bash
flutter gen-l10n
```

and use them like this:

```dart
import 'package:flutter_template/localization/app_localizations.dart';

print(AppLocalizations.of(context)!.click_to_add);
```

To add a language, create `app_xx.arb` (and optionally `assets/images/flags/XX.png`).

## ANDROID RELEASE BUILD

```bash
cp android/key.properties.example android/key.properties
```

Fill in the keystore data. Without `android/key.properties` the release build is signed with the
**debug** key (fine for `flutter run --release`, not for the Play Store).
Remember also to change `applicationId` / `namespace` in `android/app/build.gradle.kts`.

## TESTS

```bash
flutter test
```

## Contributing

Contributions are welcome! Your help is precious.
