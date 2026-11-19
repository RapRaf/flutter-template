import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';

class SnackBarService {
  AuthProvider authProvider;

  SnackBarService({required this.authProvider});

  SnackBar snackbar(String message) {
    return SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
      elevation: 10,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      action: SnackBarAction(
        label: authProvider.localizations.close,
        textColor: Colors.white,
        onPressed: () => authProvider.scaffoldMessengerKey.currentState
            ?.removeCurrentSnackBar(),
      ),
    );
  }

  /// [message] can be a `String` or a server response
  /// (`{"status": ..., "data": ...}` / `{"message": ...}`).
  void showSnackBar(Object? message) {
    final text = messageFrom(message);
    if (text.isEmpty) return;
    authProvider.scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackbar(text));
  }

  void removeSnackBar() {
    authProvider.scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
  }

  void hideSnackBar() {
    authProvider.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  /// Extracts a human readable message from a string or a server response.
  static String messageFrom(Object? message) {
    if (message == null) return '';
    if (message is String) return message;
    if (message is Map) {
      final main = message['message'] ?? message['data'];
      // e.g. validation errors: {"email": ["is invalid"], ...}
      return main != null ? messageFrom(main) : messageFrom(message.values);
    }
    if (message is Iterable) {
      return message.map(messageFrom).where((m) => m.isNotEmpty).join('\n');
    }
    return message.toString();
  }
}
