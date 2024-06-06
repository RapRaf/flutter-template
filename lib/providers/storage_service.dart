import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/providers/auth_provider.dart';

class StorageService {
  String themeKey = 'theme';
  String languageKey = 'language';
  String emailsKey = 'emails';
  String currentEmailKey = 'current-email';
  String passwordKey = 'password';
  String typeKey = 'type';
  String idKey = 'id';
  String tokenKey = 'token';
  String brandKey = 'brand';
  String modelKey = 'model';
  String osKey = 'os';
  String keepLoggedKey = 'keep-logged';

  AuthProvider authProvider;

  StorageService({required this.authProvider});

  Future<ThemeMode> getTheme(FlutterSecureStorage storage) async {
    switch (await storage.read(key: themeKey) ?? "ThemeMode.system") {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // GETTERS

  Future<String> getLanguage(FlutterSecureStorage storage) async {
    return await storage.read(key: languageKey) ?? "en,US";
  }

  Future<String> getToken(FlutterSecureStorage storage) async {
    return await storage.read(key: tokenKey) ?? "";
  }

  Future<List<String>> getEmails(FlutterSecureStorage storage) async {
    String emails = await storage.read(key: emailsKey) ?? "";
    if (emails.isEmpty) return [];
    return emails.split(',');
  }

  Future<String> getCurrentEmail(FlutterSecureStorage storage) async {
    return await storage.read(key: currentEmailKey) ?? "";
  }

  Future<String?> getPassword(
      FlutterSecureStorage storage, String email) async {
    return await storage.read(key: email);
  }

  Future<String> getType(FlutterSecureStorage storage, String email) async {
    return await storage.read(key: '$typeKey-$email') ?? 'player';
  }

  Future<bool> getKeepLogged(FlutterSecureStorage storage) async {
    return await storage.read(key: keepLoggedKey) == '1';
  }

  Future<String> getId(FlutterSecureStorage storage) async {
    return await storage.read(key: idKey) ?? "";
  }

  Future<String> getBrand(FlutterSecureStorage storage) async {
    return await storage.read(key: brandKey) ?? "";
  }

  Future<String> getModel(FlutterSecureStorage storage) async {
    return await storage.read(key: modelKey) ?? "";
  }

  Future<String> getOs(FlutterSecureStorage storage) async {
    return await storage.read(key: osKey) ?? "";
  }

  // SETTERS

  Future<void> setCurrentEmail({
    required FlutterSecureStorage storage,
    required String newCurrentEmail,
  }) async {
    storage.write(key: currentEmailKey, value: newCurrentEmail);
    if (newCurrentEmail.isEmpty) return;

    List<String> emails = authProvider.emails;
    for (String email in emails) {
      if (email == newCurrentEmail) return;
    }
    emails.add(newCurrentEmail);
    await storage.write(key: emailsKey, value: emails.join(','));
  }

  void setPassword({
    required FlutterSecureStorage storage,
    required String email,
    required String newPassword,
  }) {
    storage.write(key: email, value: newPassword);
  }

  void setToken({
    required FlutterSecureStorage storage,
    required String newToken,
  }) {
    storage.write(key: tokenKey, value: newToken);
  }

  void setTheme({
    required FlutterSecureStorage storage,
    required ThemeMode newTheme,
  }) {
    storage.write(key: themeKey, value: newTheme.toString());
  }

  void setLanguage({
    required FlutterSecureStorage storage,
    required String newLanguage,
  }) {
    storage.write(key: languageKey, value: newLanguage);
  }

  void setType(
      {required FlutterSecureStorage storage,
      required String newType,
      required String email}) {
    storage.write(key: '$typeKey-$email', value: newType);
  }

  void setID({
    required FlutterSecureStorage storage,
    required String newID,
  }) {
    storage.write(key: idKey, value: newID);
  }

  void setBrand({
    required FlutterSecureStorage storage,
    required String newBrand,
  }) {
    storage.write(key: brandKey, value: newBrand);
  }

  void setModel({
    required FlutterSecureStorage storage,
    required String newModel,
  }) {
    storage.write(key: modelKey, value: newModel);
  }

  void setOS({
    required FlutterSecureStorage storage,
    required String newOS,
  }) {
    storage.write(key: osKey, value: newOS);
  }

  void setKeepLogged({
    required FlutterSecureStorage storage,
    required bool keepLogged,
  }) async {
    storage.write(key: keepLoggedKey, value: keepLogged ? '1' : '0');
  }

  Future<void> deleteAccount({
    required FlutterSecureStorage storage,
    required String account,
  }) async {
    if (account.isEmpty) return;

    List<String> nuovi = [];
    for (String email in authProvider.emails) {
      if (email != account) nuovi.add(email);
    }
    await storage.write(key: emailsKey, value: nuovi.join(','));
    await storage.delete(key: account);
    await storage.delete(key: '$typeKey-$account');
  }
}
