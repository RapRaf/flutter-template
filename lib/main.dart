import 'package:flutter/material.dart';
import 'package:flutter_template/app_controller.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  await AppController.initApp();

  AppController.settingsController = SettingsController(SettingsService());

  await AppController.settingsController.loadSettings();

  runApp(const MyApp());
}
