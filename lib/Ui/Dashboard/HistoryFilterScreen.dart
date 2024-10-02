import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Settings/WalletConnect/WalletConnectScreen.dart';
import 'Settings/WalletsPages/WalletsListingScreen.dart';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';
import 'dart:convert';

class HistoryFilterScreen extends StatefulWidget {
  const HistoryFilterScreen({super.key});

  @override
  State<HistoryFilterScreen> createState() => _HistoryFilterScreenState();
}

class _HistoryFilterScreenState extends State<HistoryFilterScreen> {
  String selectedAccountName = "";
  int type = 0;
  TextEditingController searchController = TextEditingController();
  TextEditingController invoiceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String statusType = "All";
  String tType = "All";

  getHistoryInfo() async {
    final String url = 'https://instantexchangers.com/mobile_server/get-transaction-histories';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'type': statusType.toLowerCase(),
          'status': tType.toLowerCase(),
          'invoice_number': invoiceController.text,
          'from_amount': amountController.text,
          'to_amount': amountController.text,
          'from_date': dateController.text,
          'to_date': dateController.text,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['transactions'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        Fluttertoast.showToast(
            msg: "History searched successfully.",
            toastLength: Toast.LENGTH_SHORT, // Toast duration
            gravity: ToastGravity.BOTTOM, // Toast position
            timeInSecForIosWeb: 1, // Duration for iOS and web
            backgroundColor: Colors.black, // Background color
            textColor: Colors.white, // Text color
            fontSize: 16.0 // Font size
        );
        return info;
      } else {
        if(response.statusCode == 301) {
          final redirectedResponse = await http.post(
            Uri.parse(response.headers['location']!),
            headers: {
              'Authorization': 'Bearer ${token}',
            },
            body: {
              'type': statusType.toLowerCase(),
              'status': tType.toLowerCase(),
              'invoice_number': invoiceController.text,
              'from_amount': amountController.text,
              'to_amount': amountController.text,
              'from_date': dateController.text,
              'to_date': dateController.text,
            },
          );

          Map<String, dynamic> res= await jsonDecode(redirectedResponse.body);
          List<dynamic> result = res['transactions'];
          List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
          Fluttertoast.showToast(
              msg: "History searched successfully.",
              toastLength: Toast.LENGTH_SHORT, // Toast duration
              gravity: ToastGravity.BOTTOM, // Toast position
              timeInSecForIosWeb: 1, // Duration for iOS and web
              backgroundColor: Colors.black, // Background color
              textColor: Colors.white, // Text color
              fontSize: 16.0 // Font size
          );
          return info;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                  SizedBox(width: MediaQuery.of(context).size.width / 2 - 122),
                  Text(
                    "Filter transaction",
                    style: NewStyle.tx28White.copyWith(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "Type",
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              DropdownButtonFormField<String>(
                value: statusType,
                isExpanded: true,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "Select Bank",
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Color(0xFF646565),
                ),
                dropdownColor: NewColor.dashboardPrimaryColor,
                items: ["All", "Buy", "Sell"].map((String category) {
                  return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: NewStyle.tx28White.copyWith(fontSize: 12),
                      ));
                }).toList(),
                onChanged: (String? value) async {
                  setState(() {
                    statusType = value!;
                  });

                  print(statusType);
                },
              ),
              SizedBox(height: 20),
              Text(
                "Status",
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              DropdownButtonFormField<String>(
                value: tType,
                isExpanded: true,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                decoration: NewStyle.searchInputDecoration.copyWith(),
                icon: const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Color(0xFF646565),
                ),
                dropdownColor: NewColor.dashboardPrimaryColor,
                items: ["All", "Waiting", "Confirming", "Processing", "Completed"].map((String category) {
                  return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: NewStyle.tx28White.copyWith(fontSize: 12),
                      ));
                }).toList(),
                onChanged: (String? value) async {
                  setState(() {
                    tType = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                "Date",
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              TextFormField(
                controller: dateController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "Date",
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Invoce Number",
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              TextFormField(
                controller: invoiceController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "2337-746-b",
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Amount",
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              TextFormField(
                controller: amountController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "\$250",
                ),
              ),
              SizedBox(height: 51),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: TextButton(
                      onPressed: () => (
                        searchController.text = "",
                        dateController.text = "",
                        invoiceController.text = "",
                        amountController.text = ""
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Color(0x33D1D1D1),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        "Reset",
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.mainWhiteColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    // width: double.infinity,
                    width: (MediaQuery.of(context).size.width - 72) / 2,
                    child: TextButton(
                      onPressed: () => (Navigator.pop(context, getHistoryInfo())),
                      style: TextButton.styleFrom(
                        backgroundColor: NewColor.btnBgGreenColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Apply",
                        style: NewStyle.btnTx16SplashBlue
                            .copyWith(color: NewColor.mainWhiteColor),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
