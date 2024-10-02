import 'package:clipboard/clipboard.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/HistoryScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/BankScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SellCoin/SellCoinConfirmScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

import '../../../../Values/Helper/helper.dart';

class BuyCoinDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> bank;
  const BuyCoinDetailScreen({Key? key, required this.data, required this.bank}) : super(key: key);

  @override
  State<BuyCoinDetailScreen> createState() => _BuyCoinDetailScreenState();
}

class _BuyCoinDetailScreenState extends State<BuyCoinDetailScreen> {
  String selectedAccountName = "";
  int type = 0;
  TextEditingController searchController = TextEditingController();
  TextEditingController invoiceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  int isBuy = 0;
  String coinType = "Tether TRC20";
  String bankType = "First bank";
  int selectedBank = 0;
  late Map<String, dynamic> resultData;
  late Map<String, dynamic> bankData;
  bool isLoading = false;

  paidBuyOrder() async {
    setState(() {
      isLoading = true;
    });

    final String url = 'https://instantexchangers.com/mobile_server/paid-buy-order';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'transaction_no': resultData['transaction'],
          'vat_amount': resultData['vat_amount'].toString()
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Successfully paid.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );

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
    }
  }

  @override
  void initState() {
    resultData = widget.data;
    bankData = widget.bank;
    print(resultData);
    print(bankData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 68, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(width: MediaQuery.of(context).size.width / 2 - 90),
                  Text(
                    "Buy",
                    style: NewStyle.tx28White.copyWith(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 42),
              Text(
                "Preview",
                style: NewStyle.tx28White.copyWith(fontSize: 20),
              ),
              SizedBox(height: 17),
              Container(
                padding: EdgeInsets.all(8),
                width: double.infinity,
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
                      "Payment Instruction & Notice",
                      style: NewStyle.tx28White.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Image.asset(
                            "assets/images/ellipse.png",
                            width: 6,
                            height: 6,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              "Do not include any crypto related remark in your bank transfer memo space.",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 10,
                                  height: 2,
                                  fontWeight: FontWeight.w400,
                                  color: NewColor.splashContentWhiteColor)),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Image.asset(
                            "assets/images/ellipse.png",
                            width: 6,
                            height: 6,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text("We don’t accept payment from 3rd party.",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 10,
                                  height: 2,
                                  fontWeight: FontWeight.w400,
                                  color: NewColor.splashContentWhiteColor)),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          child: Image.asset(
                            "assets/images/ellipse.png",
                            width: 6,
                            height: 6,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              "Kindly send payment from your verified name on instantexchnagers",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 10,
                                  height: 2,
                                  fontWeight: FontWeight.w400,
                                  color: NewColor.splashContentWhiteColor)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 17),
              Container(
                padding: EdgeInsets.fromLTRB(8, 13, 8, 13),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0x33D1D1D1),
                    width: 0.5,
                  ),
                  color: Color(0xFF1B1E25),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Color(0x33D1D1D1),
                      width: 0.5,
                    ),
                    color: Color(0xFF141416),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Invoice Number",
                              style: NewStyle.tx28White.copyWith(
                                  fontSize: 14, color: NewColor.txGrayColor)),
                          Spacer(),
                          Text("${resultData['transaction']}",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: NewColor.mainWhiteColor)),
                        ],
                      ),
                      SizedBox(height: 11),
                      Container(
                          height: 0.5,
                          decoration: BoxDecoration(color: Color(0x33D1D1D1))),
                      SizedBox(height: 10),
                      Text(
                          textAlign: TextAlign.center,
                          "Kindly include ${resultData['transaction']} in your bank transfer remark ",
                          style: NewStyle.tx14SplashWhite.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.7,
                              color: NewColor.mainWhiteColor)),
                      SizedBox(height: 15),
                      Container(
                          height: 0.5,
                          decoration: BoxDecoration(color: Color(0x33D1D1D1))),
                      SizedBox(height: 10),
                      Text(
                          "Kindly transfer  ${NumberFormat('#,###.####').format(resultData['send_ngn_amount'])} NGN to the bank details below",
                          style: NewStyle.tx14SplashWhite.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              height: 1.7,
                              color: Color(0xFF1764FF))),
                      SizedBox(height: 21),
                      Row(
                        children: [
                          Text("Bank Name",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: NewColor.txGrayColor)),
                          Spacer(),
                          Text("${bankData['bank_full_name']}",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: NewColor.mainWhiteColor),
                              overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text("Bank Account Number",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: NewColor.txGrayColor)),
                          Spacer(),
                          SizedBox(
                            width: 150.0, // Set the desired width
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${bankData['account_number']}",
                                    style: NewStyle.tx14SplashWhite.copyWith(
                                      fontSize: 12,
                                      height: 1.2,
                                      color: NewColor.mainWhiteColor,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Optional: add overflow handling
                                  ),
                                  SizedBox(width: 2,),
                                  InkWell(
                                      onTap: () {
                                        FlutterClipboard.copy(bankData['account_number'])
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
                                ],
                              )
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text("Bank Account Name",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: NewColor.txGrayColor)),
                          Spacer(),
                          Text("${bankData['account_name']}",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: NewColor.mainWhiteColor),
                                  overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 35),
              isLoading == true
                  ? const Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  ))
                  : SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => {
                    paidBuyOrder()
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
