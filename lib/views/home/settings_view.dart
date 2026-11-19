import 'package:flutter/material.dart';
import 'package:flutter_template/components/change_language.dart';
import 'package:flutter_template/components/change_theme.dart';
import 'package:flutter_template/components/logout_button.dart';
import 'package:flutter_template/localization/app_localizations.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: Text(localizations.theme),
          trailing: const ChangeTheme(),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(localizations.language),
          trailing: const ChangeLanguage(),
        ),
        const Divider(),
        const Center(child: LogoutButton()),
      ],
    );
  }
}
