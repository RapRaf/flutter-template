import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int currentPage;

  AppProvider({this.currentPage = 0});

  void changeCurrentPageState({
    required int newCurrentPageState,
  }) async {
    currentPage = newCurrentPageState;
    notifyListeners();
  }

  void initProvider() {
    currentPage = 0;
  }
}
