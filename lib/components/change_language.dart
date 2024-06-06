import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: DropdownButton<String>(
        value: context.watch<AuthProvider>().language,
        onChanged: (String? value) {
          if (value != null) {
            context.read<AuthProvider>().setLanguage(newLanguage: value);
          }
        },
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
    );
  }
}
