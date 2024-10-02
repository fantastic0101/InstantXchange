import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WalletConnect/WalletConnectScreen.dart';
import 'WalletsPages/WalletsListingScreen.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ProfileScreen({
    Key? key,
    required this.data,
  }): super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedAccountName = "";
  late Map<String, dynamic> profile = {};

  getWalletName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }

  @override
  void initState() {
    getWalletName();
    profile = widget.data;
    super.initState();
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
                SizedBox(width: MediaQuery.of(context).size.width / 2 - 71),
                Text(
                  "Profile",
                  style: NewStyle.tx28White.copyWith(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 55),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),  // Adjust the radius to make it fully circular
                        child: Image.asset(
                          "assets/images/avatar1.png",
                          fit: BoxFit.cover,
                          width: 50.0,
                          height: 50.0,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${profile['full_name']}",
                            style: NewStyle.tx28White.copyWith(fontSize: 18),
                          ),
                          Text(
                            "${profile['email']}",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 14, color: NewColor.txGrayColor),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 19),
                  Container(
                      height: 0.5,
                      decoration: BoxDecoration(color: Color(0x33D1D1D1))),
                  SizedBox(height: 36),
                  Container(
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.fromLTRB(9, 7, 9, 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: NewColor.dashboardPrimaryColor),
                              child: Text("***",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      color: NewColor.mainWhiteColor))),
                          SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mobile Number",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: NewColor.splashContentWhiteColor,
                                      height: 1.15)),
                              SizedBox(height: 5),
                              Text("${profile['phone_number']}",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      color: NewColor.txGrayColor,
                                      height: 1.15)),
                            ],
                          ),
                          Spacer()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36),
                  Container(
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: NewColor.dashboardPrimaryColor),
                              child: Image.asset(
                                "assets/images/country.png",
                                fit: BoxFit.cover,
                              )),
                          SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Country",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: NewColor.splashContentWhiteColor,
                                      height: 1.15)),
                              SizedBox(height: 5),
                              Text("${Utils.countryInfo[profile['country']]}",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      color: NewColor.txGrayColor,
                                      height: 1.15)),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36),
                  Container(
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: NewColor.dashboardPrimaryColor),
                              child: Image.asset(
                                "assets/images/language.png",
                                fit: BoxFit.cover,
                              )),
                          SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Language",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: NewColor.splashContentWhiteColor,
                                      height: 1.15)),
                              SizedBox(height: 5),
                              Text("English",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      color: NewColor.txGrayColor,
                                      height: 1.15)),
                            ],
                          ),
                          Spacer(),
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
