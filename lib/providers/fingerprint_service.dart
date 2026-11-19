import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Device authentication (fingerprint, face, PIN...) through `local_auth`.
class FingerprintService {
  final LocalAuthentication auth;
  bool _isSupported = false;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  bool _authorized = false;
  bool _isAuthenticating = false;

  /// Completes when [isSupported] holds the real value.
  late final Future<void> initialization;

  bool? get canCheckBiometrics => _canCheckBiometrics;
  List<BiometricType>? get availableBiometrics => _availableBiometrics;
  bool get isSupported => _isSupported;
  bool get authorized => _authorized;
  bool get isAuthenticating => _isAuthenticating;

  FingerprintService({LocalAuthentication? localAuthentication})
    : auth = localAuthentication ?? LocalAuthentication() {
    initialization = _init();
  }

  Future<void> _init() async {
    try {
      _isSupported = await auth.isDeviceSupported();
    } catch (e) {
      // MissingPluginException on unsupported platforms / tests.
      _isSupported = false;
      debugPrint('local_auth unavailable: $e');
    }
  }

  Future<void> checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
    } on LocalAuthException catch (e) {
      _canCheckBiometrics = false;
      debugPrint(e.toString());
    } on PlatformException catch (e) {
      _canCheckBiometrics = false;
      debugPrint(e.toString());
    }
  }

  Future<void> getAvailableBiometrics() async {
    try {
      _availableBiometrics = await auth.getAvailableBiometrics();
    } on LocalAuthException catch (e) {
      _availableBiometrics = <BiometricType>[];
      debugPrint(e.toString());
    } on PlatformException catch (e) {
      _availableBiometrics = <BiometricType>[];
      debugPrint(e.toString());
    }
  }

  /// Lets the OS choose the method (biometrics or device PIN/pattern).
  Future<bool> authenticate({required String localizedReason}) =>
      _authenticate(localizedReason: localizedReason, biometricOnly: false);

  /// Biometrics only (no PIN fallback).
  Future<bool> authenticateWithBiometrics({required String localizedReason}) =>
      _authenticate(localizedReason: localizedReason, biometricOnly: true);

  Future<bool> _authenticate({
    required String localizedReason,
    required bool biometricOnly,
  }) async {
    if (!_isSupported || _isAuthenticating) return false;
    _isAuthenticating = true;
    try {
      _authorized = await auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      debugPrint(e.toString());
      _authorized = false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      _authorized = false;
    } finally {
      _isAuthenticating = false;
    }
    return _authorized;
  }

  Future<void> cancelAuthentication() async {
    try {
      await auth.stopAuthentication();
    } finally {
      _isAuthenticating = false;
    }
  }
}
