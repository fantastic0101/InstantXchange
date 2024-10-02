import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

class SellCoinScreen extends StatefulWidget {
  const SellCoinScreen({super.key});

  @override
  State<SellCoinScreen> createState() => _SellCoinScreenState();
}

class Coin {
  final String name;
  final IconData icon;
  const Coin(this.name, this.icon);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

class _SellCoinScreenState extends State<SellCoinScreen> {
  String selectedAccountName = "";
  int type = 0;
  TextEditingController amountController = TextEditingController();
  String statusType = "All";
  int selectedBank = 0;
  late List<Map<String, dynamic>> banks = [];
  late List<Map<String, dynamic>> coinList = [];
  String coinType = "Tether TRC20";
  late Map<String, dynamic> selectedCoin = {};
  late List<Coin> _list = [];
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  getCoinId(String? name) async {
    try {
      Map<String, dynamic> element = coinList.firstWhere(
            (map) => map['coin_name'] == coinType,
        orElse: () => throw Exception('No element found with name ${coinType}'),
      );

      setState(() {
        selectedCoin = element;
      });

    } catch (e) {
      print(e);
    }
  }

  getCoinItems() async {
    try {
      setState(() {
        isLoading = true;
      });
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
          Uri.parse('https://instantexchangers.com/mobile_server/get-coins'), // Get Wallet Information,
          headers: {
            'Authorization': 'Bearer ${token}'
          },
          body: {
            'type': 'sell'
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['coins'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        List<Coin> newList = info.map((coin) {
          String name = coin['coin_name'] + "(" + coin['coin_code'] + ")";
          IconData icon = Icons.help_outline;
          return Coin(name, icon);
        }).toList();

        setState(() {
          coinList = info;
          isLoading = false;
          _list = newList;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
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
            banks = info;
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
              banks = info;
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
    }
  }

  getSellAmount() async {
    setState(() {
      isLoading = true;
    });
    final String url = 'https://instantexchangers.com/mobile_server/get-sell-amount';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    getCoinId(coinType);

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'coin_id': selectedCoin['coin_id'],
          'amount': amountController.text,
          'direction': 'forward'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        var bankData = banks[selectedBank];
        var sellInfo = res;
        setState(() {
          isLoading = false;
        });
        Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return SellCoinConfirmScreen(bData: bankData, sData: sellInfo, cData: selectedCoin);
        }));
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getBanks();
    getCoinItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Align(
        alignment: Alignment.center,
        child: const Center(
            child: CircularProgressIndicator(
              color: MyColor.greenColor,
            )),
      ) : Form(
        key: _formKey,
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
                    "Sell Coin",
                    style: NewStyle.tx28White.copyWith(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                "Sell coin to any Bank in Nigeria & Receive Naira",
                style: NewStyle.tx14SplashWhite.copyWith(
                    fontSize: 12, height: 1.2, color: NewColor.txGrayColor),
              ),
              SizedBox(height: 25),
              Container(
                width: double.infinity,
                // padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: NewColor.dashboardPrimaryColor,
                    border: Border.all(width: 0.5, color: Colors.transparent)),
                child:
                CustomDropdown<Coin>.search(
                  hintText: 'Select Coin',
                  items: _list,
                  excludeSelected: false,
                  decoration: CustomDropdownDecoration(
                      listItemDecoration: ListItemDecoration(
                          selectedColor: NewColor.txGrayColor
                      ),
                      expandedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_up_sharp,
                        color: Color(0xFF646565),
                      ),
                      closedSuffixIcon: const Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Color(0xFF646565),
                      ),
                      headerStyle: NewStyle.tx28White.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: NewColor.mainWhiteColor),
                      closedBorderRadius: BorderRadius.circular(5.0),
                      expandedBorderRadius: BorderRadius.circular(5.0),
                      closedFillColor: NewColor.dashboardPrimaryColor,
                      expandedFillColor: NewColor.dashboardPrimaryColor,
                      hintStyle: NewStyle.tx28White.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: NewColor.txGrayColor),
                      listItemStyle: NewStyle.tx28White.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: NewColor.mainWhiteColor),

                      searchFieldDecoration: SearchFieldDecoration(
                        fillColor: NewColor.dashboardPrimaryColor,
                        textStyle: NewStyle.tx28White.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: NewColor.txGrayColor),
                        hintStyle: NewStyle.tx28White.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: NewColor.txGrayColor),
                      )
                  ),
                  onChanged: (value) async {
                    String temp = value.toString();
                    setState(() {
                      coinType = temp.substring(0, temp.indexOf("("));
                    });
                    getCoinId(temp.substring(0, temp.indexOf("(")));
                  },
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Withdraw Amount",
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  final number = num.tryParse(value);
                  if (number == null) {
                    return 'Please enter a valid number';
                  }
                  if (number < 10) {
                    return 'The amount must be bigger than 10';
                  }
                  if (number > 10000) {
                    return 'The amount must be smaller than 10000';
                  }
                  return null;
                },
                decoration: NewStyle.dashboardInputDecoration.copyWith(
                    hintText: " ",
                    suffixIcon: SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("USD",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: NewColor.txGrayColor)),
                          const SizedBox(width: 12.5),
                        ],
                      ),
                    )),
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BankScreen()));
                    getBanks();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: NewColor.btnBgGreenColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    "Add Bank",
                    style: NewStyle.tx28White.copyWith(
                        color: NewColor.splashContentWhiteColor, fontSize: 12),
                  ),
                ),
              ),
              SizedBox(height: 24),
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
              SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 0, bottom: 20),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: banks.length,
                    itemBuilder: (context, index) {
                      var item = banks[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedBank = index;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: selectedBank == index
                                ? NewColor.dashboardPrimaryColor
                                : Colors.transparent,
                            border: Border.all(
                              width: 0.5,
                              color: Color(0x33D1D1D1),
                            ),
                          ),
                          child: Row(children: [
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
                                    color: NewColor.txGrayColor,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => banks.length != 0 ? {
                    if (_formKey.currentState?.validate() ?? false)
                      if(selectedCoin['coin_id'] != null)
                        getSellAmount()
                      else {
                        Fluttertoast.showToast(
                          msg: "Select the coin type.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 16.0
                        )
                      }
                    else {}
                  } : {
                    Fluttertoast.showToast(
                        msg: "You should add personal bank information.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 16.0
                    )
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: amountController.text.isNotEmpty
                        ? NewColor.btnBgGreenColor
                        : Color(0x1A307581),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Proceed",
                    style: NewStyle.btnTx16SplashBlue.copyWith(
                        color: amountController.text.isNotEmpty
                            ? NewColor.mainWhiteColor
                            : Color(0xFF6B7280)),
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
