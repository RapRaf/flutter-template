import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';

class HttpService {
  Map<String, HttpEntry> _requestList = {};
  bool _sending = false;
  int _requestCount = 0;
  int _sendingIndex = 0;
  AuthProvider authProvider;

  HttpService({required this.authProvider});

  // GETTERS
  Map<String, HttpEntry> get requestList => _requestList;

  void addToQueue({required HttpEntry httpEntry}) {
    _requestCount++;

    httpEntry.tag = _generateKey();

    _requestList[httpEntry.tag] = httpEntry;

    if (!_sending) {
      _sending = true;
      sendRequest();
    }
  }

  void sendRequest() {
    HttpEntry? http = findRequestByIndex(_sendingIndex);
    if (http == null) return;

    HttpRequest req = HttpRequest(
        tag: http.tag,
        method: http.method,
        path: http.path,
        headers: getHeaders(),
        body: http.body,
        params: http.params,
        managerResponse: handleResponse);

    req.send();
  }

  void handleResponse(String tag, int status, dynamic response) {
    HttpEntry? http = findRequestByKey(tag);
    if (http == null) {
      processNext();
      return;
    }
    // HANDLE UNAUTHORIZED
    //
    // if (status == 401) {
    //   http.errorListener(response);
    //   processNext();
    //   return;
    // }

    if (status < 300 || status == 422) {
      if (response['status'] == true) {
        http.responseListener(response);
        processNext();
      } else {
        http.errorListener(response);
        processNext();
      }
      return;
    }
    http.errorListener(response);
    processNext();
    return;
  }

  void processNext() {
    _sendingIndex++;
    if (_requestCount <= _sendingIndex) {
      _requestList = {};
      _requestCount = 0;
      _sendingIndex = 0;
      _sending = false;
      return;
    }
    sendRequest();
  }

  Map<String, String> getHeaders() {
    return {
      'Authorization': 'Bearer ${authProvider.token}',
      'Content-Type': 'application/json'
    };
  }

  String _generateKey() {
    // UNIQUE KEY FOR OUTGOING HTTP REQUESTS
    return '${DateTime.now().millisecondsSinceEpoch}$_requestCount';
  }

  HttpEntry? findRequestByKey(String key) {
    return _requestList[key];
  }

  HttpEntry? findRequestByIndex(int index) {
    String key = _requestList.keys.toList()[index]; // GET KEY AT INDEX
    return _requestList[key];
  }
}
