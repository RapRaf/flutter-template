import 'package:flutter/material.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Accounts saved on this device. Tap: biometric login. Long press: toggles
/// delete mode, where a tap removes the account.
class ExistingAccount extends StatefulWidget {
  final ValueChanged<String> onTap, onLongPressed;

  const ExistingAccount({
    super.key,
    required this.onTap,
    required this.onLongPressed,
  });

  @override
  State<ExistingAccount> createState() => _ExistingAccountState();
}

class _ExistingAccountState extends State<ExistingAccount> {
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.already_logged_in_with),
          ),
          for (final item in authProvider.emails)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Material(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: ValueKey(item),
                  minTileHeight: 30,
                  onTap: () => _onTap(item),
                  onLongPress: changeToDelete,
                  title: Text(item),
                  trailing: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.blueAccent,
                  ),
                  subtitle: delete ? _AccountType(email: item) : null,
                  leading: !delete
                      ? const Icon(Icons.fingerprint, color: Colors.blueAccent)
                      : const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onTap(String email) {
    if (!delete) {
      widget.onTap(email);
      return;
    }
    widget.onLongPressed(email);
    setState(() => delete = false);
  }

  void changeToDelete() {
    setState(() {
      delete = !delete;
    });
  }
}

class _AccountType extends StatefulWidget {
  const _AccountType({required this.email});

  final String email;

  @override
  State<_AccountType> createState() => _AccountTypeState();
}

class _AccountTypeState extends State<_AccountType> {
  // Created once, not on every build.
  late final Future<String> _type = context.read<AuthProvider>().getType(
    widget.email,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _type,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final type = snapshot.data;
        return Text(type == null || type.isEmpty ? 'N.A.' : type);
      },
    );
  }
}
