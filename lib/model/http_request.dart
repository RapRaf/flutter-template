import 'package:flutter/material.dart';
import 'package:flutter_template/http_requests/log_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/store_controller.dart';
import 'package:flutter_template/app_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpRequest {
  final String scheme = dotenv.get('SCHEMA');

  final String host = dotenv.get('HOST');

  final int port = int.parse(dotenv.get('PORT'));

  final String path, method;

  final String prefix = dotenv.get('API_PREFIX');

  final Function responseListener, errorListener;

  late String? body;

  late dynamic responseBody;

  late Uri url;

  late HttpRequest oldReq, newReq;

  HttpRequest(
      {required this.method,
      required this.path,
      this.body,
      required this.responseListener,
      required this.errorListener});

  void send() async {
    url = Uri(scheme: scheme, host: host, port: port, path: prefix + path);

    http.Request req = http.Request(method, url);

    req.headers['Content-Type'] = 'application/json';

    req.headers['Authorization'] =
        'Bearer ${await StoreController().getToken()}';

    if (body != null) {
      req.body = body!;
    }

    AppController.requestList.add(this);

    http.StreamedResponse response = await req.send();

    try {
      responseBody = jsonDecode(await response.stream.bytesToString());
    } on Exception catch (_) {
      responseBody = {"status": false, "data": "Error"};
    }

    debugPrint(responseBody.toString());

    if (response.statusCode == 401) {
      autoLogIn();
      return;
    }

    if (response.statusCode == 200 && responseBody['status']) {
      responseListener();
    } else {
      errorListener();
    }
  }

  autoLogIn() async {
    bool logged = await StoreController().getKeepLogged() ?? false;
    if (!logged || AppController.type == 'free') {
      // MyApp.logOut();
      return;
    }
    String? email = await StoreController().getEmail();
    String? password = await StoreController().getPassword();

    oldReq = AppController.requestList
        .elementAt(AppController.requestList.length - 1);

    LogIn logInRequest = LogIn(
        email: email!,
        password: password!,
        responseListener: (body) => repeatRequest(),
        errorListener: (body) => autoLogInFail());

    logInRequest.run();
  }

  repeatRequest() async {
    newReq = HttpRequest(
        method: oldReq.method,
        path: oldReq.path,
        responseListener: () {
          oldReq.responseBody = newReq.responseBody;
          oldReq.responseListener();
        },
        errorListener: () {
          oldReq.responseBody = newReq.responseBody;
          oldReq.errorListener();
        });

    newReq.send();
  }

  autoLogInFail() {
    // MyApp.logOut();
    return;
  }
}
