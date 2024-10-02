import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinSendProcessingPage.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SellCoin/SellCoinDetailScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenDetailScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

// ignore: must_be_immutable
class SellCoinConfirmScreen extends StatefulWidget {
  final Map<String, dynamic> bData;
  final Map<String, dynamic> sData;
  final Map<String, dynamic> cData;

  // Constructor with multiple required parameters
  const SellCoinConfirmScreen({
    super.key,
    required this.bData,
    required this.sData,
    required this.cData,
  });

  @override
  State<SellCoinConfirmScreen> createState() => _SellCoinConfirmScreenState();
}

class _SellCoinConfirmScreenState extends State<SellCoinConfirmScreen> {
  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  late Map<String, dynamic> bankData;
  late Map<String, dynamic> sellInfo;
  late Map<String, dynamic> coinInfo;
  String walletAddress = "";
  bool isLoading = false;
  bool apiLoading = false;

  createSellOrder() async {
    setState(() {
      isLoading = true;
    });

    final String url = 'https://instantexchangers.com/mobile_server/create-sell-order';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'coin_id': coinInfo['coin_id'],
          'usd_amount': sellInfo['usd_amount'].toString(),
          'bank_id': bankData['bank_id'],
          'account_number': bankData['account_number'],
          'account_name': bankData['account_name']
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        setState(() {
          walletAddress = res['admin_wallet'];
        });
        setState(() {
          isLoading = false;
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return SellCoinDetailScreen(data: res, sData: sellInfo, cData: coinInfo);
            }));
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    bankData = widget.bData;
    sellInfo = widget.sData;
    coinInfo = widget.cData;
    print(widget.sData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(networkList[0].toJson());
    return Scaffold(
        body: SingleChildScrollView(
            child: Padding(
      padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                SizedBox(width: MediaQuery.of(context).size.width / 2 - 108),
                Text(
                  "Confirmation",
                  style: NewStyle.tx28White.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Container(
              decoration: BoxDecoration(
                color: NewColor.dashboardPrimaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Text("Withdraw ${sellInfo['coin_code']}",
                  style: NewStyle.tx28White.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: NewColor.btnBgGreenColor,
                  )),
            ),
            const SizedBox(height: 8),
            Text("${NumberFormat('#,###.#########').format(sellInfo['coin_amount'])} ${sellInfo['coin_code']}",
                style: NewStyle.tx28White.copyWith(
                  fontSize: 20,
                )),
            Text("=${NumberFormat('#,###.####').format(double.parse(sellInfo['usd_amount']))}",
                style: NewStyle.tx14SplashWhite
                    .copyWith(height: 1.3, color: NewColor.txGrayColor)),
            const SizedBox(height: 48),
            Container(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                [
                  Text("Transaction details",
                    style: NewStyle.tx28White.copyWith(
                      fontSize: 20,
                    ))
                ]
              ),
            ),
            const SizedBox(height: 12),
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: NewColor.dashboardPrimaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Network",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.txGrayColor,
                                fontWeight: FontWeight.w500)),
                        Text("${coinInfo['coin_name']} ${coinInfo['coin_code']}",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.txGrayColor,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total amount",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.txGrayColor,
                                fontWeight: FontWeight.w500)),
                        Text("${NumberFormat('#,###.##').format(sellInfo['ngn_amount'])} NGN",
                            style: NewStyle.tx14SplashWhite.copyWith(
                              fontSize: 12,
                              color: NewColor.txGrayColor,
                            )),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: 30),
            Container(
              child: Row(
                children: [
                  SizedBox(
                    width: 160,
                    child: TextButton(
                      onPressed: () => (Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return DashboardScreen();
                          }))),
                      style: TextButton.styleFrom(
                        backgroundColor: MyColor.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: MyColor.darkGreyColor, // Set your desired border color here
                            width: 2.0, // Set the border width
                          ),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.mainWhiteColor),
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 160,
                    child: TextButton(
                      onPressed: () => {
                        createSellOrder()
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: NewColor.btnBgGreenColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Proceed",
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.mainWhiteColor),
                      ),
                    ),
                  )
                ],
              ),
            )
          ]),
    )));
  }
}
