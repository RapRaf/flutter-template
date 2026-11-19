import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_template/config/env.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Env', () {
    test('builds API URIs', () {
      dotenv.loadFromString(
        envString:
            'HTTP_SCHEMA=http\nHOST=api.test\nPORT=8080\n'
            'API_PREFIX=/api/v1/',
      );
      final uri = Env.apiUri('/users', {
        'page': 2,
        'ids': [1, 2],
      });
      expect(
        uri.toString(),
        'http://api.test:8080/api/v1/users?page=2&ids=1&ids=2',
      );
    });

    test('optional values can be empty', () {
      dotenv.loadFromString(envString: 'HOST=api.test\nPORT=\nAPI_PREFIX=');
      expect(Env.apiUri('ping').toString(), 'https://api.test/ping');
      expect(Env.websiteUri(), isNull);
    });

    test('a missing HOST is a clear configuration error', () {
      dotenv.loadFromString(envString: 'PORT=443');
      expect(() => Env.apiUri('ping'), throwsA(isA<EnvConfigurationError>()));
    });
  });

  group('HttpRequest.decodeBody', () {
    test('keeps JSON maps', () {
      expect(HttpRequest.decodeBody(200, '{"status":true,"data":1}'), {
        'status': true,
        'data': 1,
      });
    });

    test('adds status when missing', () {
      expect(HttpRequest.decodeBody(200, '{"id":1}'), {
        'id': 1,
        'status': true,
      });
      expect(HttpRequest.decodeBody(422, '{"email":["invalid"]}'), {
        'email': ['invalid'],
        'status': false,
      });
    });

    test('wraps non-map JSON', () {
      expect(HttpRequest.decodeBody(200, '[1,2]'), {
        'status': true,
        'data': [1, 2],
      });
    });

    test('handles empty and invalid bodies', () {
      expect(HttpRequest.decodeBody(204, ''), {
        'status': true,
        'data': 'No Content.',
      });
      expect(HttpRequest.decodeBody(500, '<html>'), {
        'status': false,
        'data': 'Server error.',
      });
      expect(HttpRequest.decodeBody(200, '<html>')['status'], isFalse);
    });
  });

  group('HttpRequest.send', () {
    setUp(() => dotenv.loadFromString(envString: 'HOST=api.test'));

    Future<(int, Map<String, dynamic>)> run(
      http.Client client, {
      Duration timeout = HttpRequest.defaultTimeout,
    }) {
      final completer = Completer<(int, Map<String, dynamic>)>();
      HttpRequest(
        tag: 't',
        method: 'GET',
        path: 'ping',
        headers: const {},
        client: client,
        timeout: timeout,
        managerResponse: (tag, status, response, headers) =>
            completer.complete((status, response)),
      ).send();
      return completer.future;
    }

    test('always calls back, even on exceptions', () async {
      final result = await run(
        MockClient((_) async => throw Exception('boom')),
      );
      expect(result.$1, HttpRequest.networkErrorStatus);
      expect(result.$2['status'], isFalse);
    });

    test('times out', () async {
      final result = await run(
        MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 10),
      );
      expect(result.$1, HttpRequest.networkErrorStatus);
    });

    test('reports configuration errors instead of throwing', () async {
      dotenv.loadFromString(envString: 'PORT=1');
      final result = await run(MockClient((_) async => http.Response('', 200)));
      expect(result.$1, HttpRequest.networkErrorStatus);
      expect(result.$2, {'status': false, 'data': 'Configuration error.'});
    });
  });
}
