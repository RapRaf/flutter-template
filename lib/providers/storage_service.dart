import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

enum OperatingSystems {
  unknown,
  web,
  android,
  iOS,
  linux,
  windows,
  xOS,
  unsupported,
}

/// Platforms the app accepts. Add e.g. [OperatingSystems.linux] here to
/// enable it (remember the platform setup required by the plugins).
const Set<OperatingSystems> supportedOperatingSystems = {
  OperatingSystems.android,
  OperatingSystems.iOS,
};

/// Information about the device, persisted on first launch.
class DeviceData {
  final OperatingSystems os;
  final String id;
  final String brand;
  final String model;

  const DeviceData({
    required this.os,
    required this.id,
    required this.brand,
    required this.model,
  });

  bool get isSupported => supportedOperatingSystems.contains(os);
}

/// Persistent app state, saved in the platform secure storage.
class StorageService {
  static const themeKey = 'theme';
  static const languageKey = 'language';
  static const emailsKey = 'emails';
  static const currentEmailKey = 'current-email';
  static const passwordKeyPrefix = 'password';
  static const userIdKey = 'user-id';
  static const typeKey = 'type';
  static const idKey = 'id';
  static const tokenKey = 'token';
  static const sessionTokenKey = 'session-token';
  static const brandKey = 'brand';
  static const modelKey = 'model';
  static const osKey = 'os';
  static const keepLoggedKey = 'keep-logged';
  static const lastUpdatedKey = 'last-updated';

  static const defaultLanguage = 'en';

  final FlutterSecureStorage storage;

