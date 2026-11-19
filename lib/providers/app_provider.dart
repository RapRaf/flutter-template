import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';

/// State of the logged-in part of the app.
///
/// It is reset every time the user leaves [LoginState.loggedIn] (see
/// [update]): put here the data that belongs to the user session and clear it
/// in [_reset].
class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  AuthProvider _authProvider;
  int _currentPage = 0;
  bool _disposed = false;

  AppProvider({required AuthProvider authProvider})
    : _authProvider = authProvider {
    WidgetsBinding.instance.addObserver(this);
  }

  AuthProvider get authProvider => _authProvider;

  /// Selected tab of `MainActivity`.
  int get currentPage => _currentPage;

  void changeCurrentPageState({required int newCurrentPageState}) {
    if (_currentPage == newCurrentPageState) return;
    _currentPage = newCurrentPageState;
    _notify();
  }

  /// Called by the `ChangeNotifierProxyProvider` whenever [AuthProvider]
  /// changes. It runs during a build, so it must not notify.
  AppProvider update(AuthProvider auth) {
    _authProvider = auth;
    if (auth.loginState != LoginState.loggedIn) _reset();
    return this;
  }

  /// Clears the session data (without notifying).
  void _reset() {
    _currentPage = 0;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_disposed) return;
    if (state == AppLifecycleState.resumed) {
      // e.g. refresh data
    } else if (state == AppLifecycleState.paused) {
      // e.g. save drafts
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
