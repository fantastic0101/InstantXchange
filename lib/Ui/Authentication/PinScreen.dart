import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Ex_Transaction_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Walletv2_provider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/SignUpScreen.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:local_auth_ios/types/auth_messages_ios.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:custom_pin_screen/custom_pin_screen.dart';
import '../../LocalDb/Local_Account_provider.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  TextEditingController passwordController = TextEditingController();

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late DashboardProvider dashProvider;

  final LocalAuthentication auth = LocalAuthentication();
  late String deviceId;
  bool fingerOn = false;
  String isLogin = "";

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, show success message or proceed with the next step
      loginAccount();
    } else {
      // Form is invalid, no action needed here since warnings are shown automatically
    }
  }

  savePinCode(String verificationCode) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const DashboardScreen()));
  }

  loginAccount() async {
    setState(() {
      isLoading = true;
    });

    var data = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    try {
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
      if (accountProvider.isSuccess == true) {
        isLoading = false;
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    dashProvider = Provider.of<DashboardProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    dashProvider = Provider.of<DashboardProvider>(context, listen: true);
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 81, left: 24, right: 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          "assets/images/arrow_left.png",
                          fit: BoxFit.cover,
                        )),
                    const SizedBox(height: 28),
                    Container(
                      width: 160,
                      child: Text(
                        'Set your PIN code',
                        style: NewStyle.tx28White.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'We use state of -the-art security measures to protect your informatonat all times',
                      style: NewStyle.tx14SplashWhite.copyWith(height: 1.7),
                    ),
                    const SizedBox(height: 20),
                    OtpTextField(
                      obscureText: true,
                      numberOfFields: 4,
                      showFieldAsBox: false,
                      borderColor: NewColor.mainWhiteColor,
                      fieldWidth: 62,
                      fieldHeight: 90,
                      focusedBorderColor: NewColor.mainWhiteColor,
                      margin: EdgeInsets.only(left: 13, right: 13),
                      textStyle: TextStyle(
                          fontSize: 27,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: NewColor.mainWhiteColor),
                      borderWidth: 1,
                      autoFocus: true,
                      onCodeChanged: (String code) {
                      },
                      onSubmit: (String verificationCode) {
                        savePinCode(verificationCode);
                      },
                    ),
                  ])),
        ],
      ),
    );
  }
}
