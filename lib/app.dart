import 'package:flutter/material.dart';
import 'package:flutter_template/providers/app_provider.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:flutter_template/views/access_page.dart';
import 'package:flutter_template/views/loading_screen.dart';
import 'package:flutter_template/views/main_activity.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// late double width, height;
// late bool largeScreen;

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
  // void setScreenSize(BuildContext context) {
  //   width = MediaQuery.of(context).size.width;
  //   height = MediaQuery.of(context).size.height;
  //   setState(() {
  //     largeScreen = MediaQuery.of(context).size.shortestSide > 600;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String language = context.watch<AuthProvider>().language;
    //setScreenSize(context);
    return MaterialApp(
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
      locale: Locale(language.split(',')[0], language.split(',')[1]),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: context.watch<AuthProvider>().theme,
      home: ScaffoldMessenger(
          key: authProvider.scaffoldMessengerKey, child: _getBody()),
    );
  }

  _getBody() {
    switch (context.watch<AuthProvider>().loginState) {
      case 0:
        return const LoadingScreen();
      case 1:
        return const AccessView();
      case 2:
        return ChangeNotifierProvider(
          create: (context) => AppProvider(),
          child: const MainActivity(),
        );
      default:
        return const AccessView();
    }
  }
}
