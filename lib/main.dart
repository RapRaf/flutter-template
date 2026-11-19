import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template/app.dart';
import 'package:flutter_template/config/env.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    await dotenv.load(fileName: Env.fileName);
  } catch (e) {
    // The app still starts: requests will fail with a clear configuration
    // error instead of a black screen.
    debugPrint('Unable to load ${Env.fileName}: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const AppBootstrap(),
    ),
  );
}

/// Shows a splash screen until [AuthProvider] has loaded the saved state.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    final initialization = context.read<AuthProvider>().initialization;
    return FutureBuilder<bool>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StatusApp(child: SplashLogo());
        }
        if (snapshot.hasError) {
          debugPrint('Initialization failed: ${snapshot.error}');
        }
        if (snapshot.data == true) return const MyApp();
        return _StatusApp(
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context)!.unsupported_device,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Minimal app (with Directionality, MediaQuery and localizations) used before
/// the real [MyApp] is ready.
class _StatusApp extends StatelessWidget {
  const _StatusApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: child),
      ),
    );
  }
}

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo/logo.png', color: Colors.white);
  }
}
