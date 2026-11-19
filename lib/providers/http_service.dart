import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

/// Serial queue of HTTP requests: one request in flight at a time, in order.
///
/// - Network errors / timeouts never block the queue: the request fails and
///   the next one is sent.
/// - `401` while logged in: if "keep logged" is enabled the user is logged in
///   again automatically and the request retried once, otherwise the session
///   is closed ([AuthProvider.handleSessionExpired]).
/// - `403` while logged in: a new session token is requested and the request
///   retried once.
/// - A ping keeps the session alive after [TimerService.interval] of inactivity.
class HttpService {
  final AuthProvider authProvider;
  final http.Client? _client;

  final ListQueue<HttpEntry> _queue = ListQueue<HttpEntry>();
  final TimerService _timerService;
  HttpEntry? _current;
  bool _isStopped = false;
  bool _disposed = false;
  bool _keepAliveInFlight = false;
  int _tagCounter = 0;

  HttpService({
    required this.authProvider,
    http.Client? client,
    Duration keepAliveInterval = const Duration(minutes: 2),
  }) : _client = client,
       _timerService = TimerService(interval: keepAliveInterval) {
    _timerService.startTimer(_keepSessionAlive);
  }

  // GETTERS

  /// `true` while a request is in flight.
  bool get sending => _current != null;

  /// Requests not completed yet (in flight + waiting).
  int get requestCount => _queue.length + (sending ? 1 : 0);

  bool get isStopped => _isStopped;

  HttpEntry? get currentRequest => _current;

  List<HttpEntry> get pendingRequests => List.unmodifiable(_queue);

  // QUEUE CONTROL

  /// Pauses the queue: the request in flight completes, the others wait.
  void stopQueue() {
    _isStopped = true;
    _notify();
  }

  /// Drops the requests that have not been sent yet.
  void cleanQueue() {
    _queue.clear();
    _notify();
  }

  void startQueue() {
    _isStopped = false;
    _processNext();
    _notify();
  }

  /// Drops everything, including the request in flight (its response will be
  /// ignored), and restarts a stopped queue. Used on logout / session
  /// expiration.
  void reset() {
    _queue.clear();
    _current = null;
    _isStopped = false;
    _notify();
  }

  void dispose() {
    _disposed = true;
    _timerService.stopTimer();
    _queue.clear();
    _current = null;
  }

  void addToQueue({required HttpEntry httpEntry}) {
    if (_disposed) return;
    httpEntry.tag = '${httpEntry.path}_${++_tagCounter}';
    _queue.add(httpEntry);
    _processNext();
    _notify();
  }

  // INTERNALS

  void _processNext() {
    if (_disposed || _isStopped || _current != null || _queue.isEmpty) return;
    final next = _queue.removeFirst();
    _current = next;
    _send(next);
  }

  void _send(HttpEntry entry) {
    _timerService.resetTimer(_keepSessionAlive);
    HttpRequest(
      tag: entry.tag,
      method: entry.method,
      path: entry.path,
      headers: getHeaders(),
      body: entry.body,
      params: entry.params,
      client: _client,
      managerResponse: _handleResponse,
    ).send();
  }

  void _retry(HttpEntry entry) {
    if (_disposed || !identical(_current, entry)) return;
    _send(entry);
  }

  bool get _loggedIn => authProvider.loginState == LoginState.loggedIn;

  void _handleResponse(
    String tag,
    int status,
    Map<String, dynamic> response,
    Map<String, String> headers,
  ) {
    final entry = _current;
    // Stale response (queue reset / disposed meanwhile): ignore it.
    if (_disposed || entry == null || entry.tag != tag) return;

    if (status == 401) {
      _handleUnauthorized(entry, response, status);
      return;
    }

    if (status == 403 && _loggedIn && entry.retries == 0) {
      entry.retries++;
      _openSession(
        onSuccess: () => _retry(entry),
        onFailure: () => _complete(entry, response, status),
      );
      return;
    }

    final httpOk = (status >= 200 && status < 300) || status == 422;
    if (httpOk && response['status'] == true) {
      parseHeaders(headers);
      _complete(entry, response, status, success: true);
      return;
    }

    _complete(entry, response, status);
  }

  void _handleUnauthorized(
    HttpEntry entry,
    Map<String, dynamic> response,
    int status,
  ) {
    if (!_loggedIn) {
      // e.g. wrong credentials on login, or expired token on the first ping.
      _complete(entry, response, status);
      return;
    }

    void expire() {
      _complete(entry, response, status, showDefaultError: false);
      authProvider.handleSessionExpired();
    }

    if (authProvider.keepLogged && entry.retries == 0) {
      entry.retries++;
      _autoLogin(onSuccess: () => _retry(entry), onFailure: expire);
    } else {
      expire();
    }
  }

