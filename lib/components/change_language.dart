import 'package:flutter/material.dart';
import 'package:flutter_template/components/select_language.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Language picker. The list comes from the `.arb` files, so adding a new
/// language only requires a new `app_xx.arb` (and optionally a flag in
/// `assets/images/flags/XX.png` plus a name in [languageNames]).
class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key});

  /// Native name of each language.
  static const Map<String, String> languageNames = {
    'en': 'English',
    'it': 'Italiano',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
  };

  @override
  Widget build(BuildContext context) {
    final language = context.select<AuthProvider, String>((p) => p.language);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: DropdownButton<String>(
        value: language,
        onChanged: (String? value) {
          if (value != null) {
            context.read<AuthProvider>().setLanguage(newLanguage: value);
          }
        },
        items: [
          for (final code in AuthProvider.supportedLanguageCodes)
            DropdownMenuItem(
              value: code,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LanguageImage(lang: code),
                  Text(languageNames[code] ?? code.toUpperCase()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
