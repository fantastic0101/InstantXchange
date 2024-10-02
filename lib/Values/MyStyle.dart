import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';

class MyStyle {
  static const tx28BYellow = TextStyle(
    fontSize: 28,
    fontFamily: 'NimbusSanLBol',
    color: MyColor.yellowColor,
  );

  static const tx28RGreen = TextStyle(
    fontSize: 28,
    fontFamily: 'NimbusSanLRegular',
    color: MyColor.greenColor,
  );

  static const tx22RWhite = TextStyle(
    fontSize: 22,
    fontFamily: 'NimbusSanLRegular',
    color: MyColor.whiteColor,
  );

  static const tx18RWhite = TextStyle(
    fontSize: 18,
    fontFamily: 'NimbusSanLRegular',
    color: MyColor.mainWhiteColor,
  );

  static const tx18BWhite = TextStyle(
    fontSize: 18,
    fontFamily: 'NimbusSanLBol',
    color: MyColor.mainWhiteColor,
  );

  static BoxDecoration buttonDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: MyColor.greenColor,
  );

  static BoxDecoration invalidDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: MyColor.boarderColor,
  );

  static InputDecoration textInputDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: MyColor.backgroundColor,
      border: InputBorder.none,
      errorStyle:
          MyStyle.tx18RWhite.copyWith(fontSize: 12, color: MyColor.redColor),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: MyColor.redColor, width: 0.8)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: MyColor.redColor, width: 0.8)),
      hintStyle: MyStyle.tx22RWhite
          .copyWith(fontSize: 18, color: MyColor.whiteColor.withOpacity(0.7)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              const BorderSide(color: MyColor.boarderColor, width: 0.8)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              const BorderSide(color: MyColor.boarderColor, width: 0.8)));

  static InputDecoration textInputDecoration2 = InputDecoration(
      isDense: true,
      border: InputBorder.none,
      errorStyle:
          MyStyle.tx18RWhite.copyWith(fontSize: 12, color: MyColor.redColor),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: MyColor.redColor, width: 0.8)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: MyColor.redColor, width: 0.8)),
      hintStyle: MyStyle.tx22RWhite
          .copyWith(fontSize: 18, color: MyColor.whiteColor.withOpacity(0.7)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide:
              const BorderSide(color: MyColor.boarderColor, width: 0.8)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide:
              const BorderSide(color: MyColor.boarderColor, width: 0.8)));
}
