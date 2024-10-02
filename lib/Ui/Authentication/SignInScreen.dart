import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../LocalDb/Local_Account_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
  String _response = "";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _validateForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });
      // Form is valid, show success message or proceed with the next step
      final Map<String, dynamic> body = {
        "email": _emailController.text,
        "password": _passwordController.text,
      };

      loginAccount();
    } else {
      // Form is invalid, no action needed here since warnings are shown automatically
    }
  }

  loginAccount() async {

    var data = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
          Uri.parse('https://instantexchangers.com/mobile_server/login'), // Get Wallet Information
          body: data
      ).timeout(Duration(seconds: 10));

      print("------------------");

      if (response.statusCode == 200) {
        print(response.body);
        isLoading = false;
        Map<String, dynamic> res = jsonDecode(response.body);
        if(res['result'] == true) {
          Fluttertoast.showToast(
            msg: "User login success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
          );

          await saveToken(res['token']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
          setState(() {
            isLoading = false;
          });
        }
        else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: "Please input valid information",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
          );
        }
      }
      else {
        final redirectedResponse = await http.post(
          Uri.parse(response.headers['location']!),
          body: data,
        ).timeout(Duration(seconds: 10));

        // Check the status of the redirected response
        if (redirectedResponse.statusCode == 200) {
          final responseData = jsonDecode(redirectedResponse.body);
          print('Data after redirect: $responseData');
        } else {
          print('Failed to load data after redirect: ${redirectedResponse.statusCode}');
        }
        setState(() {
          isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "Request timed out. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print(e);
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 81, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
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
                    SizedBox(
                      width: 160,
                      child: Text(
                        'Sign in to your Account',
                        style: NewStyle.tx28White.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Fill all the inputs for login',
                      style: NewStyle.tx14SplashWhite,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Enter Email',
                      style: NewStyle.tx14SplashWhite.copyWith(
                          color: NewColor.txGrayColor,
                          fontWeight: FontWeight.w500,
                          height: 2),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: NewStyle.authInputDecoration,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Enter Password',
                      style: NewStyle.tx14SplashWhite.copyWith(
                          color: NewColor.txGrayColor,
                          fontWeight: FontWeight.w500,
                          height: 2),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: NewStyle.authInputDecoration,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        } else if (value.length < 8) {
                          return 'Please enter at least 8 letters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12,),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          _launchURL(Utils.forgetPassword);
                        },
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 250),
              Column(children: [
                isLoading == true
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: MyColor.greenColor,
                      ))
                    : Container(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => {_validateForm()},
                          style: TextButton.styleFrom(
                            backgroundColor: NewColor.btnBgGreenColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // Padding
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: NewStyle.btnTx16SplashBlue
                                .copyWith(color: NewColor.mainWhiteColor),
                          ),
                        ),
                      ),
                const SizedBox(height: 68),
                Container(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      'Don’t have an account? ',
                      style: NewStyle.btnTx16SplashBlue
                          .copyWith(color: NewColor.txGrayColor),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen())),
                      child: Text(
                        'Sign Up',
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.btnBgGreenColor),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 34),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
