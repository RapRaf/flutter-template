import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ExistingAccount extends StatefulWidget {
  final Function onTap, onLongPressed;

  const ExistingAccount(
      {super.key, required this.onTap, required this.onLongPressed});

  @override
  State<ExistingAccount> createState() => _ExistingAccountState();
}

class _ExistingAccountState extends State<ExistingAccount> {
  bool delete = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.already_logged_in_with),
          ),
          ...context.watch<AuthProvider>().emails.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: GestureDetector(
                  onTap: () =>
                      !delete ? widget.onTap(item) : widget.onLongPressed(item),
                  onLongPress: () => changeToDelete(item),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        minTileHeight: 30,
                        title: Text(item),
                        trailing: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blueAccent,
                        ),
                        subtitle: delete
                            ? FutureBuilder(
                                future: Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .getType(item),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text("N.A.");
                                  } else if (snapshot.hasData) {
                                    return Text(snapshot.data ?? 'N.A.');
                                  } else {
                                    return const Text("N.A.");
                                  }
                                })
                            : null,
                        leading: !delete
                            ? const Icon(Icons.fingerprint,
                                color: Colors.blueAccent)
                            : const Icon(Icons.delete, color: Colors.redAccent),
                      )),
                ),
              )),
        ],
      ),
    );
  }

  void changeToDelete(String email) {
    setState(() {
      delete = !delete;
    });
    debugPrint(delete.toString());
  }
}
