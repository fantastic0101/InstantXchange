import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';

// ignore: must_be_immutable
class ReceiveScreen extends StatefulWidget {
  int networkId;
  String tokenName, tokenSymbol, tokenImage, tokenType;

  ReceiveScreen({
    super.key,
    required this.networkId,
    required this.tokenName,
    required this.tokenSymbol,
    required this.tokenImage,
    required this.tokenType,
  });

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  late String selectedAccountName = "Bitcoin",
      selectedAccountSymbol = "BTC",
      selectedAccountAddress = "",
      selectedAccountId;
  final List<String> tokenTypes = ["ETH", "BNB", "MATIC", "BTC", "TRX", "DOGE", "LTC", "USDT(BEP20)", "USDT(TRC20)"];
  String? selectedToken;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    // selectedAccount();
  }

  getWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    try {
      final response = await http.get(
        Uri.parse('https://instantexchangers.com/mobile_server/api/wallet/address').replace(queryParameters: {
          "networkType": selectedToken
        }), // Get Wallet Information
        headers: {
          'Authorization': 'Bearer $token', // Include the JWT token
        }
      );

      if (response.statusCode == 200) {
        String? addr = response.body;
        addr = addr.substring(1, addr.length - 1);
        setState(() {
          selectedAccountAddress = addr!;
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    selectedAccountName = sharedPreferences.getString('accountName') ?? "";

    await DbAccountAddress.dbAccountAddress
        .getPublicKey(selectedAccountId, widget.networkId);
    selectedAccountAddress =
        DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;

    // await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,widget.networkId);

    setState(() {
      selectedAccountAddress =
          DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      isLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  "Receive",
                  style: NewStyle.tx28White.copyWith(fontSize: 20),
                ),
              ],
            ),

            const SizedBox(height: 35),
            Text(
              "Network Address",
              style: NewStyle.tx28White.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: NewColor.txGrayColor),
            ),
            const SizedBox(height: 5),
            Container(
                padding:
                    EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0x99D1D1D1),
                    width: 0.5,
                  ),
                  color: NewColor.dashboardPrimaryColor,
                ),
                child: DropdownButton<String>(
                  value: selectedToken,  // This is the currently selected item.
                  hint: Text(
                    'Select a token type.',
                    style: TextStyle(color: NewColor.txGrayColor), // Change the color here
                  ),  // Placeholder text.
                  elevation: 16,  // Elevation for the dropdown menu.
                  isExpanded: true,
                  style: TextStyle(color: NewColor.txGrayColor),  // Text style for the dropdown items.
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,  // Color of the underline when dropdown is selected.,
                  ),
                  onChanged: (String? newValue) {
                    getWalletAddress();
                    setState(() {
                      selectedToken = newValue;  // Update the selected value.
                    });
                  },
                  dropdownColor: NewColor.dashboardPrimaryColor,
                  items: tokenTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value)
                    );
                  }).toList(),  // Map the list of items to DropdownMenuItem widgets.
                ),
            ),
            const SizedBox(height: 19),
            Text(
              "Wallet Address",
              style: NewStyle.tx28White.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: NewColor.txGrayColor),
            ),
            const SizedBox(height: 5),
            Container(
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, right: 16, left: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0x99D1D1D1),
                    width: 0.5,
                  ),
                  color: NewColor.dashboardPrimaryColor,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedAccountAddress,
                          style: NewStyle.tx14SplashWhite.copyWith(
                              fontSize: 12,
                              height: 2,
                              fontWeight: FontWeight.w400,
                              color: NewColor.txGrayColor)),
                      InkWell(
                          onTap: () {
                            FlutterClipboard.copy(selectedAccountAddress)
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
                    ])),
            const SizedBox(height: 29),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 0.5,
                  width: MediaQuery.of(context).size.width * 0.5 - 46,
                  decoration: BoxDecoration(color: Color(0x5CD1D1D1)),
                ),
                Text("OR",
                    style: NewStyle.tx28White
                        .copyWith(fontSize: 12, color: Color(0xFF3F3E3E))),
                Container(
                  height: 0.5,
                  width: MediaQuery.of(context).size.width * 0.5 - 46,
                  decoration: BoxDecoration(color: Color(0x5CD1D1D1)),
                )
              ],
            ),
            const SizedBox(height: 27),
            // qr and token name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 73, vertical: 15),
              decoration: BoxDecoration(
                  color: NewColor.dashboardPrimaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Text(
                    "Scan QR code",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3F3E3E)),
                  ),
                  SizedBox(height: 6),
                  // Visibility(
                  //   visible: widget.tokenType.isNotEmpty,
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(bottom: 12),
                  //     child: Text(
                  //       "Type: ${widget.tokenType}",
                  //       textAlign: TextAlign.center,
                  //       style: MyStyle.tx18RWhite
                  //           .copyWith(fontSize: 12, color: MyColor.whiteColor),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    height: height * 0.26,
                    width: width * 0.55,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: MyColor.mainWhiteColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: QrImageView(
                        data: selectedAccountAddress,
                        eyeStyle: const QrEyeStyle(
                            color: MyColor.backgroundColor,
                            eyeShape: QrEyeShape.square),
                        dataModuleStyle: const QrDataModuleStyle(
                            color: MyColor.backgroundColor,
                            dataModuleShape: QrDataModuleShape.square),
                        //embeddedImage: AssetImage('assets/icons/logo.png'),
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // copy and shared

            const SizedBox(height: 34),

            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Color(0xFF8C571E),
                  width: 1,
                ),
                color: Color(0x808C571E),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Note:",
                    style: NewStyle.tx28White.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "You were to deposit at least ",
                        style: NewStyle.tx14SplashWhite.copyWith(
                            fontSize: 10,
                            height: 2,
                            fontWeight: FontWeight.w400,
                            color: NewColor.splashContentWhiteColor)),
                    TextSpan(
                        text: "0.0005 ${widget.tokenSymbol} ",
                        style: NewStyle.tx14SplashWhite.copyWith(
                            fontSize: 10,
                            height: 2,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8C571E))),
                    TextSpan(
                        text:
                            "to be funded, otherwise your wallet will not be funded",
                        style: NewStyle.tx14SplashWhite.copyWith(
                            fontSize: 10,
                            height: 2,
                            fontWeight: FontWeight.w400,
                            color: NewColor.splashContentWhiteColor)),
                  ]))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
