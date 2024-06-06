import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LogIn {
  String email, password;
  BuildContext context;
  bool automatic;

  LogIn(
      {required this.email,
      required this.password,
      required this.context,
      required this.automatic});

  HttpEntry getReq() {
    debugPrint("email: $email");
    debugPrint("password: $password");
    return HttpEntry(
        method: 'POST',
        path: 'login',
        body: jsonEncode({'email': email, 'password': password}),
        responseListener: (response) => onSuccess(response),
        errorListener: (response) => onError(response));
  }

  void send() {
    context.read<AuthProvider>().sendRequest(getReq(), context);
  }

  void onSuccess(response) {
    if (automatic) {
      context
          .read<AuthProvider>()
          .setToken(newToken: response['data']['token']);
    } else {
      context
          .read<AuthProvider>()
          .handleLoginResponse(response, email, password);
    }
  }

  void onError(response) {
    context.read<AuthProvider>().showSnackBar(response['data']);
  }
}
