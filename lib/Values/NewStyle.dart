import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';

class NewStyle {
  static const tx28White = TextStyle(
    fontSize: 28,
    fontFamily: 'VahidRegular',
    color: NewColor.mainWhiteColor,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );
  static const tx14SplashWhite = TextStyle(
    fontSize: 14,
    fontFamily: 'InterRegular',
    color: NewColor.splashContentWhiteColor,
    fontWeight: FontWeight.w400,
    height: 2,
  );
  static const btnTx16SplashBlue = TextStyle(
    fontSize: 16,
    fontFamily: 'VahidRegular',
    color: NewColor.btnTxBlueColor,
    fontWeight: FontWeight.w700,
    height: 1.5,
  );

  static InputDecoration authInputDecoration = InputDecoration(
    hintText: 'Input details',
    hintStyle: TextStyle(
      fontSize: 12, // Font size
      color: NewColor.inputHintColor, // Font color
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 0,
      horizontal: 13.85,
    ),
    filled: true,
    fillColor: NewColor.inputFillColor, // Background color
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: NewColor.borderColor,
        width: 1.38,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: NewColor.borderColor,
        width: 1.38,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: NewColor.borderColor,
        width: 1.38,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
  );

  static InputDecoration dashboardInputDecoration = InputDecoration(
    hintText: 'Input details',
    hintStyle: TextStyle(
      fontSize: 12, // Font size
      fontWeight: FontWeight.w400,
      fontFamily: 'InterRegular',
      color: Color(0xFF6B7280), // Font color
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 5,
      horizontal: 16,
    ),
    filled: true,
    fillColor: NewColor.dashboardPrimaryColor, // Background color
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x99D1D1D1),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x99D1D1D1),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x99D1D1D1),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
  );
  static InputDecoration searchInputDecoration = InputDecoration(
    hintText: 'Search coins',
    hintStyle: TextStyle(
      fontSize: 12, // Font size
      fontWeight: FontWeight.w400,
      fontFamily: 'InterRegular',
      color: Color(0xFF6B7280), // Font color
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 5,
      horizontal: 16,
    ),
    filled: true,
    fillColor: NewColor.dashboardPrimaryColor, // Background color
    border: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x33D1D1D1),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x33D1D1D1),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x33D1D1D1),
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(5),
    ),
  );
}
