import 'package:flutter/material.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/providers/app_provider.dart';
import 'package:flutter_template/views/home/home_view.dart';
import 'package:flutter_template/views/home/orders_view.dart';
import 'package:flutter_template/views/home/settings_view.dart';
import 'package:provider/provider.dart';

class MainActivity extends StatelessWidget {
  const MainActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final navigators = _getNavigators(localizations);
    final currentPage = context.select<AppProvider, int>(
      (p) => p.currentPage.clamp(0, navigators.length - 1),
    );

    return Scaffold(
      appBar: AppBar(title: Text(localizations.appTitle), elevation: 1),
      body: IndexedStack(
        index: currentPage,
        children: [for (final navItem in navigators) navItem.page],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        currentIndex: currentPage,
        onTap: (index) => context.read<AppProvider>().changeCurrentPageState(
          newCurrentPageState: index,
        ),
        items: [
          for (final navItem in navigators)
            BottomNavigationBarItem(
              icon: Icon(navItem.icon),
              label: navItem.label,
            ),
        ],
      ),
    );
  }

  List<NavigationItems> _getNavigators(AppLocalizations localizations) {
    return [
      NavigationItems(
        label: localizations.home,
        icon: Icons.home,
        page: const Home(),
        privilege: 0,
      ),
      NavigationItems(
        label: localizations.orders,
        icon: Icons.reorder,
        page: const Orders(),
        privilege: 0,
      ),
      NavigationItems(
        label: localizations.settings,
        icon: Icons.settings,
        page: const Settings(),
        privilege: 0,
      ),
    ];
  }
}

class NavigationItems {
  final String label;
  final IconData icon;
  final int privilege;
  final Widget page;

  const NavigationItems({
    required this.label,
    required this.icon,
    required this.privilege,
    required this.page,
  });
}
