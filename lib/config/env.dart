import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Thrown when a required `.env` value is missing or invalid.
class EnvConfigurationError extends Error {
  final String message;

  EnvConfigurationError(this.message);

  @override
  String toString() => 'EnvConfigurationError: $message';
}

/// Typed access to the values defined in `lib/.env` (see `lib/.env.example`).
///
/// Everything in `.env` is bundled in plain text inside the app: never store
/// secrets there.
class Env {
  Env._();

  static const fileName = 'lib/.env';

  static String? _value(String key) {
    if (!dotenv.isInitialized) return null;
    final value = dotenv.maybeGet(key)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  static String _required(String key) {
    final value = _value(key);
    if (value == null) {
      throw EnvConfigurationError('"$key" is not set in $fileName');
    }
    return value;
  }

  /// `http` or `https` (default: `https`).
  static String get httpScheme => _value('HTTP_SCHEMA') ?? 'https';

  /// API host, without scheme (e.g. `api.example.com`).
  static String get host => _required('HOST');

  /// Optional port. When empty the scheme default port is used.
  static int? get port {
    final raw = _value('PORT');
    if (raw == null) return null;
    final port = int.tryParse(raw);
    if (port == null || port <= 0 || port > 65535) {
      throw EnvConfigurationError('"PORT" is not a valid port: $raw');
    }
    return port;
  }

  /// Optional path prefix for every API call (e.g. `api/v1`).
  static String get apiPrefix => _trimSlashes(_value('API_PREFIX') ?? '');

  /// Public website host (used by the "sign up here" link), optional.
  static String? get websiteHost => _value('WEBSITE_HOST');

  /// Builds the URI of an API endpoint.
  static Uri apiUri(String path, [Map<String, dynamic>? params]) {
    final segments = [apiPrefix, _trimSlashes(path)].where((s) => s.isNotEmpty);
    return Uri(
      scheme: httpScheme,
      host: host,
      port: port,
      path: '/${segments.join('/')}',
      queryParameters: _stringifyParams(params),
    );
  }

  /// URI of the public website, or `null` if `WEBSITE_HOST` is not set.
  static Uri? websiteUri([String path = '/']) {
    final host = websiteHost;
    if (host == null) return null;
    return Uri(scheme: httpScheme, host: host, path: path);
  }

  static String _trimSlashes(String value) =>
      value.replaceAll(RegExp(r'^/+|/+$'), '');

  /// [Uri] only accepts `String` or `Iterable<String>` query values.
  static Map<String, dynamic>? _stringifyParams(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return null;
    final result = <String, dynamic>{};
    params.forEach((key, value) {
      if (value == null) return;
      result[key] = value is Iterable
          ? value.map((e) => e.toString()).toList()
          : value.toString();
    });
    return result;
  }
}
