import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/HistoryFilterScreen.dart';
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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedAccountName = "";
  String type = "all";
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> dData = [];
  bool _showRefresh = false;

  getWalletName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }
  bool isLoading = false;

  filterData() async {
    List<Map<String, dynamic>> filteredCoins = data.where((coin) {
      return coin['invoice'].toLowerCase().contains(searchController.text.toLowerCase()) || coin['status'].toLowerCase().contains(searchController.text.toLowerCase()) || coin['paid_amount'].toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();

    if(mounted) {
      setState(() {
        dData = filteredCoins;
      });
    }
  }

  getHistoryInfo() async {
    setState(() {
      isLoading = true;
      _showRefresh = true;
    });
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
          'type': type,
          'status': 'all'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['transactions'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          data = info;
          dData = info;
          searchController.text = "";
          isLoading = false;
          _showRefresh = false;
        });
      } else {
        setState(() {
          isLoading = false;
          _showRefresh = false;
        });
      }
    } catch (e) {
      setState(() {
        _showRefresh = false;
      });
      print(e);
    }
  }

  getHistoryInfo2() async {
    setState(() {
      _showRefresh = true;
    });
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
          'type': type,
          'status': 'all'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['transactions'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          data = info;
          dData = info;
          searchController.text = "";
          _showRefresh = false;
        });
      } else {
        setState(() {
          _showRefresh = false;
        });
      }
    } catch (e) {
      setState(() {
        _showRefresh = false;
      });
      print(e);
    }
  }

  doNothing() {}

  @override
  void initState() {
    super.initState();
    getHistoryInfo();
    getWalletName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ?
      Align(
        alignment: Alignment.center,
        child: const Center(
            child: CircularProgressIndicator(
              color: MyColor.greenColor,
            )),
      ) : Padding(
        padding: const EdgeInsets.fromLTRB(24, 68, 24, 24),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardScreen()),
                      );
                    },
                    child: Image.asset(
                      "assets/images/arrow_left.png",
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    )),
                SizedBox(width: MediaQuery.of(context).size.width / 2 - 79),
                Text(
                  "History",
                  style: NewStyle.tx28White.copyWith(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 28),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
                    backgroundColor:
                        type == 'all' ? Color(0xFF1B1E25) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  onPressed: () => {
                    setState(() {
                      type = 'all';
                    }),
                    getHistoryInfo()
                  },
                  child: Text("All",
                      style: NewStyle.tx28White.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                ),
                SizedBox(width: 7),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
                    backgroundColor:
                        type == 'buy' ? Color(0xFF1B1E25) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  onPressed: () => {
                    setState(() {
                      type = 'buy';
                    }),
                    getHistoryInfo()
                  },
                  child: Text("Buy",
                      style: NewStyle.tx28White.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                ),
                SizedBox(width: 7),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(14, 8, 14, 8),
                    backgroundColor:
                        type == 'sell' ? Color(0xFF1B1E25) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Rounded corners
                    ),
                  ),
                  onPressed: () => {
                    setState(() {
                      type = 'sell';
                    }),
                    getHistoryInfo()
                  },
                  child: Text("Sell",
                      style: NewStyle.tx28White.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      )),
                ),
                Spacer(),
                InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryFilterScreen()),
                      );

                      // Update the state based on the result
                      if (result != null) {
                        setState(() {
                          data = result;
                          dData = result;
                          searchController.text = "";
                          type = "All";
                        });
                      }
                    },
                    child: Image.asset(
                      "assets/images/filter.png",
                      fit: BoxFit.cover,
                    )),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: searchController,
              cursorColor: NewColor.btnBgGreenColor,
              style: NewStyle.tx28White.copyWith(fontSize: 12),
              onChanged: (value) {
                filterData();
              },
              decoration: NewStyle.searchInputDecoration.copyWith(
                hintText: "Search history",
                prefixIcon: SizedBox(
                  width: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        "assets/images/search.png",
                        height: 18,
                        width: 18,
                      ),
                      const SizedBox(width: 12.5),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
                height: 0.5,
                decoration: BoxDecoration(color: Color(0x33D1D1D1))),
            const SizedBox(height: 12),
            Expanded(
              child:
              dData.length != 0 ? Container(
                padding: const EdgeInsets.only(top: 0),
                margin: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  color: MyColor.backgroundColor,
                ),
                child: DeclarativeRefreshIndicator(
                  color: MyColor.greenColor,
                  backgroundColor: MyColor.mainWhiteColor,
                  onRefresh: getHistoryInfo2,
                  refreshing: _showRefresh,
                child:
                ListView.builder(
                  itemCount: dData.length,
                  padding: const EdgeInsets.all(0),
                  itemBuilder: (context, index) {
                    var list = dData[index];
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 12, bottom: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                child: Image.asset(
                                  list['type'] == "buy"
                                      ? "assets/images/buy.png"
                                      : "assets/images/sell.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                // Use Expanded to properly handle the layout
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          list['type'] == "buy"
                                              ? "Buy"
                                              : "Sell",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: NewColor
                                                  .splashContentWhiteColor),
                                        ),
                                        Text(
                                          list['type'] == "buy"
                                              ? "+ ${NumberFormat('#,###.########').format(double.parse(list['coin_amount']))} ${list['coin_code']}"
                                              : "- ${NumberFormat('#,###.########').format(double.parse(list['coin_amount']))} ${list['coin_code']}",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: list['type'] == "buy"
                                                  ? NewColor.mainWhiteColor
                                                  : const Color(0xFFA73E03)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${list['created_at']}",
                                          style: NewStyle.tx14SplashWhite
                                              .copyWith(
                                              fontSize: 10,
                                              color: NewColor.txGrayColor),
                                        ),
                                        Text(
                                          "${list['status']}",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF017F04)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          list['type'] == "buy"
                                              ? "Paid"
                                              : "Got",
                                          style: NewStyle.tx14SplashWhite
                                              .copyWith(
                                              fontSize: 10,
                                              color: NewColor.txGrayColor),
                                        ),
                                        Text(
                                          "${NumberFormat('#,###.####').format(double.parse(list['paid_amount']))} USD",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF999999)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Invoice",
                                          style: NewStyle.tx14SplashWhite
                                              .copyWith(
                                              fontSize: 10,
                                              color: NewColor.txGrayColor),
                                        ),
                                        Text(
                                          "${list['invoice']}",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFFBFBFBF)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            height: 0.5,
                            decoration:
                            BoxDecoration(color: Color(0x33D1D1D1))),
                      ],
                    );
                  },
                ),
                ),
              ) : Align(
                alignment: Alignment.topCenter,
                child: Text("There is no history",
                    style: NewStyle.tx28White.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
