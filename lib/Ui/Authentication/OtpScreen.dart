import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Ui/Authentication/PinScreen.dart';
import 'package:jost_pay_wallet/Ui/Authentication/SignInScreen.dart';
import 'package:jost_pay_wallet/Ui/Authentication/SignUpScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/LoginWithPasscode.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import '../../Values/MyColor.dart';
import '../Authentication/LoginScreen.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const OtpScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late Map<String, dynamic> receivedData;
  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late SharedPreferences sharedPreferences;
  late String emailCode;

  bool isLoading = false;
  bool clearText = false;

  onResendCode() async {
    setState(() {
      clearText = true;
      isLoading = true;
    });
    await Future.delayed(Duration(seconds: 2));
    final String url = 'https://instantexchangers.com/mobile_server/get-email-code';

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        body: {
          'email': receivedData['email']
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        if(res['result'] == true) {
          Fluttertoast.showToast(
              msg: "Successfully resend code.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: MyColor.darkGrey01Color,
              textColor: MyColor.whiteColor,
              fontSize: 15.0
          );
        }
        else {
          Fluttertoast.showToast(
              msg: "Something went wrong. Please contact with supprot team.",
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
            body: {
              'email': receivedData['email']
            },
          );

          Map<String, dynamic> res = jsonDecode(redirectedResponse.body);
          if(res['result'] == true) {
            Fluttertoast.showToast(
                msg: "Successfully resend code.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: MyColor.darkGrey01Color,
                textColor: MyColor.whiteColor,
                fontSize: 15.0
            );
          }
          else {
            Fluttertoast.showToast(
                msg: "Something went wrong. Please contact with supprot team.",
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
          Fluttertoast.showToast(
              msg: "Something went wrong. Please contact with supprot team.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: MyColor.darkGrey01Color,
              textColor: MyColor.whiteColor,
              fontSize: 15.0
          );
        }
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      clearText = false;
      isLoading = false;
    });
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  loginAccount() async {
    setState(() {
      isLoading = true;
    });

    final String url = 'https://instantexchangers.com/mobile_server/signup'; // User Register API
    Map<String, dynamic> requestData = receivedData;
    requestData['email_code'] = emailCode;

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        body: requestData,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        if(res['result'] == true) {
          response = await http.post(
            Uri.parse('https://instantexchangers.com/mobile_server/login'),
            body: {
              'email': receivedData['email'],
              'password': receivedData['password']
            },
          );

          Fluttertoast.showToast(
              msg: "Successfully registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );

          if (response.statusCode == 200) {
            res = jsonDecode(response.body);
            setState(() {
              isLoading = false;
            });
            await saveToken(res['token']);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()));
          }
        }
        else {
          if(response.statusCode == 301) {
            final redirectedResponse = await http.post(
              Uri.parse(response.headers['location']!),
              body: {
                'email': receivedData['email'],
                'password': receivedData['password']
              },
            );

            Fluttertoast.showToast(
                msg: "Successfully registered",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );

            if (redirectedResponse.statusCode == 200) {
              res = jsonDecode(redirectedResponse.body);
              setState(() {
                isLoading = false;
              });
              await saveToken(res['token']);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()));
            }
          }
          else {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: "Email confirm failed.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        }
      } else {
        if(response.statusCode == 301) {
          final redirectedResponse = await http.post(
            Uri.parse(response.headers['location']!),
            body: requestData,
          );


          Map<String, dynamic> res = jsonDecode(redirectedResponse.body);
          if(res['result'] == true) {
            response = await http.post(
              Uri.parse('https://instantexchangers.com/mobile_server/login'),
              body: {
                'email': receivedData['email'],
                'password': receivedData['password']
              },
            );

            Fluttertoast.showToast(
                msg: "Successfully registered",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );

            if (response.statusCode == 200) {
              res = jsonDecode(response.body);
              setState(() {
                isLoading = false;
              });
              await saveToken(res['token']);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardScreen()));
            }
            else if(response.statusCode == 301) {
              final redirectedResponse = await http.post(
                Uri.parse(response.headers['location']!),
                body: {
                  'email': receivedData['email'],
                  'password': receivedData['password']
                },
              );

              if (redirectedResponse.statusCode == 200) {
                res = jsonDecode(redirectedResponse.body);
                setState(() {
                  isLoading = false;
                });
                await saveToken(res['token']);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()));
              }
            }
          }
          else {
            if(response.statusCode == 301) {
              final redirectedResponse = await http.post(
                Uri.parse(response.headers['location']!),
                body: {
                  'email': receivedData['email'],
                  'password': receivedData['password']
                },
              );

              Fluttertoast.showToast(
                  msg: "Successfully registered",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0
              );

              if (redirectedResponse.statusCode == 200) {
                res = jsonDecode(redirectedResponse.body);
                setState(() {
                  isLoading = false;
                });
                await saveToken(res['token']);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()));
              }
            }
            else {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: "Email confirm failed.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            }
          }
        }
        else {
          setState(() {
            isLoading = true;
          });
          Fluttertoast.showToast(
              msg: "Email confirm failed.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = true;
      });
      Fluttertoast.showToast(
          msg: "Email confirm failed.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      print(e);
    }
  }

  @override
  void initState() {
    receivedData = widget.data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 103, right: 24, left: 24),
          child: Column(
            children: <Widget>[
              Image.asset(
                "assets/images/otp.png",
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8.5),
              Text(
                'Authentication!!',
                style: NewStyle.tx28White.copyWith(fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(21.0),
                child: Text(
                  'Enter  OTP that was sent to \n${receivedData['email']}, to verify it’s you',
                  style: NewStyle.tx14SplashWhite
                      .copyWith(fontSize: 14, height: 2),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 33),
              OtpTextField(
                numberOfFields: 6,
                borderColor: NewColor.borderColor,
                fillColor: NewColor.inputFillColor,
                fieldWidth: 50,
                fieldHeight: 50,
                focusedBorderColor: NewColor.btnBgGreenColor,
                textStyle: TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: NewColor.btnBgGreenColor),
                filled: true,
                borderWidth: 0.68,
                borderRadius: BorderRadius.all(Radius.circular(7.71)),
                showFieldAsBox: true,
                clearText: clearText,
                autoFocus: true,
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode) {
                  emailCode = verificationCode;
                },
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => {onResendCode()},
                child: Text("Resend Code",
                    style: NewStyle.tx28White.copyWith(fontSize: 18)),
              ),
              const SizedBox(height: 59),
              isLoading == true
                  ? const Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  ))
                  : Container(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => {
                    loginAccount()
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: NewColor.btnBgGreenColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: Text(
                    "Confirm",
                    style: NewStyle.btnTx16SplashBlue
                        .copyWith(color: NewColor.mainWhiteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
