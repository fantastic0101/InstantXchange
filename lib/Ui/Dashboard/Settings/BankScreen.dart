import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/AddBankScreen.dart';
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

class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  String selectedAccountName = "";
  String _response = "";
  late List<Map<String, dynamic>> data = [];
  bool isLoading = false;

  getWalletName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }

  deleteBank(String bank_id) async {
    final String url = 'https://instantexchangers.com/mobile_server/delete-user-bank';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'bank_id': bank_id
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Bank account deleted successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
        getBanks();
      } else {
        if(response.statusCode == 301)
          {
            final redirectedResponse = await http.post(
              Uri.parse(response.headers['location']!),
              headers: {
                'Authorization': 'Bearer ${token}',
              },
              body: {
                'bank_id': bank_id
              },
            );

            Fluttertoast.showToast(
                msg: "Bank account deleted successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );
            getBanks();
          }
        else
          Fluttertoast.showToast(
              msg: "Something went wrong",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0
          );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        _response = 'Exception: $e';
      });
    }
  }

  getBanks() async {
    setState(() {
      isLoading = true;
    });
    final String url = 'https://instantexchangers.com/mobile_server/get-user-banks';
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
        List<dynamic> result = res['banks'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        if(mounted) {
          setState(() {
            data = info;
            isLoading = false;
          });
        }
        return info;
      } else {
        if(response.statusCode == 301) {
          final redirectedResponse = await http.post(
            Uri.parse(response.headers['location']!),
            headers: {
              'Authorization': 'Bearer ${token}',
            },
            body: {
              'type': 'buy'
            },
          );

          Map<String, dynamic> res= await jsonDecode(redirectedResponse.body);
          List<dynamic> result = res['banks'];
          List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
          if(mounted) {
            setState(() {
              data = info;
              isLoading = false;
            });
          }
          return info;
        }
        else
          setState(() {
            isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _response = 'Exception: $e';
      });
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, String bankId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this account?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                deleteBank(bankId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getWalletName();
    getBanks();
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
                      Navigator.pop(context, getBanks());
                    },
                    child: Image.asset(
                      "assets/images/arrow_left.png",
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    )),
                SizedBox(width: MediaQuery.of(context).size.width / 2 - 68),
                Text(
                  "Bank",
                  style: NewStyle.tx28White.copyWith(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 44),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add a new Bank",
                  style: NewStyle.tx28White.copyWith(fontSize: 18),
                ),
                SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddBankScreen()),
                    );

                    await getBanks();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: NewColor.dashboardPrimaryColor,
                        border:
                            Border.all(width: 0.5, color: Color(0x33D1D1D1))),
                    child: Row(children: [
                      Image.asset(
                        "assets/images/bank.png",
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add a new Bank",
                            style: NewStyle.tx28White.copyWith(fontSize: 16),
                          ),
                          Text(
                            "Average processing period - 2 mins",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 12,
                                height: 1.25,
                                color: NewColor.txGrayColor),
                          ),
                        ],
                      )
                    ]),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                    height: 0.5,
                    decoration: BoxDecoration(color: Color(0x33D1D1D1))),
                SizedBox(height: 14),
                Text(
                  "Saved accounts",
                  style: NewStyle.tx28White.copyWith(fontSize: 18),
                ),
              ],
            ),
            Expanded(
              child:
              isLoading ?
              Align(
                alignment: Alignment.topCenter,
                child: const Center(
                    child: CircularProgressIndicator(
                      color: MyColor.greenColor,
                    )),
              ) : Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
                  decoration: const BoxDecoration(
                    color: MyColor.backgroundColor,
                  ),
                  child: data.length != 0 ? ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var item = data[index];
                        return InkWell(
                            child: Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                              child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.fill,
                                      imageUrl: item['bank_image'],
                                    ),
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${item['bank_full_name']}",
                                          style: NewStyle.tx28White.copyWith(fontSize: 16),
                                        ),
                                        Text(
                                          "${item['account_number']}",
                                          style: NewStyle.tx14SplashWhite.copyWith(
                                              fontSize: 12,
                                              height: 1.25,
                                              color: NewColor.txGrayColor),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        _showConfirmationDialog(context, item['user_bank_id']);
                                      },
                                      child: Image.asset(
                                        "assets/images/remove_bank.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ]),)
                        );
                      }
                  ) : Align(
                    alignment: Alignment.topCenter,
                    child: Text("Please add new bank account",
                      style: NewStyle.tx28White.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      ),
                    )
                  )
              )
            )
          ],
        ),
      ),
    );
  }
}