  StorageService({FlutterSecureStorage? storage})
    : storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(accountName: 'FlutterTemplate'),
          );

  // GETTERS

  Future<ThemeMode> getTheme() async {
    final value = await storage.read(key: themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => value == mode.name || value == mode.toString(),
      orElse: () => ThemeMode.system,
    );
  }

  /// Language code (`en`, `it`...). Also accepts the legacy `en,US` format.
  Future<String> getLanguage() async {
    final value = await storage.read(key: languageKey);
    if (value == null || value.isEmpty) return defaultLanguage;
    return value.split(RegExp('[,_-]')).first.toLowerCase();
  }

  Future<String> getToken() async => await storage.read(key: tokenKey) ?? '';

  Future<String> getUserId() async => await storage.read(key: userIdKey) ?? '';

  Future<String> getSessionToken() async =>
      await storage.read(key: sessionTokenKey) ?? '';

  Future<int?> getLastUpdated() async {
    final value = await storage.read(key: lastUpdatedKey);
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  Future<List<String>> getEmails() async {
    final emails = await storage.read(key: emailsKey) ?? '';
    return emails.split(',').where((e) => e.isNotEmpty).toList();
  }

  Future<String> getCurrentEmail() async =>
      await storage.read(key: currentEmailKey) ?? '';

  Future<String?> getPassword(String email) =>
      storage.read(key: _passwordKey(email));

  Future<String> getType(String email) async =>
      await storage.read(key: _typeKey(email)) ?? '';

  Future<bool> getKeepLogged() async =>
      await storage.read(key: keepLoggedKey) == '1';

  Future<String> getId() async => await storage.read(key: idKey) ?? '';

  Future<String> getBrand() async => await storage.read(key: brandKey) ?? '';

  Future<String> getModel() async => await storage.read(key: modelKey) ?? '';

  Future<OperatingSystems> getOs() async {
    final value = await storage.read(key: osKey);
    if (value == null || value.isEmpty) return OperatingSystems.unknown;
    return OperatingSystems.values.firstWhere(
      (os) => value == os.name || value == os.toString(),
      orElse: () => OperatingSystems.unknown,
    );
  }

  // SETTERS

  /// Saves the current account and adds it to the list of known accounts.
  Future<void> setCurrentEmail({required String newCurrentEmail}) async {
    await storage.write(key: currentEmailKey, value: newCurrentEmail);
    if (newCurrentEmail.isEmpty) return;

    final emails = await getEmails();
    if (emails.contains(newCurrentEmail)) return;
    emails.add(newCurrentEmail);
    await storage.write(key: emailsKey, value: emails.join(','));
  }

  Future<void> setPassword({
    required String email,
    required String newPassword,
  }) => storage.write(key: _passwordKey(email), value: newPassword);

  Future<void> setToken({required String newToken}) =>
      storage.write(key: tokenKey, value: newToken);

  Future<void> setUserId({required String newUserId}) =>
      storage.write(key: userIdKey, value: newUserId);

  Future<void> setSessionToken({required String newSessionToken}) =>
      storage.write(key: sessionTokenKey, value: newSessionToken);

  Future<void> setTheme({required ThemeMode newTheme}) =>
      storage.write(key: themeKey, value: newTheme.name);

  Future<void> setLanguage({required String newLanguage}) =>
      storage.write(key: languageKey, value: newLanguage);

  Future<void> setType({required String newType, required String email}) =>
      storage.write(key: _typeKey(email), value: newType);

  Future<void> setLastUpdate({required int newLastUpdate}) =>
      storage.write(key: lastUpdatedKey, value: newLastUpdate.toString());

  Future<void> setID({required String newID}) =>
      storage.write(key: idKey, value: newID);

  Future<void> setBrand({required String newBrand}) =>
      storage.write(key: brandKey, value: newBrand);

  Future<void> setModel({required String newModel}) =>
      storage.write(key: modelKey, value: newModel);

  Future<void> setOS({required OperatingSystems newOS}) =>
      storage.write(key: osKey, value: newOS.name);

  Future<void> setKeepLogged({required bool keepLogged}) =>
      storage.write(key: keepLoggedKey, value: keepLogged ? '1' : '0');

  /// Removes a saved account (and its password) from the device.
  Future<void> deleteAccount({required String account}) async {
    if (account.isEmpty) return;

    final emails = await getEmails();
    emails.remove(account);
    await storage.write(key: emailsKey, value: emails.join(','));
    await storage.delete(key: _passwordKey(account));
    await storage.delete(key: _typeKey(account));
    if (await getCurrentEmail() == account) {
      await storage.write(key: currentEmailKey, value: '');
    }
  }

  String _passwordKey(String email) => '$passwordKeyPrefix-$email';

  String _typeKey(String email) => '$typeKey-$email';

  // DEVICE INITIALIZATION

  /// Returns the stored device data, detecting and saving it on first launch.
  Future<DeviceData> loadDeviceData({DeviceInfoPlugin? deviceInfo}) async {
    var os = await getOs();
    var id = await getId();
    if (os != OperatingSystems.unknown && id.isNotEmpty) {
      return DeviceData(
        os: os,
        id: id,
        brand: await getBrand(),
        model: await getModel(),
      );
    }

    os = detectOperatingSystem();
    id = id.isNotEmpty ? id : const Uuid().v4();
    var brand = '';
    var model = '';

    if (supportedOperatingSystems.contains(os)) {
      try {
        (brand, model) = await _readBrandAndModel(
          os,
          deviceInfo ?? DeviceInfoPlugin(),
        );
      } catch (e) {
        // Device info is only informative: never block the app because of it.
        debugPrint('Unable to read device info: $e');
      }
    }

    await setOS(newOS: os);
    await setID(newID: id);
    await setBrand(newBrand: brand);
    await setModel(newModel: model);
    return DeviceData(os: os, id: id, brand: brand, model: model);
  }

  static OperatingSystems detectOperatingSystem() {
    if (kIsWeb) return OperatingSystems.web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => OperatingSystems.android,
      TargetPlatform.iOS => OperatingSystems.iOS,
      TargetPlatform.linux => OperatingSystems.linux,
      TargetPlatform.windows => OperatingSystems.windows,
      TargetPlatform.macOS => OperatingSystems.xOS,
      TargetPlatform.fuchsia => OperatingSystems.unsupported,
    };
  }

  Future<(String, String)> _readBrandAndModel(
    OperatingSystems os,
    DeviceInfoPlugin plugin,
  ) async {
    switch (os) {
      case OperatingSystems.android:
        final info = await plugin.androidInfo;
        return (info.brand, info.model);
      case OperatingSystems.iOS:
        final info = await plugin.iosInfo;
        return ('Apple', info.modelName);
      case OperatingSystems.xOS:
        final info = await plugin.macOsInfo;
        return ('Apple', info.modelName);
      case OperatingSystems.linux:
        final info = await plugin.linuxInfo;
        return (info.name, info.prettyName);
      case OperatingSystems.windows:
        final info = await plugin.windowsInfo;
        return ('Microsoft', info.productName);
      case OperatingSystems.web:
        final info = await plugin.webBrowserInfo;
        return (info.vendor ?? '', info.browserName.name);
      case OperatingSystems.unknown:
      case OperatingSystems.unsupported:
        return ('', '');
    }
  }
}
