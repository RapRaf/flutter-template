import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChangeTheme extends StatelessWidget {
  const ChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: DropdownButton<ThemeMode>(
        // Read the selected themeMode from the controller
        value: context.watch<AuthProvider>().theme,
        // Call the updateThemeMode method any time the user selects a theme.
        onChanged: (ThemeMode? value) {
          if (value != null) {
            context.read<AuthProvider>().setTheme(newTheme: value);
          }
        },
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
    );
  }
}
