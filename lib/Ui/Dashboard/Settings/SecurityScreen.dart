import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'WalletConnect/WalletConnectScreen.dart';
import 'WalletsPages/WalletsListingScreen.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String selectedAccountName = "";
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _oldPINController = TextEditingController();
  final _newPINController = TextEditingController();
  final _confirmPINController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> profile = {};

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  getWalletName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }

  getProfileInfo() async {
    final String url = 'https://instantexchangers.com/mobile_server/get-user-profile';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'type': 'buy'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        if(mounted) {
          setState(() {
            profile = res['user'];
          });
        }
      } else {
      }
    } catch (e) {
      print(e);
    }
  }

  changePassword() async {
    final String url = 'https://instantexchangers.com/mobile_server/change-password';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'current_password': _oldPasswordController.text,
          'new_password': _newPasswordController.text,
          'confirm_password': _confirmPasswordController.text
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        if(res['result'] == true) {
          Fluttertoast.showToast(
              msg: "Password changed successfully.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
        else {
          Fluttertoast.showToast(
              msg: "Please input all information correctly.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
        Navigator.of(context).pop();
      } else {
        if(response.statusCode == 301) {
          final redirectedResponse = await http.post(
            Uri.parse(response.headers['location']!),
            headers: {
              'Authorization': 'Bearer ${token}',
            },
            body: {
              'current_password': _oldPasswordController.text,
              'new_password': _newPasswordController.text,
              'confirm_password': _confirmPasswordController.text
            },
          );

          Fluttertoast.showToast(
              msg: "Password changed successfully.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pop();
        }
        else
          Navigator.of(context).pop();
      }
    } catch (e) {
      Navigator.of(context).pop();
      print(e);
    }
  }

  void _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      changePassword();
    } else {
    }
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: MyColor.backgroundColor,
              border: Border.all(
                color: MyColor.darkGreyColor,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(6.0)
            ),
            padding: EdgeInsets.all(16.0),
            child: Form(key: _formKey, child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Password Change', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NewColor.txGrayColor)),
                SizedBox(height: 16.0),
                Text('You can change the password here.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NewColor.txGrayColor)),
                SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current Password',
                    style: NewStyle.tx14SplashWhite.copyWith(
                        color: NewColor.txGrayColor,
                        fontWeight: FontWeight.w500,
                        height: 2),
                  ),
                ),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: MyStyle.textInputDecoration.copyWith(),
                  style: TextStyle(
                      color: NewColor.txGrayColor
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else if (value.length < 6) {
                      return 'Please enter at least 6 letters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'New Password',
                    style: NewStyle.tx14SplashWhite.copyWith(
                        color: NewColor.txGrayColor,
                        fontWeight: FontWeight.w500,
                        height: 2),
                  ),
                ),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: MyStyle.textInputDecoration.copyWith(),
                  style: TextStyle(
                      color: NewColor.txGrayColor
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else if (value.length < 6) {
                      return 'Please enter at least 6 letters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm Password',
                    style: NewStyle.tx14SplashWhite.copyWith(
                        color: NewColor.txGrayColor,
                        fontWeight: FontWeight.w500,
                        height: 2),
                  ),
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: MyStyle.textInputDecoration.copyWith(),
                  style: TextStyle(
                      color: NewColor.txGrayColor
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else if (value.length < 6) {
                      return 'Please enter at least 6 letters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: Text('Change'),
                      onPressed: () {
                        _validateForm();
                      },
                    ),
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),)
          ),
        );
      },
    );
  }

  Future<void> _showVerifyDialog(BuildContext context) async {
    if(profile['verified'] == '0'){
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                decoration: BoxDecoration(
                    color: MyColor.backgroundColor,
                    border: Border.all(
                      color: MyColor.darkGreyColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(6.0)
                ),
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Verification Notice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NewColor.mainWhiteColor)),
                    SizedBox(height: 12.0),
                    Text('To access the buying feature, you need to complete the verification process.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewColor.txGrayColor)),
                    SizedBox(height: 16.0),
                    Image.asset(
                      "assets/images/verify.png",
                      height: 120,
                      width: 120,
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Verify Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColor.blueColor)),
                    ),
                    SizedBox(height: 12.0),
                    Text('Tap "Verify Account" to go to the website. Log in, complete verification, and chat with support to speed up approval. Once approved, return to the app and tap "Update Verification" to refresh your status.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewColor.mainWhiteColor)),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColor.greenColor)),
                    ),
                    SizedBox(height: 12.0),
                    Text("Once you've finished verification, tap the button below to update your status and gain access to buy feature.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewColor.mainWhiteColor)),
                    SizedBox(height: 24.0),
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: TextButton(
                              onPressed: () => {
                                _launchURL(Utils.verifyUrl)
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: MyColor.blueColor,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              child: Text(
                                "Verify Account",
                                style: NewStyle.btnTx16SplashBlue
                                    .copyWith(fontSize: 14, color: NewColor.mainWhiteColor),
                              ),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 130,
                            child: TextButton(
                              onPressed: () => {
                                getProfileInfo(),
                                Navigator.of(context).pop(),
                                if(profile['verified'] == 1)
                                  Fluttertoast.showToast(
                                    msg: "Your account is verified",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                  )
                                else
                                  Fluttertoast.showToast(
                                      msg: "Your account is not verified",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black54,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  )
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: MyColor.greenColor,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              child: Text(
                                "Update Status",
                                style: NewStyle.btnTx16SplashBlue
                                    .copyWith(fontSize: 14, color: NewColor.mainWhiteColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
            ),
          );
        },
      );
    }
    else if(profile['verified'] == '1') {
      Fluttertoast.showToast(
          msg: "Your account is already verified.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {}
  }

  @override
  void initState() {
    super.initState();
    getWalletName();
    getProfileInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 68),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/images/arrow_left.png",
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    )),
                SizedBox(width: MediaQuery.of(context).size.width / 2 - 85),
                Text(
                  "Security",
                  style: NewStyle.tx28White.copyWith(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 23),
            Text(
                "See information about your account security. We prioritize your security and have implemented several robust measures to protect your account and personal data.",
                textAlign: TextAlign.center,
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontSize: 10, height: 1.6, color: NewColor.txGrayColor)),
            SizedBox(height: 28),
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: InkWell(
                onTap: () {
                  _showVerifyDialog(context);
                },
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: NewColor.dashboardPrimaryColor),
                      child: Image.asset(
                        "assets/images/security.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text("Verification Status ",
                        style: NewStyle.tx14SplashWhite.copyWith(
                          fontWeight: FontWeight.w500,
                          color: NewColor.txGrayColor,
                        )),
                    profile['verified'] == "1" ? Text(
                      "Verified",
                        style: NewStyle.tx14SplashWhite.copyWith(
                          fontWeight: FontWeight.w500,
                          color: MyColor.greenColor,
                        )) :
                    Text(
                        "Not Verified",
                        style: NewStyle.tx14SplashWhite.copyWith(
                          fontWeight: FontWeight.w500,
                          color: MyColor.redColor,
                        )
                    ),
                    Spacer(),
                    Image.asset(
                      "assets/images/right.png",
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: InkWell(
                onTap: () {
                  _showPasswordDialog(context);
                },
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: NewColor.dashboardPrimaryColor),
                      child: Image.asset(
                        "assets/images/password.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text("Change Password",
                        style: NewStyle.tx14SplashWhite.copyWith(
                          fontWeight: FontWeight.w500,
                          color: NewColor.txGrayColor,
                        )),
                    Spacer(),
                    Image.asset(
                      "assets/images/right.png",
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
