import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_template/config/env.dart';
import 'package:http/http.dart' as http;

/// Called with the decoded JSON body when a request succeeds.
typedef ResponseListener = void Function(Map<String, dynamic> response);

/// Called when a request fails. [statusCode] is the HTTP status, or
/// [HttpRequest.networkErrorStatus] when the server could not be reached.
typedef ErrorListener =
    void Function(Map<String, dynamic> response, int statusCode);

/// Internal callback used by [HttpRequest] to hand the result to its owner.
typedef ResponseHandler =
    void Function(
      String tag,
      int statusCode,
      Map<String, dynamic> response,
      Map<String, String> headers,
    );

/// A request waiting in the [HttpService] queue.
class HttpEntry {
  final ResponseListener responseListener;

  /// When `null` the error message (if any) is shown in a snackbar.
  final ErrorListener? errorListener;
  final String path, method;
  final Map<String, dynamic>? params;
  final String? body;
  final bool automatic;

  /// Unique key assigned by the queue.
  late String tag;

  /// How many times the queue has already retried this request.
  int retries = 0;

  HttpEntry({
    required this.responseListener,
    required this.method,
    required this.path,
    this.errorListener,
    this.body,
    this.params,
    this.automatic = true,
  });
}

/// Performs one HTTP call. [send] never throws: network errors, timeouts,
/// configuration errors and malformed bodies are all reported to
/// [managerResponse] as a `{"status": false, "data": "..."}` body.
class HttpRequest {
  /// Status code used when no HTTP response was received.
  static const int networkErrorStatus = 0;
  static const Duration defaultTimeout = Duration(seconds: 30);

  final String path, method, tag;
  final Map<String, dynamic>? params;
  final Map<String, String> headers;
  final String? body;
  final ResponseHandler managerResponse;
  final Duration timeout;
  final http.Client? client;

  HttpRequest({
    required this.tag,
    required this.method,
    required this.path,
    required this.managerResponse,
    required this.headers,
    this.body,
    this.params,
    this.timeout = defaultTimeout,
    this.client,
  });

  Future<void> send() async {
    int statusCode;
    Map<String, dynamic> responseBody;
    Map<String, String> responseHeaders = const {};

    try {
      final request = http.Request(method, Env.apiUri(path, params));
      request.headers.addAll(headers);
      if (body != null) request.body = body!;

      final ownClient = client == null;
      final httpClient = client ?? http.Client();
      try {
        final streamed = await httpClient.send(request).timeout(timeout);
        final response = await http.Response.fromStream(
          streamed,
        ).timeout(timeout);
        statusCode = response.statusCode;
        responseHeaders = response.headers;
        responseBody = decodeBody(response.statusCode, response.body);
      } finally {
        if (ownClient) httpClient.close();
      }
    } on TimeoutException {
      statusCode = networkErrorStatus;
      responseBody = {'status': false, 'data': 'Request timed out.'};
    } on EnvConfigurationError catch (e) {
      debugPrint(e.toString());
      statusCode = networkErrorStatus;
      responseBody = {'status': false, 'data': 'Configuration error.'};
    } catch (e) {
      debugPrint('HTTP $method $path failed: $e');
      statusCode = networkErrorStatus;
      responseBody = {'status': false, 'data': 'Network error.'};
    }

    managerResponse(tag, statusCode, responseBody, responseHeaders);
  }

  /// Normalizes any response body to a map with at least a `status` key.
  @visibleForTesting
  static Map<String, dynamic> decodeBody(int statusCode, String body) {
    final success = statusCode >= 200 && statusCode < 300;

    if (body.trim().isEmpty) {
      return {'status': success, 'data': _defaultMessage(statusCode)};
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded.containsKey('status')
            ? decoded
            : {...decoded, 'status': success};
      }
      return {'status': success, 'data': decoded};
    } on FormatException {
      return {
        'status': false,
        'data': success
            ? 'Error reading response.'
            : _defaultMessage(statusCode),
      };
    }
  }

  static String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 204:
        return 'No Content.';
      case 404:
        return 'Not found.';
      case >= 500:
        return 'Server error.';
      default:
        return statusCode >= 200 && statusCode < 300
            ? 'OK.'
            : 'Request failed ($statusCode).';
    }
  }
}
