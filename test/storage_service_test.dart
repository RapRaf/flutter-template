import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/providers/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  StorageService create(Map<String, String> values) {
    FlutterSecureStorage.setMockInitialValues(values);
    return StorageService();
  }

  test('reads values saved by the previous version', () async {
    final storage = create({
      'language': 'it,IT',
      'theme': 'ThemeMode.dark',
      'os': 'OperatingSystems.iOS',
    });
    expect(await storage.getLanguage(), 'it');
    expect(await storage.getTheme(), ThemeMode.dark);
    expect(await storage.getOs(), OperatingSystems.iOS);
  });

  test('saved accounts: no duplicates, delete removes the password', () async {
    final storage = create({});
    await storage.setCurrentEmail(newCurrentEmail: 'a@test.it');
    await storage.setCurrentEmail(newCurrentEmail: 'b@test.it');
    await storage.setCurrentEmail(newCurrentEmail: 'a@test.it');
    await storage.setPassword(email: 'a@test.it', newPassword: 'secret');
    expect(await storage.getEmails(), ['a@test.it', 'b@test.it']);
    expect(await storage.getPassword('a@test.it'), 'secret');

    await storage.deleteAccount(account: 'a@test.it');
    expect(await storage.getEmails(), ['b@test.it']);
    expect(await storage.getPassword('a@test.it'), isNull);
    expect(await storage.getCurrentEmail(), isEmpty);
  });

  test('device data is generated once and then reused', () async {
    final storage = create({});
    final first = await storage.loadDeviceData();
    final second = await storage.loadDeviceData();
    // Tests run as Android.
    expect(first.os, OperatingSystems.android);
    expect(first.isSupported, isTrue);
    expect(first.id, isNotEmpty);
    expect(second.id, first.id);
  });

  test('unsupported platforms stay unsupported on the next launch', () async {
    final storage = create({'os': 'linux', 'id': 'x'});
    final data = await storage.loadDeviceData();
    expect(data.os, OperatingSystems.linux);
    expect(data.isSupported, isFalse);
  });
}
