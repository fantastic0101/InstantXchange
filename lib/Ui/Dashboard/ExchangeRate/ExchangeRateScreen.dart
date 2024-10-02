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
import 'package:flutter_animate/flutter_animate.dart';

// ignore: must_be_immutable
class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({
    super.key,
  });

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> data = [];
  Map<String, dynamic> rateInfo = {};
  late List<Map<String, dynamic>> coinList = [];
  late List<Map<String, dynamic>> sCoinList = [];
  String? searchCoin;

  getExchangeRate() async {
    setState(() {
      isLoading = true;
    });
    final String url = 'https://instantexchangers.com/mobile_server/get-exchange-rates';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'type': 'all',
          'status': 'all'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = await jsonDecode(response.body);
        if(mounted) {
          setState(() {
            rateInfo = res['coins'];
            isLoading = false;
          });
        }
      } else {
        if(response.statusCode == 301)
          {
            final redirectedResponse = await http.post(
              Uri.parse(response.headers['location']!),
              headers: {
                'Authorization': 'Bearer ${token}',
              },
              body: {
                'type': 'all',
                'status': 'all'
              },
            );
            Map<String, dynamic> res = await jsonDecode(redirectedResponse.body);
            if(mounted) {
              setState(() {
                rateInfo = res['coins'];
                isLoading = false;
              });
            }
          }
        else
          setState(() {
            isLoading = false;
          });
      }
    } catch (e) {
      print(e);
    }
  }

  getCoinItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      setState(() {
        isLoading = true;
      });

      final response = await http.post(
          Uri.parse('https://instantexchangers.com/mobile_server/get-coins'),
          headers: {
            'Authorization': 'Bearer ${token}'
          },
          body: {
            'type': 'buy'
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['coins'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        if(mounted) {
          setState(() {
            sCoinList = info;
            coinList = info;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  filterCoins() async {
    List<Map<String, dynamic>> filteredCoins = sCoinList.where((coin) {
      return coin['coin_code'].contains(searchCoin!.toUpperCase()) || coin['coin_name'].toUpperCase().contains(searchCoin!.toUpperCase());
    }).toList();

    if(mounted) {
      setState(() {
        coinList = filteredCoins;
      });
    }
  }

  @override
  void initState() {
    getExchangeRate();
    getCoinItems();
    super.initState();
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
        padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              cursorColor: NewColor.btnBgGreenColor,
              style: NewStyle.tx28White.copyWith(fontSize: 12),
              onChanged: (value) {
                setState(() {
                  searchCoin = value;
                });
                filterCoins();
              },
              decoration: NewStyle.searchInputDecoration.copyWith(
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
                width: MediaQuery.of(context).size.width - 54,
                padding: EdgeInsets.only(bottom: 8),
                child: Table(columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                }, children: [
                  TableRow(
                    children: [
                      Center(
                        child: Text(
                          'Coin',
                          style: NewStyle.tx28White.copyWith(
                              fontSize: 10,
                              color: NewColor.splashContentWhiteColor),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Your Buy Price (NGN)',
                          style: NewStyle.tx28White.copyWith(
                              fontSize: 10,
                              color: NewColor.splashContentWhiteColor),
                        ),
                      ),
                      Center(
                        child: Text(
                          'You Buy Sell (NGN)',
                          style: NewStyle.tx28White.copyWith(
                              fontSize: 10,
                              color: NewColor.splashContentWhiteColor),
                        ),
                      ),
                    ],
                  )
                ])),
            Container(
              height: 0.5,
              color: Color(0x33D1D1D1),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child:
                  rateInfo.length == 0 ? Text("") : Container(
                    margin: EdgeInsets.only(bottom: 90),
                    width: MediaQuery.of(context).size.width - 54,
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        for (int i = 0; i < coinList.length; i++)
                          TableRow(
                            children: [
                              Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(
                                          0x19D1D1D1),
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 19, bottom: 19),
                                  child: Column(
                                    children: [
                                      Text(coinList[i]["coin_code"],
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 10,
                                              color: NewColor
                                                  .splashContentWhiteColor)),
                                      Text(coinList[i]["coin_name"],
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 8,
                                              color: NewColor.txGrayColor)),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(
                                          0x19D1D1D1),
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 19, bottom: 19),
                                  child: Column(
                                    children: [
                                      Text("${rateInfo[coinList[i]["coin_code"]]['buy_price']}",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF00A478))),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(
                                          0x19D1D1D1), // Color of the bottom border
                                      width: 0.3,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 19, bottom: 19),
                                  child: Column(
                                    children: [
                                      Text("${rateInfo[coinList[i]["coin_code"]]['sell_price']}",
                                          style: NewStyle.tx28White.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF00A478))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
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