  /// Completes [entry], notifies its listener and moves to the next request.
  void _complete(
    HttpEntry entry,
    Map<String, dynamic> response,
    int status, {
    bool success = false,
    bool showDefaultError = true,
  }) {
    if (identical(_current, entry)) _current = null;
    try {
      if (success) {
        entry.responseListener(response);
      } else if (entry.errorListener != null) {
        entry.errorListener!(response, status);
      } else if (showDefaultError) {
        returnError(response, status);
      }
    } catch (exception, stack) {
      // A failing listener must never block the queue.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'HttpService',
        ),
      );
    }
    _processNext();
    _notify();
  }

  /// Default error handling when a request has no `errorListener`.
  void returnError(Map<String, dynamic> response, int status) {
    if (status == HttpRequest.networkErrorStatus) {
      authProvider.showSnackBar(authProvider.localizations.network_error);
    } else if (response['data'] != null || response['message'] != null) {
      authProvider.showSnackBar(response);
    }
  }

  void _keepSessionAlive() {
    if (_disposed || _keepAliveInFlight || sending || !_loggedIn) return;
    _keepAliveInFlight = true;
    _openSession(
      onSuccess: () => _keepAliveInFlight = false,
      onFailure: () => _keepAliveInFlight = false,
    );
  }

  /// Asks the server for a new session token.
  void _openSession({VoidCallback? onSuccess, VoidCallback? onFailure}) {
    if (_disposed || !_loggedIn) {
      onFailure?.call();
      return;
    }
    final ping = HttpRequests().ping(
      responseListener: (_) {},
      errorListener: (_, _) {},
    );
    HttpRequest(
      tag: 'session',
      method: ping.method,
      path: ping.path,
      headers: getHeaders(),
      client: _client,
      managerResponse: (tag, status, response, headers) {
        if (_disposed) return;
        final ok = status >= 200 && status < 300 && response['status'] == true;
        if (ok) {
          final sessionToken = response['data'];
          if (sessionToken is String) {
            authProvider.setSessionToken(newSessionToken: sessionToken);
          }
          onSuccess?.call();
          return;
        }
        onFailure?.call();
        // Network errors are ignored: only an explicit refusal closes the session.
        if ((status == 401 || status == 403) && _loggedIn) {
          authProvider.handleSessionExpired();
        }
      },
    ).send();
  }

  Future<void> _autoLogin({
    required VoidCallback onSuccess,
    required VoidCallback onFailure,
  }) async {
    final email = authProvider.currentMail;
    final password = email.isEmpty
        ? null
        : await authProvider.getPassword(email);
    if (_disposed) return;
    if (password == null || password.isEmpty) {
      onFailure();
      return;
    }

    final login = HttpRequests().logIn(
      responseListener: (_) {},
      email: email,
      password: password,
    );
    HttpRequest(
      tag: 'auto-login',
      method: login.method,
      path: login.path,
      headers: getHeaders(),
      body: login.body,
      client: _client,
      managerResponse: (tag, status, response, headers) {
        if (_disposed) return;
        final data = response['data'];
        final token = data is Map ? data['token'] : null;
        final ok =
            status >= 200 &&
            status < 300 &&
            response['status'] == true &&
            token is String &&
            token.isNotEmpty;
        if (ok) {
          authProvider.setToken(newToken: token);
          onSuccess();
        } else {
          onFailure();
        }
      },
    ).send();
  }

  void parseHeaders(Map<String, String> headers) {
    final notify = headers['notify'];
    if (notify != null && notify.isNotEmpty) {
      final lastUpdate = int.tryParse(notify);
      if (lastUpdate != null) {
        authProvider.setLastUpdate(lastUpdate: lastUpdate);
      }
    }
    final sessionToken = headers['session-token'];
    if (sessionToken != null && sessionToken.isNotEmpty) {
      authProvider.setSessionToken(newSessionToken: sessionToken);
    }
  }

  Map<String, String> getHeaders() {
    final userId = authProvider.userId;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent':
          'FlutterTemplate|${authProvider.model}|${userId.isEmpty ? "0" : userId}',
      'Device-Id': authProvider.id,
      if (authProvider.token.isNotEmpty)
        'Authorization': 'Bearer ${authProvider.token}',
      if (authProvider.sessionToken.isNotEmpty)
        'Session-Token': authProvider.sessionToken,
    };
  }

  /// Notifies after the current frame/task, so that adding a request from
  /// `build`/`initState` never triggers "notifyListeners during build".
  void _notify() {
    scheduleMicrotask(() {
      if (!_disposed) authProvider.mNotifyListeners();
    });
  }
}

class TimerService {
  final Duration interval;
  Timer? _timer;

  TimerService({this.interval = const Duration(minutes: 2)});

  void startTimer(void Function() callback) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => callback());
  }

  void resetTimer(void Function() callback) => startTimer(callback);

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
