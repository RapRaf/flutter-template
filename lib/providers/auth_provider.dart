import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/fingerprint_service.dart';
import 'package:flutter_template/providers/http_service.dart';
import 'package:flutter_template/providers/snackbar_service.dart';
import 'package:flutter_template/providers/storage_service.dart';

class AuthProvider with ChangeNotifier {
  int _loginState = 0;
  ThemeMode _theme = ThemeMode.system;
  String _language = 'en,US';
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final Future<bool> initialization;

  late List<String> _emails;
  late String _currentMail;
  late String _password;
  late String? _userId;
  late String _token;
  late String _sessionToken;
  late String _type;
  late String _id;
  late String _brand;
  late String _model;
  late int? _lastUpdate;
  late OperatingSystems _os;
  late bool _keepLogged;
  bool _justLogged = false;
  late FlutterSecureStorage _storage;
  late StorageService _storeService;
  late HttpService _httpService;
  late SnackBarService _snackBarService;
  late FingerprintService _fingerprintService;
  bool _isDark = false;

  ThemeMode get theme => _theme;
  String get language => _language;
  List<String> get emails => _emails;
  String get currentMail => _currentMail;
  String get password => _password;
  String? get userId => _userId;
  String get token => _token;
  String get sessionToken => _sessionToken;
  String get type => _type;
  String get id => _id;
  String get brand => _brand;
  String get model => _model;
  int? get lastUpdate => _lastUpdate;
  OperatingSystems get os => _os;
  int get loginState => _loginState;
  bool get keepLogged => _keepLogged;
  bool get justLogged => _justLogged;
  FlutterSecureStorage get storage => _storage;
  HttpService get httpService => _httpService;
  bool get isDark => _isDark;

  AuthProvider() {
    initialization = _initialize();
  }

