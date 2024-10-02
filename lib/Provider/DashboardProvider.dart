import 'package:flutter/cupertino.dart';

class DashboardProvider with ChangeNotifier{
  int currentIndex = 0;
  changeBottomIndex(int newIndex){
    currentIndex = newIndex;
    notifyListeners();
  }

  bool showPassword = true;
  changeBuyShowPassword(bool newValue){
    showPassword = newValue;
    notifyListeners();
  }

  String defaultCoin = "";
  changeDefaultCoin(String newValue){
    defaultCoin = newValue;
    notifyListeners();
  }

}