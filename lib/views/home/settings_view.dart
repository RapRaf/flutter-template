// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/components/change_language.dart';
import 'package:flutter_template/components/change_theme.dart';
import 'package:flutter_template/components/logout_button.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [ChangeTheme(), ChangeLanguage(), LogoutButton()],
    );
  }
}
