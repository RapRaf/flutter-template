import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/providers/app_provider.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:flutter_template/views/access_page.dart';
import 'package:flutter_template/views/loading_screen.dart';
import 'package:flutter_template/views/main_activity.dart';
import 'package:provider/provider.dart';

/// Shortest side above which the device is treated as a tablet.
const double largeScreenBreakpoint = 600;

/// `true` on tablets / large screens.
bool isLargeScreen(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide > largeScreenBreakpoint;

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _setScreenOrientation();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild only when these values change, not on every AuthProvider update.
    final themeMode = context.select<AuthProvider, ThemeMode>((p) => p.theme);
    final locale = context.select<AuthProvider, Locale>((p) => p.locale);
    final loginState = context.select<AuthProvider, LoginState>(
      (p) => p.loginState,
    );
    final messengerKey = context.read<AuthProvider>().scaffoldMessengerKey;

    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<AuthProvider, AppProvider>(
          create: (context) =>
              AppProvider(authProvider: context.read<AuthProvider>()),
          update: (_, auth, app) => app!.update(auth),
        ),

        /// Add providers if needed
      ],
      child: MaterialApp(
        scaffoldMessengerKey: messengerKey,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: themeMode,
        home: _getBody(loginState),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      fontFamily: 'Lexend',
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Colors.lightBlueAccent,
        selectionHandleColor: Colors.blueAccent,
      ),
    );
  }

  Widget _getBody(LoginState loginState) {
    switch (loginState) {
      case LoginState.loading:
        return const LoadingScreen();
      case LoginState.loggedOut:
        return const AccessView();
      case LoginState.loggedIn:
        return const MainActivity();
    }
  }

  /// Tablets: landscape only. Phones: portrait only.
  void _setScreenOrientation() {
    SystemChrome.setPreferredOrientations(
      isLargeScreen(context)
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
  }
}
