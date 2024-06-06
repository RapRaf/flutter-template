import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintService {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isSupported = false;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  bool _authorized = false;
  bool _isAuthenticating = false;
  late final Future<void> initialization;

  bool? get canCheckBiometrics => _canCheckBiometrics;
  List<BiometricType>? get availableBiometrics => _availableBiometrics;
  bool get isSupported => _isSupported;
  bool get authorized => _authorized;
  bool get isAuthenticating => _isAuthenticating;

  FingerprintService() {
    auth.isDeviceSupported().then(
          (bool isSupported) => _isSupported = isSupported,
        );
  }

  Future<void> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      debugPrint(e.toString());
    }

    _canCheckBiometrics = canCheckBiometrics;
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      debugPrint(e.toString());
    }

    _availableBiometrics = availableBiometrics;
  }

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      _isAuthenticating = true;
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      _isAuthenticating = false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      _isAuthenticating = false;
      _authorized = false;
      return _authorized;
    }
    _authorized = authenticated;

    return _authorized;
  }

  Future<bool> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      _isAuthenticating = true;

      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      _isAuthenticating = false;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      _isAuthenticating = false;
      _authorized = false;
      return _authorized;
    }

    _authorized = authenticated;
    return _authorized;
  }

  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    _isAuthenticating = false;
  }
}
