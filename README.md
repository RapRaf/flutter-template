# Flutter Template

This is new Flutter template project is designed to provide a simple starting point for Flutter applications, with core features already implemented out of the box.

## Features

- `Themes`: Supports dark, light, and system themes.
- `Localization`: Handles language changes between Italian and English. For each language supported by the app,
  there is a corresponding .arb file in `./lib/localization`.
- `Authentication`: Login and logout functionality is already implemented (ajust the .env file and the requests).

This template includes two main ChangeNotifier classes for managing app state and providing essential services:

- `AuthProvider` is the primary class responsible for handling the low-level state of the app. It includes:

  1. `Http Service`: Manages a queue of HTTP requests, ensuring efficient and organized network communication.

  2. `Storage Service`:
     Fetches and stores persistent app state such as tokens and the currently logged-in user.

  3. `Snackbar Service`: Allows triggering snackbar messages from anywhere in the app for user notifications. **(I have doubts on this topic, maybe it is not necessary centralize it but convenient)**

  4. `Fingerprint Service`:
     Provides authentication services using fingerprint, face ID, passcode, etc., to protect user data. This service is accessible throughout the project.

- `AppProvider` is mounted lower in the widget tree and is activated once the login is successful and all necessary data is fetched and ready for use.

## GENERATE LOCALIZATIONS
flutter pub add intl:any

## Contributing

Contributions are welcome! Your help is precious.