import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthProvider auth;

  Future<AuthProvider> createAuth(
    MockClientHandler handler, {
    String token = '',
  }) async {
    FlutterSecureStorage.setMockInitialValues({
      'os': 'android',
      'id': 'device-1',
      if (token.isNotEmpty) 'token': token,
    });
    final provider = AuthProvider(httpClient: MockClient(handler));
    expect(await provider.initialization, isTrue);
    return provider;
  }

  setUp(() {
    dotenv.loadFromString(envString: 'HOST=api.test\nAPI_PREFIX=api');
  });

  tearDown(() => auth.dispose());

  /// Sends [path] through the queue and completes with (success, status).
  Future<(bool, int)> send(String path) {
    final completer = Completer<(bool, int)>();
    auth.sendRequest(
      HttpEntry(
        method: 'GET',
        path: path,
        responseListener: (_) => completer.complete((true, 200)),
        errorListener: (_, status) => completer.complete((false, status)),
      ),
    );
    return completer.future;
  }

  test('requests are sent in order, one at a time', () async {
    final paths = <String>[];
    var inFlight = 0, maxInFlight = 0;
    auth = await createAuth((request) async {
      paths.add(request.url.path);
      maxInFlight = ++inFlight > maxInFlight ? inFlight : maxInFlight;
      await Future.delayed(const Duration(milliseconds: 5));
      inFlight--;
      return jsonResponse({'status': true, 'data': 'ok'});
    });

    final results = await Future.wait([send('a'), send('b'), send('c')]);

    expect(paths, ['/api/a', '/api/b', '/api/c']);
    expect(maxInFlight, 1);
    expect(results.every((r) => r.$1), isTrue);
    expect(auth.httpService.sending, isFalse);
  });

  test('a network error does not block the queue', () async {
    auth = await createAuth((request) async {
      if (request.url.path.endsWith('offline')) {
        throw const SocketException('no network');
      }
      return jsonResponse({'status': true, 'data': 'ok'});
    });

    final failed = send('offline');
    final next = send('next');

    expect(await failed, (false, HttpRequest.networkErrorStatus));
    expect(await next, (true, 200));
  });

  test('a 403 while logged out fails instead of blocking the queue', () async {
    auth = await createAuth(
      (request) async => request.url.path.endsWith('forbidden')
          ? jsonResponse({'status': false, 'data': 'no'}, 403)
          : jsonResponse({'status': true, 'data': 'ok'}),
    );

    final forbidden = send('forbidden');
    final next = send('next');

    expect(await forbidden, (false, 403));
    expect(await next, (true, 200));
  });

  test(
    'a 403 while logged in refreshes the session and retries once',
    () async {
      final sessionHeaders = <String?>[];
      var ordersCalls = 0;
      auth = await createAuth(token: 'tkn', (request) async {
        if (request.url.path == '/api/ping') {
          return jsonResponse({'status': true, 'data': 'new-session'});
        }
        sessionHeaders.add(request.headers['Session-Token']);
        return ++ordersCalls == 1
            ? jsonResponse({'status': false, 'data': 'expired'}, 403)
            : jsonResponse({'status': true, 'data': []});
      });
      auth.setLoginState(newLoginState: LoginState.loggedIn);

      expect(await send('orders'), (true, 200));
      expect(ordersCalls, 2);
      expect(sessionHeaders, [null, 'new-session']);
      expect(auth.sessionToken, 'new-session');
    },
  );

  test('a 401 while logged in closes the session', () async {
    auth = await createAuth(
      token: 'tkn',
      (request) async => jsonResponse({'status': false, 'data': 'no'}, 401),
    );
    auth.setLoginState(newLoginState: LoginState.loggedIn);

    expect(await send('orders'), (false, 401));
    expect(auth.loginState, LoginState.loggedOut);
    expect(auth.token, isEmpty);
  });

  test('sends the auth headers', () async {
    late Map<String, String> headers;
    auth = await createAuth(token: 'tkn', (request) async {
      headers = request.headers;
      return jsonResponse({'status': true, 'data': 'ok'});
    });

    await send('me');

    expect(headers['Authorization'], 'Bearer tkn');
    expect(headers['Device-Id'], 'device-1');
    expect(headers.containsKey('Session-Token'), isFalse);
  });

  test('logout closes the local session even when offline', () async {
    auth = await createAuth(
      token: 'tkn',
      (request) async => throw const SocketException('no network'),
    );
    auth.setLoginState(newLoginState: LoginState.loggedIn);

    await auth.logout();

    expect(auth.loginState, LoginState.loggedOut);
    expect(auth.token, isEmpty);
  });

  test('logout drops pending requests and notifies the server', () async {
    final requests = <String, String?>{};
    final hang = Completer<http.Response>();
    auth = await createAuth(token: 'tkn', (request) {
      requests[request.url.path] = request.headers['Authorization'];
      return request.url.path == '/api/slow'
          ? hang.future
          : Future.value(jsonResponse({'status': true, 'data': 'ok'}));
    });
    auth.setLoginState(newLoginState: LoginState.loggedIn);

    var pendingCalled = false;
    auth.sendRequest(
      HttpEntry(method: 'GET', path: 'slow', responseListener: (_) {}),
    );
    auth.sendRequest(
      HttpEntry(
        method: 'GET',
        path: 'pending',
        responseListener: (_) => pendingCalled = true,
        errorListener: (_, _) => pendingCalled = true,
      ),
    );

    await auth.logout();
    await Future.delayed(const Duration(milliseconds: 20));

    expect(auth.loginState, LoginState.loggedOut);
    expect(requests['/api/logout'], 'Bearer tkn');
    expect(requests.containsKey('/api/pending'), isFalse);
    expect(pendingCalled, isFalse);
    expect(auth.httpService.requestCount, 0);
  });
}
