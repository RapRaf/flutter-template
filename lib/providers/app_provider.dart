import 'package:flutter/material.dart';
import 'package:flutter_template/providers/auth_provider.dart';

class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  int currentPage = 0;
  AuthProvider authProvider;
  bool _disposed = false;

  AppProvider({required this.authProvider}) {
    WidgetsBinding.instance.addObserver(this);
  }

  void mNotifyListener() {
    notifyListeners();
  }

  void changeCurrentPageState({
    required int newCurrentPageState,
  }) async {
    currentPage = newCurrentPageState;
    notifyListeners();
  }

  void initProvider() {
    currentPage = 0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_disposed) return;
    if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.paused) {}
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
