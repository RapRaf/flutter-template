import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/app.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  dotenv.load(fileName: "lib/.env").then((_) {
    final authProvider = AuthProvider();

    runApp(
      ChangeNotifierProvider(
        create: (context) => authProvider,
        child: FutureBuilder(
          future: authProvider.initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _splashScreen();
            } else if (snapshot.hasError) {
              return _unsupportedScreen();
            } else {
              if (snapshot.data != null && snapshot.data == true) {
                return const MyApp();
              } else {
                return _unsupportedScreen();
              }
            }
          },
        ),
      ),
    );
  });
}

Widget _splashScreen() {
  return Container(
    color: Colors.black,
    child: Center(
        child: Image.asset(
      'assets/images/logo/logo.png',
      color: Colors.white,
    )),
  );
}

Widget _unsupportedScreen() {
  return Container(
    color: Colors.black,
    child: const Center(
        child: Text(
      "Something went wrong, try restarting the application. If the error persists it is because your device is not supported.",
      style: TextStyle(color: Colors.white),
    )),
  );
}
