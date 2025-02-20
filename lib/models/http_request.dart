import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HttpEntry {
  final Function responseListener;
  final Function? errorListener;
  final String path, method;
  final Map<String, dynamic>? params;
  final String? body;
  late String tag;
  final bool automatic;

  HttpEntry(
      {required this.responseListener,
      required this.method,
      required this.path,
      this.errorListener,
      this.body,
      this.params,
      this.automatic = true});
}

class HttpRequest {
  final String path, method, tag;
  final Map<String, dynamic>? params;
  final Map<String, String> headers;
  late Function managerResponse;
  late String? body;
  late dynamic responseBody;
  late HttpRequest oldReq, newReq;
  late http.Request req;

  HttpRequest(
      {required this.tag,
      required this.method,
      required this.path,
      required this.managerResponse,
      required this.headers,
      this.body,
      this.params});

  Uri _getUrl() {
    return Uri(
        scheme: dotenv.get('HTTP_SCHEMA'),
        host: dotenv.get('HOST'),
        port: int.parse(dotenv.get('PORT')),
        path: "${dotenv.get('API_PREFIX')}/$path",
        queryParameters: params);
  }

  void _initRequest() {
    req = http.Request(method, _getUrl());

    headers.forEach((key, value) {
      req.headers[key] = value;
    });

    if (body != null) {
      req.body = body!;
    }
  }

  void send() async {
    _initRequest();

    http.StreamedResponse response = await req.send();

    switch (response.statusCode) {
      case 204:
        responseBody = {"status": true, "data": "No Content."};
        break;
      case 404:
        responseBody = {"status": false, "data": "Not found."};
        break;
      case 500:
        responseBody = {"status": false, "data": "Server error."};
        break;
      default:
        try {
          responseBody = jsonDecode(await response.stream.bytesToString());
        } on Exception catch (_) {
          responseBody = {"status": false, "data": "Error reading response."};
        }
    }

    // log("Status: ${response.statusCode}");

    // log("Data: $responseBody");

    managerResponse(tag, response.statusCode, responseBody, response.headers);
  }
}
