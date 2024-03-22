import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_template/http_requests/ping.dart';
import 'package:flutter_template/src/settings/settings_controller.dart';
import 'package:restart_app/restart_app.dart';
import 'model/http_request.dart';
import 'store_controller.dart';
import 'devices/device_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppController {
  AppController();

  static late String email, token, type;
  static final List<HttpRequest> requestList = List.empty(growable: true);
  static late SettingsController settingsController;
  static late bool isLogged;

  static Future<void> initApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: "lib/.env");

    String? id = await StoreController().getId();

    if (id == null || id.isEmpty) {
      await DeviceInfo().initPlatformState();
    }

    email = await StoreController().getEmail() ?? "";
    token = await StoreController().getToken() ?? "";
    type = await StoreController().getType() ?? "";
    isLogged = await isLoggedIn();
  }

  static Future<bool> isLoggedIn() async {
    if (token.isEmpty) {
      return false;
    }

    // Create a new Completer
    final Completer completer = Completer<bool>();

    Ping ping = Ping(
      responseListener: () {
        completer.complete(true);
      },
      errorListener: () {
        completer.complete(false);
      },
    );

    ping.run();

    bool response = await completer.future;

    return response;
  }

  static void restart() async {
    await Future.delayed(const Duration(milliseconds: 300));

    Restart.restartApp();
  }
}
