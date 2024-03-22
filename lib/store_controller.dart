import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreController {
  StoreController();

  String themeKey = 'theme';
  String languageKey = 'language';
  String emailKey = 'email';
  String passwordKey = 'password';
  String typeKey = 'type';
  String idKey = 'id';
  String tokenKey = 'token';
  String brandKey = 'brand';
  String modelKey = 'model';
  String osKey = 'os';
  String keepLoggedKey = 'keep-logged';

  final FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // sharedPreferencesName: 'Test2',
        // preferencesKeyPrefix: 'Test'
      ),
      iOptions: IOSOptions(
        accountName: "FlutterTemplate",
      ));

  FlutterSecureStorage getSharedPreferences() {
    return storage;
  }

  ///
  /// SETTERS
  ///

  void setTheme(theme) {
    getSharedPreferences().write(key: themeKey, value: theme);
  }

  void setLanguage(lang) {
    getSharedPreferences().write(key: languageKey, value: lang);
  }

  void setToken(token) {
    getSharedPreferences().write(
        key: tokenKey, value: token.isEmpty ? token : token.split('|')[1]);
  }

  void setType(String type) {
    getSharedPreferences().write(key: typeKey, value: type);
  }

  void setEmail(email) {
    getSharedPreferences().write(key: emailKey, value: email);
  }

  void setPassword(password) {
    getSharedPreferences().write(key: passwordKey, value: password);
  }

  void setId(deviceId) {
    getSharedPreferences().write(key: idKey, value: deviceId);
  }

  void setBrand(brand) {
    getSharedPreferences().write(key: brandKey, value: brand);
  }

  void setModel(model) {
    getSharedPreferences().write(key: modelKey, value: model);
  }

  void setOs(os) {
    getSharedPreferences().write(key: osKey, value: os);
  }

  void setKeepLogged(keep) {
    getSharedPreferences().write(key: keepLoggedKey, value: keep ? '1' : '0');
  }

  ///
  /// GETTERS
  ///

  Future<String?> getTheme() async {
    return await getSharedPreferences().read(key: themeKey);
  }

  Future<String?> getType() async {
    return await getSharedPreferences().read(key: typeKey);
  }

  Future<String?> getLanguage() async {
    return await getSharedPreferences().read(key: languageKey) ?? "it,IT";
  }

  Future<String?> getToken() async {
    return await getSharedPreferences().read(key: tokenKey);
  }

  Future<String?> getEmail() async {
    return await getSharedPreferences().read(key: emailKey);
  }

  Future<String?> getPassword() async {
    return await getSharedPreferences().read(key: passwordKey);
  }

  Future<String?> getId() async {
    return await getSharedPreferences().read(key: idKey);
  }

  Future<String?> getBrand() async {
    return await getSharedPreferences().read(key: brandKey);
  }

  Future<String?> getModel() async {
    return await getSharedPreferences().read(key: modelKey);
  }

  Future<String?> getOs() async {
    return await getSharedPreferences().read(key: osKey);
  }

  Future<bool?> getKeepLogged() async {
    return await getSharedPreferences().read(key: keepLoggedKey) == '1';
  }
}
