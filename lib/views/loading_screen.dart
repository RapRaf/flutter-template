import 'package:flutter/material.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

enum PingResult { success, failure, tokenExpired }

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  Future<void> pingServer(context) async {
    await Future.delayed(const Duration(milliseconds: 900));

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token.isEmpty) {
      authProvider.setLoginState(newLoginState: 1);
      return;
    }

    HttpEntry ping = HttpRequests().ping(
      responseListener: (response) {
        authProvider.setLoginState(newLoginState: 2);
      },
      errorListener: (response) {
        if (response != null && response.containsKey('status')) {
          authProvider.setToken(newToken: "");
          authProvider.showSnackBar("Token scaduto");

          authProvider.setLoginState(newLoginState: 1);
        } else {
          authProvider.setLoginState(newLoginState: 1);
        }
      },
    );

    authProvider.sendRequest(ping, context);
  }

  @override
  Widget build(BuildContext context) {
    //pingServer(context);
    return Scaffold(
        body: FutureBuilder(
            future: pingServer(context),
            builder: (context, snapshot) {
              return Center(
                  child: Image.asset(
                'assets/images/logo/logo.png',
                color: Colors.black,
              ));
            }));
  }
}

        // body: FutureBuilder(
        //   future: pingServer(),
        //   child: Center(child: Image.asset('assets/images/logo/logo.png'))));