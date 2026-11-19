import 'dart:convert';

import 'package:flutter_template/models/http_request.dart';

class HttpRequests {
  HttpEntry logIn({
    required ResponseListener responseListener,
    ErrorListener? errorListener,
    required String email,
    required String password,
  }) {
    return HttpEntry(
      method: 'POST',
      path: 'login',
      body: jsonEncode({'email': email, 'password': password}),
      responseListener: responseListener,
      errorListener: errorListener,
    );
  }

  HttpEntry logOut({
    required ResponseListener responseListener,
    ErrorListener? errorListener,
  }) {
    return HttpEntry(
      method: 'POST',
      path: 'logout',
      responseListener: responseListener,
      errorListener: errorListener,
    );
  }

  HttpEntry ping({
    required ResponseListener responseListener,
    required ErrorListener errorListener,
  }) {
    return HttpEntry(
      method: 'GET',
      path: 'ping',
      responseListener: responseListener,
      errorListener: errorListener,
    );
  }
}
