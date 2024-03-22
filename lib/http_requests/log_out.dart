import 'package:flutter_template/app_controller.dart';
import 'package:flutter_template/store_controller.dart';
import 'package:flutter_template/model/http_request.dart';

class LogOut {
  late HttpRequest req;

  Function responseListener, errorListener;

  LogOut({required this.responseListener, required this.errorListener});

  Future<void> run() async {
    if (AppController.type == 'free' ||
        '${await StoreController().getToken()}'.isEmpty) {
      onSuccess();
      return;
    }
    req = HttpRequest(
        method: 'POST',
        path: 'web/logout',
        responseListener: () => onSuccess(),
        errorListener: () => onError());

    req.send();
  }

  void onSuccess() {
    StoreController().setEmail("");
    StoreController().setPassword("");
    StoreController().setToken("");
    StoreController().setType("");
    responseListener();
  }

  void onError() {
    errorListener(req.responseBody);
  }
}
