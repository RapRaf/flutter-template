import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/providers/auth_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

enum OperatingSystems {
  unknown,
  web,
  android,
  iOS,
  linux,
  windows,
  xOS,
  unsupported
}

class StorageService {
  String themeKey = 'theme';
  String languageKey = 'language';
  String emailsKey = 'emails';
  String currentEmailKey = 'current-email';
  String passwordKey = 'password';
  String userIdKey = 'user-id';
  String typeKey = 'type';
  String idKey = 'id';
  String tokenKey = 'token';
  String sessionTokenKey = 'session-token';
  String brandKey = 'brand';
  String modelKey = 'model';
  String osKey = 'os';
  String keepLoggedKey = 'keep-logged';
  String lastUpdated = 'last-updated';

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

  Future<String> getUserId(FlutterSecureStorage storage) async {
    return await storage.read(key: userIdKey) ?? "";
  }

  Future<String> getSessionToken(FlutterSecureStorage storage) async {
    return await storage.read(key: sessionTokenKey) ?? "";
  }

  Future<int?> getLastUpdated(FlutterSecureStorage storage) async {
    String? res = await storage.read(key: lastUpdated);
    if (res == null || res.isEmpty) return null;
    return int.tryParse(res);
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

  Future<OperatingSystems> getOs(FlutterSecureStorage storage) async {
    switch (await storage.read(key: osKey) ?? "OperatingSystems.unknown") {
      case 'OperatingSystems.android':
        return OperatingSystems.android;
      case 'OperatingSystems.iOS':
        return OperatingSystems.iOS;
      case 'OperatingSystems.unknown':
        return OperatingSystems.unknown;
      // case 'OperatingSystems.web':
      //   return OperatingSystems.web;
      // case 'OperatingSystems.linux':
      //   return OperatingSystems.linux;
      // case 'OperatingSystems.windows':
      //   return OperatingSystems.windows;
      // case 'OperatingSystems.macOS':
      //   return OperatingSystems.xOS;
      default:
        return OperatingSystems.unsupported;
    }
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

  void setUserId({
    required FlutterSecureStorage storage,
    required String newUserId,
  }) {
    storage.write(key: userIdKey, value: newUserId);
  }

  void setSessionToken({
    required FlutterSecureStorage storage,
    required String newSessionToken,
  }) {
    storage.write(key: sessionTokenKey, value: newSessionToken);
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

  void setLastUpdate(
      {required FlutterSecureStorage storage, required int newLastUpdate}) {
    storage.write(key: lastUpdated, value: newLastUpdate.toString());
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
    required OperatingSystems newOS,
  }) {
    storage.write(key: osKey, value: newOS.toString());
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

  // DEVICE INITIALIZATION

  Future<OperatingSystems> initPlatformState(
      FlutterSecureStorage storage) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    OperatingSystems os;
    try {
      if (kIsWeb) {
        os = OperatingSystems.web;
      } else {
        os = switch (defaultTargetPlatform) {
          TargetPlatform.android => OperatingSystems.android,
          TargetPlatform.iOS => OperatingSystems.iOS,
          TargetPlatform.linux => OperatingSystems.linux,
          TargetPlatform.windows => OperatingSystems.windows,
          TargetPlatform.macOS => OperatingSystems.xOS,
          TargetPlatform.fuchsia => OperatingSystems.unsupported,
        };
      }

      storage.write(key: osKey, value: os.toString());

      if (os == OperatingSystems.unsupported) return os;

      String uuid = const Uuid().v4();

      switch (os) {
        case OperatingSystems.android:
          dynamic info =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
          storage.write(key: idKey, value: uuid);
          storage.write(key: brandKey, value: info['brand']);
          storage.write(key: modelKey, value: info['model']);
          break;
        case OperatingSystems.iOS:
          dynamic info = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          storage.write(key: idKey, value: uuid);
          storage.write(key: brandKey, value: info['systemName']);
          storage.write(
              key: modelKey, value: info['utsname.machine:']['iOSProductName']);
          break;
        case OperatingSystems.linux:
          dynamic info = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
          storage.write(key: idKey, value: uuid);
          storage.write(key: brandKey, value: info['machineId']);
          storage.write(key: modelKey, value: info['versionId']);
          break;
        case OperatingSystems.web:
          dynamic info =
              _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
          storage.write(key: idKey, value: uuid);
          storage.write(key: brandKey, value: info['vendor']);
          storage.write(key: modelKey, value: info['product']);
          break;
        case OperatingSystems.xOS:
          dynamic info = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
          storage.write(key: idKey, value: uuid);
          storage.write(key: brandKey, value: 'Apple');
          storage.write(key: modelKey, value: info['model']);
          break;
        case OperatingSystems.windows:
          dynamic info =
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
          storage.write(key: idKey, value: uuid);
          storage.write(key: brandKey, value: 'productName');
          storage.write(key: modelKey, value: info['productId']);
          break;
        default:
          return os;
      }
    } on PlatformException {
      return OperatingSystems.unsupported;
    }
    return os;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }
}
