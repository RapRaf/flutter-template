import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/http_requests/auth/auth.dart';
import 'package:flutter_template/localization/app_localizations.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/fingerprint_service.dart';
import 'package:flutter_template/providers/http_service.dart';
import 'package:flutter_template/providers/snackbar_service.dart';
import 'package:flutter_template/providers/storage_service.dart';
import 'package:http/http.dart' as http;

enum LoginState {
  /// Checking the saved token with the server (LoadingScreen).
  loading,

  /// No valid session: show the login page.
  loggedOut,

  /// Session ready: show the app.
  loggedIn,
}

class AuthProvider with ChangeNotifier {
  LoginState _loginState = LoginState.loading;
  ThemeMode _theme = ThemeMode.system;
  String _language = StorageService.defaultLanguage;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Completes with `false` when the device is not supported.
  late final Future<bool> initialization;

  List<String> _emails = [];
  String _currentMail = '';
  String _userId = '';
  String _token = '';
  String _sessionToken = '';
  String _type = '';
  String _id = '';
  String _brand = '';
  String _model = '';
  int? _lastUpdate;
  OperatingSystems _os = OperatingSystems.unknown;
  bool _keepLogged = false;
  bool _disposed = false;

  final StorageService _storeService;
  final DeviceInfoPlugin? _deviceInfo;
  late final HttpService _httpService;
  late final SnackBarService _snackBarService;
  final FingerprintService _fingerprintService;

  ThemeMode get theme => _theme;

  /// Language code, one of [supportedLanguageCodes].
  String get language => _language;
  Locale get locale => Locale(_language);
  AppLocalizations get localizations => lookupAppLocalizations(locale);
  List<String> get emails => List.unmodifiable(_emails);
  String get currentMail => _currentMail;
  String get userId => _userId;
  String get token => _token;
  String get sessionToken => _sessionToken;
  String get type => _type;
  String get id => _id;
  String get brand => _brand;
  String get model => _model;
  int? get lastUpdate => _lastUpdate;
  OperatingSystems get os => _os;
  LoginState get loginState => _loginState;
  bool get keepLogged => _keepLogged;
  FlutterSecureStorage get storage => _storeService.storage;
  HttpService get httpService => _httpService;

  static List<String> get supportedLanguageCodes => AppLocalizations
      .supportedLocales
      .map((locale) => locale.languageCode)
      .toList();

  AuthProvider({
    StorageService? storageService,
    FingerprintService? fingerprintService,
    DeviceInfoPlugin? deviceInfo,
    http.Client? httpClient,
  }) : _storeService = storageService ?? StorageService(),
       _fingerprintService = fingerprintService ?? FingerprintService(),
       _deviceInfo = deviceInfo {
    _httpService = HttpService(authProvider: this, client: httpClient);
    _snackBarService = SnackBarService(authProvider: this);
    initialization = _initialize();
  }

  Future<bool> _initialize() async {
    final supported = await _loadFromStorage();
    await _fingerprintService.initialization;
    _notify();
    return supported;
  }

  Future<bool> _loadFromStorage() async {
    _theme = await _storeService.getTheme();
    _language = _validLanguage(await _storeService.getLanguage());
    _currentMail = await _storeService.getCurrentEmail();
    _userId = await _storeService.getUserId();
    _type = _currentMail.isEmpty
        ? ''
        : await _storeService.getType(_currentMail);
    _token = await _storeService.getToken();
    _sessionToken = await _storeService.getSessionToken();
    _keepLogged = await _storeService.getKeepLogged();
    _emails = await _storeService.getEmails();
    _lastUpdate = await _storeService.getLastUpdated();

    final device = await _storeService.loadDeviceData(deviceInfo: _deviceInfo);
    _os = device.os;
    _id = device.id;
    _brand = device.brand;
    _model = device.model;
    return device.isSupported;
  }

  static String _validLanguage(String code) =>
      supportedLanguageCodes.contains(code)
      ? code
      : StorageService.defaultLanguage;

