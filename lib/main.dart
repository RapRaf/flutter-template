import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/app.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
              return _splashScreen();
            } else {
              return const MyApp();
            }
          },
        ),
      ),
    );
  });
}

Widget _splashScreen() {
  return Center(
      child: Image.asset(
    'assets/images/logo/logo.png',
    color: Colors.black,
  ));
}
