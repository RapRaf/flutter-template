import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';

class SnackBarService {
  AuthProvider authProvider;

  SnackBarService({required this.authProvider});

  SnackBar snackbar(dynamic message) {
    return SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
      elevation: 10,
      content: Text(
        message.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      action: SnackBarAction(
          label: "Close",
          onPressed: () => authProvider.scaffoldMessengerKey.currentState
              ?.removeCurrentSnackBar()),
    );
  }

  void showSnackBar(message) {
    authProvider.scaffoldMessengerKey.currentState
        ?.showSnackBar(snackbar(message));
  }

  void removeSnackBar() {
    authProvider.scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
  }

  void hideSnackBar() {
    authProvider.scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }
}
