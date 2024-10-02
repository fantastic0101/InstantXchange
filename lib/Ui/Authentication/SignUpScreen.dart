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
import 'package:jost_pay_wallet/Ui/Authentication/LoginWithPasscode.dart';
import 'package:jost_pay_wallet/Ui/Authentication/OtpScreen.dart';
import 'package:jost_pay_wallet/Ui/Authentication/SignInScreen.dart';
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
import 'package:csc_picker/csc_picker.dart';
import '../../LocalDb/Local_Account_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController passwordController = TextEditingController();

  String countryValue = "";

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
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _response = '';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  void _validateForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      userRegister();
    } else {
    }
  }

  userRegister() async {
    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {

      final String url = 'https://instantexchangers.com/mobile_server/get-email-code';
      final Map<String, dynamic> body = {
        'email': _emailController.text
      };

      try {
        http.Response response = await http.post(
          Uri.parse(url),
          body: body,
        ).timeout(Duration(seconds: 10));

        if (response.statusCode == 200) {
          Map<String, dynamic> res = jsonDecode(response.body);
          if(res['result'] == true) {
            saveToken(res['token']);
            loginAccount();
          }
          else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: "Your email address is not valid. Please try with another one.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: MyColor.darkGrey01Color,
                textColor: MyColor.whiteColor,
                fontSize: 15.0
            );
          }
        } else {
          if(response.statusCode == 301) {
            final redirectedResponse = await http.post(
              Uri.parse(response.headers['location']!),
              body: body,
            ).timeout(Duration(seconds: 10));
            if (redirectedResponse.statusCode == 200) {
              final responseData = jsonDecode(redirectedResponse.body);

              Map<String, dynamic> res = jsonDecode(redirectedResponse.body);
              if(res['result'] == true) {
                saveToken(res['token']);
                loginAccount();
              }
              else {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                    msg: "Your email address is not valid. Please try with another one.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: MyColor.darkGrey01Color,
                    textColor: MyColor.whiteColor,
                    fontSize: 15.0
                );
              }
            } else {
              setState(() {
                isLoading = false;
              });

              Fluttertoast.showToast(
                  msg: "Your email address is not valid. Please try with another one.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: MyColor.darkGrey01Color,
                  textColor: MyColor.whiteColor,
                  fontSize: 15.0
              );
            }
          }
          else {
            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(
                msg: "Your email address is not valid. Please try with another one.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: MyColor.darkGrey01Color,
                textColor: MyColor.whiteColor,
                fontSize: 15.0
            );
          }
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
      }
    }
    else {}
  }

  String? getCountryCode(String countryName) {
    return Utils.countryInfo.entries
        .firstWhere(
            (entry) => entry.value.toLowerCase() == countryName.toLowerCase(),
        orElse: () => MapEntry('', ''))
        .key;
  }

  loginAccount() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    var data = {
      "email": _emailController.text,
      "password": _passwordController.text,
      "full_name": _fullNameController.text,
      "phone": _phoneNumberController.text,
      "country": getCountryCode(countryValue.substring(8, countryValue.length))!,
      "token": token
    };

    try {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpScreen(data: data)),
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 81, left: 24, right: 24),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Container(
                      width: 200,
                      child: Text(
                        'Create your wallet Account',
                        style: NewStyle.tx28White.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Fill all the inputs for registration',
                      style: NewStyle.tx14SplashWhite,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Enter Full Name',
                      style: NewStyle.tx14SplashWhite.copyWith(
                          color: NewColor.txGrayColor,
                          fontWeight: FontWeight.w500,
                          height: 2),
                    ),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: NewStyle.authInputDecoration,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the valid name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
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
                      'Enter Phone Number',
                      style: NewStyle.tx14SplashWhite.copyWith(
                          color: NewColor.txGrayColor,
                          fontWeight: FontWeight.w500,
                          height: 2),
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: NewStyle.authInputDecoration.copyWith(
                        hintText: "+234"
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        } else if (!RegExp(r'^\+(?:[0-9] ?){6,14}[0-9]$')
                            .hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Create Password',
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
                    const SizedBox(height: 14),
                    Text(
                      'Select Country',
                      style: NewStyle.tx14SplashWhite.copyWith(
                          color: NewColor.txGrayColor,
                          fontWeight: FontWeight.w500,
                          height: 2),
                    ),
                    CSCPicker(
                      flagState: CountryFlag.ENABLE,
                      disabledDropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: NewColor.inputFillColor,
                        border: Border.all(
                          color: NewColor.borderColor,
                          width: 1.38,
                        ),
                      ),
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: NewColor.inputFillColor,
                        border: Border.all(
                          color: NewColor.borderColor,
                          width: 1.38,
                        ),
                      ),
                      dropdownHeadingStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      showCities: false,
                      showStates: false,
                      searchBarRadius: 50,
                      defaultCountry: CscCountry.Nigeria,
                      countryDropdownLabel: countryValue,
                      onCountryChanged: (value) {
                        setState(() {
                          countryValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 61),
              Column(children: [
                isLoading == true
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: MyColor.greenColor,
                      ))
                    : Container(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => {
                            _validateForm()
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: NewColor.btnBgGreenColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Sign Up",
                            style: NewStyle.btnTx16SplashBlue
                                .copyWith(color: NewColor.mainWhiteColor),
                          ),
                        ),
                      ),
                const SizedBox(height: 117),
                Container(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      'Already have an account? ',
                      style: NewStyle.btnTx16SplashBlue
                          .copyWith(color: NewColor.txGrayColor),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen())),
                      child: Text(
                        'Sign In',
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
