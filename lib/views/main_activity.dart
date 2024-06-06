import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/providers/app_provider.dart';
import 'package:flutter_template/views/home/home_view.dart';
import 'package:flutter_template/views/home/orders_view.dart';
import 'package:flutter_template/views/home/settings_view.dart';
import 'package:provider/provider.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        //shadowColor: Colors.white,
        elevation: 1,
      ),
      body: IndexedStack(
        index: context.watch<AppProvider>().currentPage,
        children: [..._getNavigators().map((navItem) => navItem.page)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        currentIndex: context.watch<AppProvider>().currentPage,
        onTap: _onItemTapped,
        items: _getNavigators().map((navItem) {
          return BottomNavigationBarItem(
            icon: Icon(navItem.icon),
            label: navItem.label,
          );
        }).toList(),
      ),
    );
  }

  List<NavigationItems> _getNavigators() {
    return [
      NavigationItems(
          label: AppLocalizations.of(context)!.home,
          icon: Icons.home,
          page: const Home(),
          privilege: 0),
      NavigationItems(
          label: AppLocalizations.of(context)!.orders,
          icon: Icons.reorder,
          page: const Orders(),
          privilege: 0),
      NavigationItems(
          label: AppLocalizations.of(context)!.settings,
          icon: Icons.settings,
          page: const Settings(),
          privilege: 0)
    ];
  }

  void _onItemTapped(int index) {
    context
        .read<AppProvider>()
        .changeCurrentPageState(newCurrentPageState: index);
  }
}

class NavigationItems {
  String label;
  IconData icon;
  int privilege;
  Widget page;

  NavigationItems(
      {required this.label,
      required this.icon,
      required this.privilege,
      required this.page});
}
