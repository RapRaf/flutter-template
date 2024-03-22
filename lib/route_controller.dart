import 'package:flutter/material.dart';
import 'package:flutter_template/src/access/access_view.dart';
import 'package:flutter_template/src/sample_feature/sample_item_details_view.dart';
import 'package:flutter_template/src/sample_feature/sample_item_list_view.dart';
import 'package:flutter_template/src/settings/settings_view.dart';

class RouteController {
  Widget buildRoute(RouteSettings settings) {
    final routeName = settings.name != null
        ? AppRoutes.values.firstWhere((e) => e.toString() == settings.name)
        : null;

    ///
    /// final args = settings.arguments;
    ///

    switch (routeName) {
      case AppRoutes.root:
        return const AccessView();
      case AppRoutes.home:
        return const SampleItemListView();
      case AppRoutes.settings:
        return const SettingsView();
      case AppRoutes.sampleItem:
        return const SampleItemDetailsView();
      default:
        return const Scaffold(
          body: Center(
            child: Text('404 - Page not found'),
          ),
        );
    }
  }
}

enum AppRoutes {
  root,
  home,
  settings,
  sampleItem,
}
