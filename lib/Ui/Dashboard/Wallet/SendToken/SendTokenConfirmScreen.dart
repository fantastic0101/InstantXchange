import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinSendProcessingPage.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenDetailScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'QrScannerPage.dart';

// ignore: must_be_immutable
class SendTokenConfirmScreen extends StatefulWidget {
  final String address, network, fee, amount;
  SendTokenConfirmScreen({
    required this.address,
    required this.network,
    required this.fee,
    required this.amount,
    super.key,
  });

  @override
  State<SendTokenConfirmScreen> createState() => _SendTokenConfirmScreenState();
}

class _SendTokenConfirmScreenState extends State<SendTokenConfirmScreen> {
  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  bool isLoading = false;

  @override
  void initState() {
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
                        // Handle button press
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
              const SizedBox(height: 33),
              Container(
                padding: EdgeInsets.fromLTRB(32, 8, 32, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: NewColor.dashboardPrimaryColor,
                ),
                child: Text("Withdraw USDT",
                    style: NewStyle.tx28White.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: NewColor.btnBgGreenColor)),
              ),
              const SizedBox(height: 13),
              Text("5.00 USDT",
                  style: NewStyle.tx28White.copyWith(
                    fontSize: 20,
                  )),
              const SizedBox(height: 3),
              Text("=250.00",
                  style: NewStyle.tx14SplashWhite
                      .copyWith(height: 1.3, color: NewColor.txGrayColor)),
              const SizedBox(height: 49),
              Container(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Transaction details",
                          style: NewStyle.tx28White.copyWith(
                            fontSize: 18,
                          )),
                      const SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                              color: NewColor.dashboardPrimaryColor,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 0.5, color: Color(0x33D1D1D1))),
                          padding: EdgeInsets.fromLTRB(8, 18, 8, 18),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Address",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                          fontSize: 12,
                                          color: NewColor.txGrayColor,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    width: 191,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        widget.address,
                                        style:
                                            NewStyle.tx14SplashWhite.copyWith(
                                          fontSize: 12,
                                          color: NewColor.txGrayColor,
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Network",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                          fontSize: 12,
                                          color: NewColor.txGrayColor,
                                          fontWeight: FontWeight.w500)),
                                  Text(widget.network,
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                        fontSize: 12,
                                        color: NewColor.txGrayColor,
                                      )),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Fee",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                          fontSize: 12,
                                          color: NewColor.txGrayColor,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: MyColor.backgroundColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                                    child: Text("${widget.fee} USDT",
                                        style: NewStyle.tx28White.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: NewColor.btnBgGreenColor,
                                        )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total amount",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                          fontSize: 12,
                                          color: NewColor.txGrayColor,
                                          fontWeight: FontWeight.w500)),
                                  Text("${widget.amount} USDT",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                        fontSize: 12,
                                        color: NewColor.txGrayColor,
                                      )),
                                ],
                              ),
                            ],
                          )),
                      const SizedBox(height: 33),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            child: TextButton(
                              onPressed: () => (Navigator.pop(context)),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: Color(0x33D1D1D1),
                                    width: 0.5,
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
                          SizedBox(
                            // width: double.infinity,
                            width: (MediaQuery.of(context).size.width - 72) / 2,
                            child: TextButton(
                              onPressed: () => (Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SendTokenDetailScreen();
                              }))),
                              style: TextButton.styleFrom(
                                backgroundColor: NewColor.btnBgGreenColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                      )
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
