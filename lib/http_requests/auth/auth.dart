import 'package:flutter_template/models/http_request.dart';

class HttpRequests {
  HttpEntry logOut(
      {required Function responseListener, required Function errorListener}) {
    return HttpEntry(
        method: 'POST',
        path: 'app/logout',
        responseListener: (response) => responseListener(response),
        errorListener: (response) => errorListener(response));
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
