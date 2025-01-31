import 'dart:convert';

import 'package:flutter_template/models/http_request.dart';

class HttpRequests {
  HttpEntry logIn(
      {required Function responseListener,
      required String email,
      required String password}) {
    return HttpEntry(
        method: 'POST',
        path: 'login',
        body: jsonEncode({'email': email, 'password': password}),
        responseListener: (response) => responseListener(response));
  }

  HttpEntry logOut({required Function responseListener}) {
    return HttpEntry(
        method: 'POST',
        path: 'logout',
        responseListener: (response) => responseListener(response));
  }

  HttpEntry ping(
      {required Function responseListener, required Function errorListener}) {
    return HttpEntry(
        method: 'GET',
        path: 'ping',
        responseListener: (response) => responseListener(response),
        errorListener: (response) => errorListener(response));
  }
}
