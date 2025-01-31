import 'dart:async';

import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';

class HttpService {
  Map<String, HttpEntry> _requestList = {};
  bool _sending = false;
  int _requestCount = 0;
  int _sendingIndex = 0;
  bool _isStopped = false;

  AuthProvider authProvider;

  bool get sending => _sending;

  int get requestCount => _requestCount;

  int get sendingIndex => _sendingIndex;

  bool get isStopped => _isStopped;

  late TimerService _timerService;

  HttpService({required this.authProvider}) {
    _timerService = TimerService();
    _timerService.startTimer(_openSession);
  }

  // GETTERS
  Map<String, HttpEntry> get requestList => _requestList;

  void stopQueue() {
    _isStopped = true;
    authProvider.mNotifyListeners();
  }

  void cleanQueue() {
    if (!_isStopped) return;
    _cleanQueue();
    authProvider.mNotifyListeners();
  }

  void startQueue() {
    _isStopped = false;
    _processNext();
  }

  void addToQueue({required HttpEntry httpEntry}) {
    _requestCount++;

    httpEntry.tag = _generateKey(httpEntry.path);

    _requestList[httpEntry.tag] = httpEntry;

    if (!_sending) {
      _sending = true;
      _sendRequest();
    }
    authProvider.mNotifyListeners();
  }

  void _sendRequest() {
    HttpEntry? http = findRequestByIndex(_sendingIndex);
    if (http == null) return;

    HttpRequest req = HttpRequest(
        tag: http.tag,
        method: http.method,
        path: http.path,
        headers: getHeaders(),
        body: http.body,
        params: http.params,
        managerResponse: _handleResponse);

    req.send();
    _timerService.resetTimer(_openSession);
  }

  void _handleResponse(String tag, int status, dynamic response,
      Map<String, String> headers) async {
    HttpEntry? http = findRequestByKey(tag);
    if (http == null) {
      _processNext();
      return;
    }

    if (status == 401) {
      if (authProvider.keepLogged) {
        _autoLogin();
      } else {
        if (!tag.contains('ping')) authProvider.initProvider();
      }
      returnError(http, response);
      return;
    }

    if (status == 403) {
      _openSession();
      return;
    }

    if (status < 300 || status == 422) {
      if (response['status'] == true) {
        parseHeaders(headers);

        http.responseListener(response);
        _processNext();
      } else {
        returnError(http, response);
      }
      return;
    }
    returnError(http, response);
    return;
  }

  void _openSession() {
    if (authProvider.loginState != 2) return;
    HttpEntry sessionEntry =
        HttpRequests().ping(responseListener: () {}, errorListener: () {});
    HttpRequest req = HttpRequest(
        tag: "auto",
        method: sessionEntry.method,
        path: sessionEntry.path,
        headers: getHeaders(),
        managerResponse: _handleSessionResponse);

    req.send();
  }

  void _handleSessionResponse(
      String tag, int status, dynamic response, Map<String, String> headers) {
    if (status != 200 || !response['status']) {
      authProvider.initProvider();
      return;
    }

    authProvider.setSessionToken(newSessionToken: response['data']);
    if (_requestList.isNotEmpty) _sendRequest();
  }

  void _autoLogin() async {
    await authProvider
        .getPassword(authProvider.currentMail)
        .then((String? pass) {
      if (pass != null && pass.isNotEmpty) {
        HttpEntry loginEntry = HttpRequests().logIn(
            responseListener: (response) {},
            email: authProvider.currentMail,
            password: pass);
        HttpRequest req = HttpRequest(
            tag: "auto",
            method: loginEntry.method,
            path: loginEntry.path,
            headers: getHeaders(),
            body: loginEntry.body,
            managerResponse: _handleLoginResponse);

        req.send();
      }
    });
  }

  void _handleLoginResponse(String tag, int status, dynamic response,
      Map<String, String> headers) async {
    if (status != 200 || !response['status']) {
      authProvider.initProvider();
      return;
    }

    authProvider.setToken(newToken: response['data']['token']);
    if (_requestList.isNotEmpty) _sendRequest();
  }

  void parseHeaders(Map<String, String> headers) {
    if (headers['notify'] != null && headers['notify']!.isNotEmpty) {
      authProvider.setLastUpdate(
          lastUpdate: int.tryParse(headers['notify']!) ?? 0);
    }
    if (headers['session-token'] != null &&
        headers['session-token']!.isNotEmpty) {
      authProvider.setSessionToken(newSessionToken: headers['session-token']!);
    }
  }

  void _processNext() {
    if (_isStopped) return;
    _sendingIndex++;
    if (_requestCount <= _sendingIndex) {
      _cleanQueue();
      _sending = false;
      authProvider.mNotifyListeners();
      return;
    }
    authProvider.mNotifyListeners();
    _sendRequest();
  }

  void _cleanQueue() {
    _requestList = {};
    _requestCount = 0;
    _sendingIndex = 0;
  }

  Map<String, String> getHeaders() {
    return {
      'Authorization': 'Bearer ${authProvider.token}',
      'Content-Type': 'application/json',
      'User-Agent': 'FlutterTemplate|${authProvider.model}|${authProvider.userId ?? "0"}',
      'Device-Id': authProvider.id,
      'Session-Token': authProvider.sessionToken
    };
  }

  String _generateKey(String path) {
    // UNIQUE KEY FOR OUTGOING HTTP REQUESTS
    return '${path}_$_requestCount';
  }

  HttpEntry? findRequestByKey(String key) {
    return _requestList[key];
  }

  HttpEntry? findRequestByIndex(int index) {
    String key = _requestList.keys.toList()[index]; // GET KEY AT INDEX
    return _requestList[key];
  }

  void returnError(HttpEntry http, dynamic response) {
    if (http.errorListener != null) {
      http.errorListener!(response);
    } else if (response != null && response['data'] != null) {
      authProvider.showSnackBar(response);
    }
    _processNext();
  }
}

class TimerService {
  Timer? _timer;
  Duration interval = const Duration(minutes: 2);

  void startTimer(void Function() callback) {
    _timer = Timer.periodic(interval, (Timer t) => callback());
  }

  void resetTimer(void Function() callback) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (Timer t) => callback());
  }

  void stopTimer() {
    _timer?.cancel();
  }
}