  Future<bool> _initialize() async {
    _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accountName: "FlutterTemplate",
        ));
    _storeService = StorageService(authProvider: this);
    if (!await _loadFromStorage()) return false;
    _httpService = HttpService(authProvider: this);
    _snackBarService = SnackBarService(authProvider: this);
    _fingerprintService = FingerprintService();
    notifyListeners();
    return true;
  }

  Future<bool> _loadFromStorage() async {
    _theme = await _storeService.getTheme(storage);
    _language = await _storeService.getLanguage(storage);
    _currentMail = await _storeService.getCurrentEmail(storage);
    _userId = await _storeService.getUserId(storage);
    _type = await _storeService.getType(storage, currentMail);
    _token = await _storeService.getToken(storage);
    _sessionToken = await _storeService.getSessionToken(storage);
    _keepLogged = await _storeService.getKeepLogged(storage);
    _emails = await _storeService.getEmails(storage);
    _lastUpdate = await _storeService.getLastUpdated(storage);
    _os = await _storeService.getOs(storage);
    if (_os == OperatingSystems.unsupported) return false;
    if (_os == OperatingSystems.unknown) {
      _os = await _storeService.initPlatformState(storage);
      if (_os == OperatingSystems.unsupported) return false;
    }
    _id = await _storeService.getId(storage);
    _brand = await _storeService.getBrand(storage);
    _model = await _storeService.getModel(storage);
    return true;
  }

  void mNotifyListeners() {
    if (_loginState == 2) notifyListeners();
  }

  void initProvider() async {
    _httpService = HttpService(authProvider: this);
    _snackBarService = SnackBarService(authProvider: this);
    _fingerprintService = FingerprintService();
    _currentMail = await _storeService.getCurrentEmail(storage);
    _type = await _storeService.getType(storage, currentMail);
    _token = await _storeService.getToken(storage);
    _keepLogged = await _storeService.getKeepLogged(storage);
    _emails = await _storeService.getEmails(storage);
    _loginState = 0;
    notifyListeners();
  }

  Future<String?> getPassword(String email) async {
    return await _storeService.getPassword(storage, email);
  }

  Future<String> getType(String email) async {
    return await _storeService.getType(storage, email);
  }

  void setLoginState({
    required int newLoginState,
  }) {
    _loginState = newLoginState;
    notifyListeners();
  }

  void setCurrentEmail({
    required String newCurrentMail,
  }) async {
    _currentMail = newCurrentMail;
    await _storeService.setCurrentEmail(
        storage: storage, newCurrentEmail: newCurrentMail);
    _emails = await _storeService.getEmails(storage);
    notifyListeners();
  }

  void setPassword({
    required String email,
    required String newPassword,
  }) {
    _password = newPassword;
    _storeService.setPassword(
        storage: storage, email: email, newPassword: newPassword);
    notifyListeners();
  }

  void setToken({
    required String newToken,
  }) {
    _token = newToken;
    _storeService.setToken(storage: storage, newToken: newToken);
    notifyListeners();
  }

  void setSessionToken({
    required String newSessionToken,
  }) {
    _sessionToken = newSessionToken;
    _storeService.setSessionToken(
        storage: storage, newSessionToken: newSessionToken);
    notifyListeners();
  }

  void setTheme({
    required ThemeMode newTheme,
  }) {
    _theme = newTheme;
    _storeService.setTheme(storage: storage, newTheme: newTheme);
    notifyListeners();
  }

  void setLanguage({
    required String newLanguage,
  }) {
    _language = newLanguage;
    _storeService.setLanguage(storage: storage, newLanguage: newLanguage);
    notifyListeners();
  }

  void setType({
    required String email,
    required String newType,
  }) async {
    _type = newType;
    _storeService.setType(storage: storage, newType: newType, email: email);
    notifyListeners();
  }

  void setLastUpdate({required int lastUpdate}) {
    _lastUpdate = lastUpdate;
    _storeService.setLastUpdate(storage: storage, newLastUpdate: lastUpdate);
  }

  void setID({
    required String newID,
  }) async {
    _id = newID;
    _storeService.setID(storage: storage, newID: newID);
    notifyListeners();
  }

  void setBrand({
    required String newBrand,
  }) async {
    _brand = newBrand;
    _storeService.setBrand(storage: storage, newBrand: newBrand);
    notifyListeners();
  }

  void setModel({
    required String newModel,
  }) async {
    _model = newModel;
    _storeService.setModel(storage: storage, newModel: newModel);
    notifyListeners();
  }

  void setOS({
    required OperatingSystems newOS,
  }) async {
    _os = newOS;
    _storeService.setOS(storage: storage, newOS: newOS);
    notifyListeners();
  }

  void setKeepLogged() async {
    _keepLogged = !_keepLogged;
    _storeService.setKeepLogged(storage: storage, keepLogged: keepLogged);
    notifyListeners();
  }

  void sendRequest(HttpEntry request) {
    _httpService.addToQueue(httpEntry: request);
  }

  void handleLoginResponse(
      Map<String, dynamic> response, String email, String password) {
        /// DEPENDS ON BACKEND RESPONSE
    _storeService.setToken(
        storage: storage, newToken: response['data']['token']);
    _storeService.setUserId(
        storage: storage, newUserId: response['data']['id'].toString());
    _storeService.setType(
        storage: storage, newType: response['data']['role'], email: email);
    _storeService.setCurrentEmail(storage: storage, newCurrentEmail: email);
    _storeService.setPassword(
        storage: storage, email: email, newPassword: password);

    _currentMail = email;
    _password = "";
    _token = response['data']['token'];
    _type = response['data']['role'];
    _userId = response['data']['id'].toString();
    _loginState = 0;
    _justLogged = true;
    notifyListeners();
  }

  void fetchForLogin() {
    _justLogged = false;
  }

  void handleLogoutResponse() {
    _storeService.setToken(storage: storage, newToken: "");
    _storeService.setUserId(storage: storage, newUserId: "");

    _token = "";
    _type = "";
    _userId = "";
    _currentMail = "";
    _password = "";
    _loginState = 0;
    notifyListeners();
  }

  void showSnackBar(response) {
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
    return _fingerprintService.authenticate();
  }

  void deleteAccount(String account) async {
    await _storeService.deleteAccount(storage: storage, account: account);
    _emails = await _storeService.getEmails(storage);
    notifyListeners();
  }

  void setDark(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }
}
