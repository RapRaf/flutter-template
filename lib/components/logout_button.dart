import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
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
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
    HttpEntry req = HttpRequests().logOut(
        responseListener: (response) =>
            Provider.of<AuthProvider>(context, listen: false)
                .handleLogoutResponse());

    Provider.of<AuthProvider>(context, listen: false).sendRequest(req);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        onLongPress: () => _showLogoutDialog(context),
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
