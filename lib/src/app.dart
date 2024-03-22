import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template/app_controller.dart';
import 'package:flutter_template/route_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('it', 'IT'),
          ],
          locale: Locale(
              AppController.settingsController.language.split(',')[0],
              AppController.settingsController.language.split(',')[1]),
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: AppController.settingsController.themeMode,
          initialRoute: AppController.isLogged
              ? AppRoutes.home.toString()
              : AppRoutes.root.toString(),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
                builder: (context) => RouteController().buildRoute(settings));
          },
        );
      },
    );
  }
}
