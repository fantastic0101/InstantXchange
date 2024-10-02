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
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinSendProcessingPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'QrScannerPage.dart';

// ignore: must_be_immutable
class SendTokenDetailScreen extends StatefulWidget {
  SendTokenDetailScreen({
    super.key,
  });

  @override
  State<SendTokenDetailScreen> createState() => _SendTokenDetailScreenState();
}

class _SendTokenDetailScreenState extends State<SendTokenDetailScreen> {
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
          padding: const EdgeInsets.only(top: 70, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/confirm.png",
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 26),
              Text("Transaction confirmed",
                  style: NewStyle.tx28White.copyWith(
                    fontSize: 20,
                  )),
              Text("Your transaction has been processed",
                  style: NewStyle.tx14SplashWhite
                      .copyWith(height: 1.3, color: NewColor.txGrayColor)),
              const SizedBox(height: 6),
              Text("Check History for order status",
                  style: NewStyle.tx14SplashWhite
                      .copyWith(height: 1.3, color: NewColor.txGrayColor)),
              const SizedBox(height: 45),
              Text("Transaction amount",
                  style: NewStyle.tx14SplashWhite
                      .copyWith(height: 1.3, color: NewColor.txGrayColor)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    height: 22,
                    width: 22,
                    fit: BoxFit.fill,
                    imageUrl:
                        "https://smanager.instantexchangers.net/assets/media/uploads/coin_logos/1711733661_c5ff428177b78a7fa50b.png",
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                          color: NewColor.btnBgGreenColor),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 22,
                      width: 22,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: MyColor.whiteColor,
                      ),
                      child: Image.asset(
                        "assets/images/bitcoin.png",
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text("5.001 USDT",
                      style: NewStyle.tx28White.copyWith(
                        fontSize: 20,
                      )),
                ],
              ),
              const SizedBox(height: 39),
              Container(
                width: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: Color(0x80825728),
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
                                          color:
                                              NewColor.splashContentWhiteColor,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    width: 191,
                                    child: Text(
                                        "35s7bBwpVzsCziXQQkZQtB8oXtR5tW8Mon",
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
                                          color:
                                              NewColor.splashContentWhiteColor,
                                          fontWeight: FontWeight.w500)),
                                  Text("Ethereum USDTTRC20",
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
                                  Text("Fee charged",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                          fontSize: 12,
                                          color:
                                              NewColor.splashContentWhiteColor,
                                          fontWeight: FontWeight.w500)),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: MyColor.backgroundColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
                                    child: Text("0.1 USDT",
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
                                          color:
                                              NewColor.splashContentWhiteColor,
                                          fontWeight: FontWeight.w500)),
                                  Text("5.001 USDT",
                                      style: NewStyle.tx14SplashWhite.copyWith(
                                        fontSize: 12,
                                        color: NewColor.txGrayColor,
                                      )),
                                ],
                              ),
                            ],
                          )),
                      const SizedBox(height: 45),
                      SizedBox(
                        // width: double.infinity,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => (Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CoinScreen();
                          }))),
                          style: TextButton.styleFrom(
                            backgroundColor: NewColor.btnBgGreenColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "View History",
                            style: NewStyle.btnTx16SplashBlue
                                .copyWith(color: NewColor.mainWhiteColor),
                          ),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
