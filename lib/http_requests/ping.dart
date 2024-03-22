import 'package:flutter_template/model/http_request.dart';

class Ping {
  late HttpRequest req;

  Function responseListener, errorListener;

  Ping({required this.responseListener, required this.errorListener});

  Future<void> run() async {
    req = HttpRequest(
        method: 'GET',
        path: 'ping',
        responseListener: () => onSuccess(),
        errorListener: () => onError());

    req.send();
  }

  void onSuccess() {
    responseListener();
  }

  void onError() {
    errorListener();
  }
}
