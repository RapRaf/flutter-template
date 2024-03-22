import 'package:flutter_template/http_requests/log_out.dart';
import 'package:flutter_template/model/http_request.dart';
import 'package:flutter_template/store_controller.dart';
import 'dart:convert';

class LogIn {
  String email, password;
  late HttpRequest req;
  late bool? keep;
  late String? id, brand, model;

  Function responseListener, errorListener;

  LogIn(
      {required this.email,
      required this.password,
      required this.responseListener,
      required this.errorListener});

  Future<void> run() async {
    keep = await StoreController().getKeepLogged();
    id = await StoreController().getId();
    brand = await StoreController().getBrand();
    model = await StoreController().getModel();
    req = HttpRequest(
        method: 'POST',
        path: 'app/login',
        body: jsonEncode({
          'email': email,
          'password': password,
          'key': id,
          'brand': brand,
          'model': model
        }),
        responseListener: () => onSuccess(),
        errorListener: () => onError());

    req.send();
  }

  Future<void> onSuccess() async {
    if (req.responseBody['status']) {
      StoreController().setToken(req.responseBody['token']);

      if (req.responseBody['role'] != 'owner') {
        LogOut(responseListener: () {}, errorListener: () {}).run();
        errorListener(-1);
        return;
      }

      if (keep! && keep == true) {
        StoreController().setEmail(email);
        StoreController().setPassword(password);
      }

      responseListener(req.responseBody);
    } else {
      errorListener(req.responseBody);
    }
  }

  void onError() {
    errorListener(req.responseBody);
  }
}
