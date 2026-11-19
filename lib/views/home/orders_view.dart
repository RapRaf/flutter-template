import 'package:flutter/material.dart';
import 'package:flutter_template/localization/app_localizations.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.orders));
  }
}
