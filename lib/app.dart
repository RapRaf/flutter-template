import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/providers/app_provider.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:flutter_template/views/access_page.dart';
import 'package:flutter_template/views/loading_screen.dart';
import 'package:flutter_template/views/main_activity.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

late bool isLarge;
late double width, height;


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AuthProvider authProvider;
  late AppProvider appProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider = context.read<AuthProvider>();
      appProvider =
          AppProvider(authProvider: authProvider);

      _setScreenOrientation();
    });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    authProvider = context.watch<AuthProvider>();
    final languageParts = authProvider.language.split(',');
    Locale locale = languageParts.length == 2
        ? Locale(languageParts[0], languageParts[1])
        : const Locale('en', 'US');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appProvider),
        /// Add providers if needed
      ],
      child: Selector<AuthProvider, ThemeMode>(
          selector: (_, provider) => provider.theme,
          builder: (context, theme, child) {
            final isDarkMode = theme == ThemeMode.dark ||
                (theme == ThemeMode.system &&
                    MediaQuery.of(context).platformBrightness ==
                        Brightness.dark);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              authProvider.setDark(isDarkMode);
            });
            return MaterialApp(
              scaffoldMessengerKey: authProvider.scaffoldMessengerKey,
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
              locale: locale,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                textSelectionTheme: const TextSelectionThemeData(
                  selectionColor: Colors.lightBlueAccent,
                  selectionHandleColor: Colors.blueAccent,
                ),
              ),
              darkTheme: ThemeData.dark(),
              themeMode: authProvider.theme,
              home: _getBody(),
            );
          }),
    );
  }

  _getBody() {
    switch (authProvider.loginState) {
      case 0:
        return const LoadingScreen();
      case 1:
        return const AccessView();
      case 2:
        return const MainActivity();
      default:
        return const AccessView();
    }
  }

  void _setScreenOrientation() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    double minSize = width < height ? width : height;

    if (minSize > 600) {
      isLarge = true;
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      isLarge = false;
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }
}
