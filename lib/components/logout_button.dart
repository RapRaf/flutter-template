import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout_confirmation),
          content: Text(AppLocalizations.of(context)!.are_you_sure_logout),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Perform the logout operation here
                _logout();
              },
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    HttpEntry req = HttpEntry(
        method: 'POST',
        path: 'logout',
        responseListener: (response) =>
            Provider.of<AuthProvider>(context, listen: false)
                .handleLogoutResponse(),
        errorListener: (response) =>
            Provider.of<AuthProvider>(context, listen: false)
                .showSnackBar(response['data']));

    Provider.of<AuthProvider>(context, listen: false).sendRequest(req, context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        onLongPress: () => _showLogoutDialog(context),
        child: Text(AppLocalizations.of(context)!.logout),
      ),
    );
  }
}
