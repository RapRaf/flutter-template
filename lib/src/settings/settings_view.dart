import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_template/app_controller.dart';
import 'package:flutter_template/http_requests/log_out.dart';
import 'package:flutter_template/route_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = AppRoutes.settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: AppController.settingsController.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: AppController.settingsController.updateThemeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(AppLocalizations.of(context)!.sys_theme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(AppLocalizations.of(context)!.ligth_theme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(AppLocalizations.of(context)!.dark_theme),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: DropdownButton<String>(
              value: AppController.settingsController.language,
              onChanged: AppController.settingsController.updateLanguage,
              items: [
                DropdownMenuItem(
                  value: 'en,US',
                  child: Text(AppLocalizations.of(context)!.english),
                ),
                DropdownMenuItem(
                  value: 'it,IT',
                  child: Text(AppLocalizations.of(context)!.italian),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FloatingActionButton(
              onPressed: () {
                logOut(context);
              },
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          )
        ],
      ),
    );
  }

  void logOut(BuildContext context) async {
    LogOut logOut = LogOut(
      responseListener: () {
        debugPrint("Logged Out");
        Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.root.toString(), (Route<dynamic> route) => false);
      },
      errorListener: () {},
    );

    logOut.run();
  }
}
