import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Ui/Authentication/SignInScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/BankScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/ProfileScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SecurityScreen.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'WalletConnect/WalletConnectScreen.dart';
import 'WalletsPages/WalletsListingScreen.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String selectedAccountName = "";
  late Map<String, dynamic> profile = {};

  getProfileInfo() async {
    final String url = 'https://instantexchangers.com/mobile_server/get-user-profile';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${token}',
          }
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

  getWalletName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Delete Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NewColor.txGrayColor)),
                  SizedBox(height: 16.0),
                  Text('Your request to delete your account will be sent to the admin team, and your account information will be removed within 24 hours. Please confirm if you’d like to proceed.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NewColor.txGrayColor)),
                  SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: Text('Confirm'),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('token');

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SignInScreen()),
                            (Route<dynamic> route) => false, // This removes all routes
                          );
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
              )
          ),
        );
      },
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 68),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Settings",
                style: NewStyle.tx28White.copyWith(fontSize: 20),
              ),
            ),
            SizedBox(height: 19),
            Container(
                height: 0.5,
                decoration: BoxDecoration(color: Color(0x33D1D1D1))),
            SizedBox(height: 22),
            Container(
              padding: EdgeInsets.only(right: 24, left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Account",
                    style: NewStyle.tx28White.copyWith(fontSize: 18),
                  ),
                  SizedBox(height: 21),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(data: profile),
                            ));
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NewColor.dashboardPrimaryColor),
                            child: Image.asset(
                              "assets/images/profile.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("Profile",
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
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecurityScreen(),
                            ));
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
                          Text("Security",
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
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () {
                        _launchURL(Utils.termsUrl);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NewColor.dashboardPrimaryColor),
                            child: Image.asset(
                              "assets/images/terms.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("Terms",
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
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () {
                        _launchURL(Utils.privacyUrl);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NewColor.dashboardPrimaryColor),
                            child: Image.asset(
                              "assets/images/privacy.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("Privacy",
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
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BankScreen(),
                            ));
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NewColor.dashboardPrimaryColor),
                            child: Image.asset(
                              "assets/images/bank.png",
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("Banks",
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
                  SizedBox(height: 25),
                  Container(
                      height: 0.5,
                      decoration: BoxDecoration(color: Color(0x33D1D1D1))),
                  SizedBox(height: 18),
                  Text(
                    "Other",
                    style: NewStyle.tx28White.copyWith(fontSize: 18),
                  ),
                  SizedBox(height: 13),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () {
                        _launchURL(Utils.termsUrl);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NewColor.dashboardPrimaryColor),
                            child: Image.asset(
                              "assets/images/policy.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("AML Security Policy",
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
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: InkWell(
                      onTap: () async {
                        _showLogoutDialog(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: NewColor.dashboardPrimaryColor),
                            child: Image.asset(
                              "assets/images/delete.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("Delete account",
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
          ],
        ),
      ),
    );
  }
}
