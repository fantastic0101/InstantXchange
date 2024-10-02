import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetProvider with ChangeNotifier{

  bool isOnline = true;

  checkInternet() async {

    Connectivity().onConnectivityChanged.listen((event) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if(event == ConnectivityResult.none){
            isOnline = false;
            notifyListeners();
          }
          else{
            isOnline = true;
            notifyListeners();
          }
        }
      } on SocketException catch (_) {
        isOnline = true;
        notifyListeners();
      }

    });
  }
}