  @override
  void dispose() {
    _disposed = true;
    _httpService.dispose();
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Notifies only once logged in (used by the request queue).
  void mNotifyListeners() {
    if (_loginState == LoginState.loggedIn) _notify();
  }

  Future<String?> getPassword(String email) => _storeService.getPassword(email);

  Future<String> getType(String email) => _storeService.getType(email);

  void setLoginState({required LoginState newLoginState}) {
    if (_loginState == newLoginState) return;
    _loginState = newLoginState;
    _notify();
  }

  Future<void> setCurrentEmail({required String newCurrentMail}) async {
    _currentMail = newCurrentMail;
    await _storeService.setCurrentEmail(newCurrentEmail: newCurrentMail);
    _emails = await _storeService.getEmails();
    _notify();
  }

  Future<void> setPassword({
    required String email,
    required String newPassword,
  }) => _storeService.setPassword(email: email, newPassword: newPassword);

  Future<void> setToken({required String newToken}) {
    _token = newToken;
    _notify();
    return _storeService.setToken(newToken: newToken);
  }

  Future<void> setSessionToken({required String newSessionToken}) {
    _sessionToken = newSessionToken;
    _notify();
    return _storeService.setSessionToken(newSessionToken: newSessionToken);
  }

  Future<void> setTheme({required ThemeMode newTheme}) {
    _theme = newTheme;
    _notify();
    return _storeService.setTheme(newTheme: newTheme);
  }

  /// [newLanguage] is a language code (`en`, `it`...).
  Future<void> setLanguage({required String newLanguage}) {
    _language = _validLanguage(newLanguage);
    _notify();
    return _storeService.setLanguage(newLanguage: _language);
  }

  Future<void> setType({required String email, required String newType}) {
    _type = newType;
    _notify();
    return _storeService.setType(newType: newType, email: email);
  }

  Future<void> setLastUpdate({required int lastUpdate}) {
    _lastUpdate = lastUpdate;
    return _storeService.setLastUpdate(newLastUpdate: lastUpdate);
  }

  Future<void> setID({required String newID}) {
    _id = newID;
    _notify();
    return _storeService.setID(newID: newID);
  }

  Future<void> setBrand({required String newBrand}) {
    _brand = newBrand;
    _notify();
    return _storeService.setBrand(newBrand: newBrand);
  }

  Future<void> setModel({required String newModel}) {
    _model = newModel;
    _notify();
    return _storeService.setModel(newModel: newModel);
  }

  Future<void> setOS({required OperatingSystems newOS}) {
    _os = newOS;
    _notify();
    return _storeService.setOS(newOS: newOS);
  }

  /// Toggles "keep me logged in".
  Future<void> setKeepLogged() {
    _keepLogged = !_keepLogged;
    _notify();
    return _storeService.setKeepLogged(keepLogged: _keepLogged);
  }

  void sendRequest(HttpEntry request) {
    _httpService.addToQueue(httpEntry: request);
  }

  /// Saves the session returned by the login API.
  /// DEPENDS ON BACKEND RESPONSE: `{"data": {"token", "id", "role"}}`.
  Future<void> handleLoginResponse(
    Map<String, dynamic> response,
    String email,
    String password,
  ) async {
    final data = response['data'];
    final token = data is Map ? data['token'] : null;
    if (data is! Map || token is! String || token.isEmpty) {
      showSnackBar(localizations.generic_error);
      return;
    }

    _currentMail = email;
    _token = token;
    _type = '${data['role'] ?? ''}';
    _userId = '${data['id'] ?? ''}';
    if (!_emails.contains(email)) _emails = [..._emails, email];
    // The LoadingScreen validates the token and opens the session.
    _loginState = LoginState.loading;
    _notify();

    await _storeService.setToken(newToken: _token);
    await _storeService.setUserId(newUserId: _userId);
    await _storeService.setType(newType: _type, email: email);
    await _storeService.setCurrentEmail(newCurrentEmail: email);
    // Saved for biometric / automatic login. Prefer a refresh token if your
    // backend supports it.
    await _storeService.setPassword(email: email, newPassword: password);
  }

  /// Logs out immediately, without waiting for the server (no 30s wait when
  /// offline). The server is notified on a best-effort basis.
  Future<void> logout() async {
    // Pending requests belong to the old session.
    _httpService.reset();
    if (_token.isNotEmpty) {
      // Sent right away (empty queue), so it still carries the current token.
      sendRequest(
        HttpRequests().logOut(
          responseListener: (_) {},
          errorListener: (_, _) {},
        ),
      );
    }
    await _clearSession();
  }

  Future<void> _clearSession() async {
    // Drops the logout request too: its response is not needed.
    _httpService.reset();
    _token = '';
    _sessionToken = '';
    _type = '';
    _userId = '';
    _currentMail = '';
    _loginState = LoginState.loggedOut;
    _notify();

    await _storeService.setToken(newToken: '');
    await _storeService.setSessionToken(newSessionToken: '');
    await _storeService.setUserId(newUserId: '');
    await _storeService.setCurrentEmail(newCurrentEmail: '');
  }

  /// Called by the request queue when the server refuses the session.
  Future<void> handleSessionExpired() async {
    if (_loginState == LoginState.loggedOut) return;
    _httpService.reset();
    _token = '';
    _sessionToken = '';
    _loginState = LoginState.loggedOut;
    _notify();
    showSnackBar(localizations.session_expired);

    await _storeService.setToken(newToken: '');
    await _storeService.setSessionToken(newSessionToken: '');
  }

  /// [response] can be a `String` or a server response map.
  void showSnackBar(Object? response) {
    _snackBarService.showSnackBar(response);
  }

  void removeSnackBar() {
    _snackBarService.removeSnackBar();
  }

  void hideSnackBar() {
    _snackBarService.hideSnackBar();
  }

  bool hasFingerPrints() {
    return _fingerprintService.isSupported;
  }

  Future<bool> authFingerprints() {
    return _fingerprintService.authenticate(
      localizedReason: localizations.biometric_reason,
    );
  }

  Future<void> deleteAccount(String account) async {
    await _storeService.deleteAccount(account: account);
    _emails = await _storeService.getEmails();
    if (_currentMail == account) _currentMail = '';
    _notify();
  }
}
