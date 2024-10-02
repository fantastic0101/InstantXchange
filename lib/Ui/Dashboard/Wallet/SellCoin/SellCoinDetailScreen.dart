import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/HistoryScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinSendProcessingPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class SellCoinDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> sData;
  final Map<String, dynamic> cData;
  const SellCoinDetailScreen({
    Key? key,
    required this.data,
    required this.sData,
    required this.cData,
  }) : super(key: key);

  @override
  State<SellCoinDetailScreen> createState() => _SellCoinDetailScreenState();
}

class _SellCoinDetailScreenState extends State<SellCoinDetailScreen> {
  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  late Map<String, dynamic> transaction;
  late Map<String, dynamic> sellInfo;
  late Map<String, dynamic> coinInfo;
  TextEditingController amountController = TextEditingController();
  bool isLoading = false;
  String walletAddress = "3SA3222SV2F2352EFASDF213RWEF2323FS";

  final interval = const Duration(seconds: 1);
  late Timer _timer;
  final int timerMaxSeconds = 1200;
  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')} : ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')} Sec';

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  startTimeout([int? milliseconds]) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentSeconds++;
      });
    });
  }

  handleSellPayment() async {
    setState(() {
      isLoading = true;
    });
    final String url = 'https://instantexchangers.com/mobile_server/create-sell-order';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse('https://instantexchangers.com/mobile_server/paid-sell-order'),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'transaction_no': transaction['transaction']
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        if(res['result'] == true) {
          Fluttertoast.showToast(
              msg: "Successfully paid.",
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
              msg: "We can't confirm your payment. Please try again later.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
        setState(() {
          isLoading = false;
        });
        Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return HistoryScreen();
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
    super.initState();
    startTimeout(1000);
    transaction = widget.data;
    sellInfo = widget.sData;
    coinInfo = widget.cData;
    print(coinInfo);
  }

  @override
  Widget build(BuildContext context) {
    // print(networkList[0].toJson());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 70, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: NewColor.dashboardPrimaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                          child: Text("${transaction['transaction']}",
                              style: NewStyle.tx28White.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: NewColor.btnBgGreenColor,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start, // Vertical alignment
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Please transfer the amount shown below and then ",
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      color: NewColor.txGrayColor
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("click the 'I PAID' button to confirm your payment.",
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      color: NewColor.txGrayColor
                                  )),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 12,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          height: 35,
                          width: 35,
                          fit: BoxFit.fill,
                          imageUrl: coinInfo['coin_image'],
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: MyColor.greenColor),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Text("${NumberFormat("#,###.#########").format(sellInfo['coin_amount'])} ${coinInfo['coin_code']}",
                          style: NewStyle.tx28White.copyWith(
                            fontSize: 18,
                        ))
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Network Address",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: amountController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12, height: 2.5),
                onChanged: (value) {
                  setState(() {
                    amountController.text = value.toString();
                  });
                },
                enabled: false,
                decoration: NewStyle.dashboardInputDecoration.copyWith(
                    hintText: " ",
                    suffixIcon: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 12),
                          Text("${coinInfo['coin_code']} ${coinInfo['coin_name']}",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: NewColor.txGrayColor)),
                        ],
                      ),
                    )),
              ),
              const SizedBox(height: 12),
              transaction['admin_wallet'] != "" ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Wallet Address",
                    style: NewStyle.tx28White.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: NewColor.txGrayColor),
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: amountController,
                    cursorColor: NewColor.btnBgGreenColor,
                    style: NewStyle.tx28White.copyWith(fontSize: 12, height: 2.5),
                    onChanged: (value) {
                      setState(() {
                        amountController.text = value.toString();
                      });
                    },
                    decoration: NewStyle.dashboardInputDecoration.copyWith(
                        hintText: " ",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text(transaction['admin_wallet'],
                                    overflow: TextOverflow.ellipsis,
                                    style: NewStyle.tx14SplashWhite.copyWith(
                                        fontSize: 12,
                                        height: 2,
                                        fontWeight: FontWeight.w400,
                                        color: NewColor.txGrayColor))),
                                InkWell(
                                    onTap: () {
                                      FlutterClipboard.copy(transaction['admin_wallet'])
                                          .then((value) {
                                        Helper.dialogCall.showToast(context, "Copied");
                                      });
                                      // Handle button press
                                    },
                                    child: Image.asset(
                                      "assets/images/dashboard/copy.png",
                                      width: 14,
                                      height: 14,
                                      fit: BoxFit.cover,
                                    )),
                              ]),
                        )),
                  ),
                  SizedBox(height: 24),
                  Container(
                      height: 0.5,
                      decoration: BoxDecoration(color: Color(0x33D1D1D1))),
                  SizedBox(height: 24),
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Scan QR Code",
                              style: NewStyle.tx28White.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: NewColor.txGrayColor),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Spacer(),
                            Container(
                              padding: EdgeInsets.all(16.0), // Padding around the QR code
                              decoration: BoxDecoration(
                                color: Colors.white, // Background color of the container
                                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                    offset: Offset(2.0, 2.0), // Shadow position
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: transaction['admin_wallet'], // The data to encode in the QR code
                                version: QrVersions.auto, // Automatically choose the best QR version
                                size: 200.0, // Size of the QR code
                                gapless: false, // Set to false to reduce artifacts
                              ),
                            ),
                            Spacer(),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Address Expires in",
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: NewColor.txGrayColor))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(timerText,
                                  style: NewStyle.tx14SplashWhite.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: NewColor.txGrayColor)),
                            ],
                          )
                        ],
                      )
                  ),
                  SizedBox(height: 24),
                  isLoading == true
                      ? const Center(
                      child: CircularProgressIndicator(
                        color: MyColor.greenColor,
                      ))
                      : SizedBox(
                    // width: double.infinity,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => {
                        handleSellPayment()
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: NewColor.btnBgGreenColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "I Paid",
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.mainWhiteColor),
                      ),
                    ),
                  )
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24,),
                  SizedBox(
                    // width: double.infinity,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => {
                        _launchURL("${Utils.sellUrl}${transaction['transaction']}"),
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                          return HistoryScreen();
                        }))
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: NewColor.btnBgGreenColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Proceed to sell",
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.mainWhiteColor),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
