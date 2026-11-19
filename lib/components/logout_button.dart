import 'package:flutter/material.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.logout_confirmation),
          content: Text(localizations.are_you_sure_logout),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.logout),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        style: TextButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 24),
        ),
        child: Text(
          AppLocalizations.of(context)!.logout,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
