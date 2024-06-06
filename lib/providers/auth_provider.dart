import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/models/http_request.dart';
import 'package:flutter_template/providers/fingerprint_service.dart';
import 'package:flutter_template/providers/http_service.dart';
import 'package:flutter_template/providers/snackbar_service.dart';
import 'package:flutter_template/providers/storage_service.dart';

class AuthProvider with ChangeNotifier {
  int _loginState = 0;
  late ThemeMode _theme = ThemeMode.system;
  late String _language = 'en,US';
  late List<String> _emails;
  late String _currentMail;
  late String _password;
  late String _token;
  late String _type;
  late String _id;
  late String _brand;
  late String _model;
  late String _os;
  late bool _keepLogged;
  late FlutterSecureStorage _storage;
  late StorageService _storeService;
  late HttpService _httpService;
  late SnackBarService _snackBarService;
  late FingerprintService _fingerprintService;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final Future<void> initialization;

  ThemeMode get theme => _theme;
  String get language => _language;
  List<String> get emails => _emails;
  String get currentMail => _currentMail;
  String get password => _password;
  String get token => _token;
  String get type => _type;
  String get id => _id;
  String get brand => _brand;
  String get model => _model;
  String get os => _os;
  int get loginState => _loginState;
  bool get keepLogged => _keepLogged;
  FlutterSecureStorage get storage => _storage;

  AuthProvider() {
    initialization = _initialize();
  }

  Future<void> _initialize() async {
    _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accountName: "Raffa",
        ));
    _storeService = StorageService(authProvider: this);
    await _loadFromStorage();
    _httpService = HttpService(authProvider: this);
    _snackBarService = SnackBarService(authProvider: this);
    _fingerprintService = FingerprintService();
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    _theme = await _storeService.getTheme(storage);
    _language = await _storeService.getLanguage(storage);
    _currentMail = await _storeService.getCurrentEmail(storage);
    _type = await _storeService.getType(storage, currentMail);
    _token = await _storeService.getToken(storage);
    _keepLogged = await _storeService.getKeepLogged(storage);
    _emails = await _storeService.getEmails(storage);
    // _id = await _storeService.getId(storage);
    // _brand = await _storeService.getBrand(storage);
    // _model = await _storeService.getModel(storage);
    // _os = await _storeService.getOs(storage);
  }

  void initProvider() async {
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
  }) async {
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
  }) async {
    _password = newPassword;
    _storeService.setPassword(
        storage: storage, email: email, newPassword: newPassword);
    notifyListeners();
  }

  void setToken({
    required String newToken,
  }) async {
    _token = newToken;
    _storeService.setToken(storage: storage, newToken: newToken);
    notifyListeners();
  }

  void setTheme({
    required ThemeMode newTheme,
  }) async {
    _theme = newTheme;
    _storeService.setTheme(storage: storage, newTheme: newTheme);
    notifyListeners();
  }

  void setLanguage({
    required String newLanguage,
  }) async {
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
    required String newOS,
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

  void sendRequest(HttpEntry request, BuildContext context) {
    _httpService.addToQueue(httpEntry: request);
  }

  void handleLoginResponse(
      Map<String, dynamic> response, String email, String password) {
    _currentMail = email;
    _password = "";
    _token = response['data']['token'];
    _type = response['data']['role'];
    _storeService.setToken(
        storage: storage, newToken: response['data']['token']);
    _storeService.setType(
        storage: storage, newType: response['data']['role'], email: email);
    _storeService.setCurrentEmail(storage: storage, newCurrentEmail: email);
    _storeService.setPassword(
        storage: storage, email: email, newPassword: password);
    _loginState = 2;

    notifyListeners();
  }

  void handleLogoutResponse() {
    _token = "";
    _type = "";
    _storeService.setToken(storage: storage, newToken: "");
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
}
