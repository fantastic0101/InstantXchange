import 'dart:async';
import 'dart:ffi';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/BankScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/BuyCoin/BuyCoinPreviewScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SellCoin/SellCoinConfirmScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jost_pay_wallet/Values/utils.dart';

class BuyCoinScreen extends StatefulWidget {
  const BuyCoinScreen({super.key});

  @override
  State<BuyCoinScreen> createState() => _BuyCoinScreenState();
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

class _BuyCoinScreenState extends State<BuyCoinScreen> {
  String selectedAccountName = "";
  int type = 0;
  TextEditingController searchController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _amountNGNController = TextEditingController();
  TextEditingController _memoController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  int isBuy = 0;
  String? coinType;
  String feeType = "fast";
  int selectedBank = 0;
  List<Map<String, dynamic>> coinList = [];
  static String direction = "forward";
  late Map<String, dynamic> buyData = {};
  double vatAmount = 0.0;
  double coinAmount = 0.0;
  late Map<String, dynamic> selectedCoin = {};
  late Map<String, dynamic> coinFees = {
    'fast': 0,
    'normal': 0
  };
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool apiLoading = false;
  Timer? _debounce;

  late List<Coin> _list = [];

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
            'type': 'buy'
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

  getBuyAmount() async {
    getCoinId(coinType);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
          Uri.parse('https://instantexchangers.com/mobile_server/get-buy-amount'), // Get Wallet Information,
          headers: {
            'Authorization': 'Bearer ${token}'
          },
          body: {
            'coin_id': selectedCoin['coin_id'],
            'amount': _amountController.text,
            'fee_type': feeType,
            'direction': direction
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        print(res);
        if(res['result'] != false) {
          setState(() {
            buyData = res;
            buyData['coin_id'] = selectedCoin['coin_id'];
            coinAmount = res['get_coin_amount'].toDouble();
            vatAmount = res['vat_amount'].toDouble();
            _amountNGNController.text = res['send_ngn_amount'].toString();
          });
        }
        else {
          setState(() {
            buyData = res;
            buyData['coin_id'] = selectedCoin['coin_id'];
            coinAmount = 0;
            vatAmount = 0;
            _amountNGNController.text = "0";
          });
        }
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getCoinId(String? name) async {
    print(name);
    try {
      Map<String, dynamic> element = coinList.firstWhere(
            (map) => map['coin_name'] == coinType,
        orElse: () => throw Exception('No element found with name ${coinType}'),
      );

      setState(() {
        selectedCoin = element;
      });

      getCoinFees();
    } catch (e) {
      print(e);
    }
  }

  getCoinFees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
          Uri.parse('https://instantexchangers.com/mobile_server/get-buy-fees'), // Get Wallet Information,
          headers: {
            'Authorization': 'Bearer ${token}'
          },
          body: {
            'coin_id': selectedCoin['coin_id']
          }
      );

      if (response.statusCode == 200) {
        setState(() {
          coinFees = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    getCoinItems();
    getBuyAmount();
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
      ) : SingleChildScrollView(
        child: Form(
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
                    "Buy Coin",
                    style: NewStyle.tx28White.copyWith(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 35),
              Text(
                "Select Coin/Currency",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 7),
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
                  await getCoinId(temp.substring(0, temp.indexOf("(")));
                  await getBuyAmount();
                },
              ),
              // DropdownButtonFormField<String>(
              //   value: coinType,
              //   isExpanded: true,
              //   style: NewStyle.tx28White.copyWith(fontSize: 12),
              //   hint: Text("Select Coin",
              //     style: NewStyle.tx28White.copyWith(
              //         fontWeight: FontWeight.w400,
              //         fontSize: 12,
              //         color: NewColor.txGrayColor),),
              //   decoration: InputDecoration(
              //     hintStyle: const TextStyle(
              //       color: Colors.grey, // Set the hint text color here
              //       fontSize: 12,
              //     ),
              //     contentPadding: EdgeInsets.symmetric(
              //       horizontal: 16,
              //     ),
              //     filled: true,
              //     fillColor: NewColor.dashboardPrimaryColor, // Background color
              //     border: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Color(0x33D1D1D1),
              //         width: 0.5,
              //       ),
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Color(0x33D1D1D1),
              //         width: 0.5,
              //       ),
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(
              //         color: Color(0x33D1D1D1),
              //         width: 0.5,
              //       ),
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //   ),
              //   icon: const Icon(
              //     Icons.keyboard_arrow_down_sharp,
              //     color: Color(0xFF646565),
              //   ),
              //   dropdownColor: NewColor.dashboardPrimaryColor,
              //   items: coinList.map<DropdownMenuItem<String>>((Map<String, dynamic> coin) {
              //     return DropdownMenuItem(
              //         value: coin['coin_name'],
              //         child: Text(
              //           coin['coin_name'],
              //           maxLines: 2,
              //           overflow: TextOverflow.ellipsis,
              //           style: NewStyle.tx28White.copyWith(fontSize: 12),
              //         ));
              //   }).toList(),
              //   onChanged: (String? value) async {
              //     setState(() {
              //       coinType = value!;
              //     });
              //     getCoinId(coinType);
              //     getBuyAmount();
              //   },
              // ),
              SizedBox(height: 16),
              Text(
                "Amount (USD)",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              TextFormField(
                controller: _amountController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 200), () {
                    getBuyAmount();
                  });
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "Amount",
                ),
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
              ),
              SizedBox(height: 16),
              Text(
                "Amount (NGN)",
                style: NewStyle.tx28White.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 2,
                  color: NewColor.txGrayColor,
                ),
              ),
              SizedBox(height: 3),
              TextFormField(
                controller: _amountNGNController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                enabled: false,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "Amount",
                ),
              ),
              selectedCoin['memo_required'] == "1" ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Memo",
                      style: NewStyle.tx28White.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: NewColor.txGrayColor),
                    ),
                  ),
                  SizedBox(height: 7),
                  TextFormField(
                    controller: _memoController,
                    cursorColor: NewColor.btnBgGreenColor,
                    style: NewStyle.tx28White.copyWith(fontSize: 12),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: NewStyle.searchInputDecoration.copyWith(
                      hintText: "Memo information",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please input memo details.';
                      }
                      return null;
                    }
                  ),
                ],
              ) : SizedBox(),
              coinFees['fast'] != 0 ? SizedBox(height: 16) : SizedBox(height: 0),
              coinFees['fast'] != 0 ? Text(
                "Network fee",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),
              ) : SizedBox(height: 0),
              coinFees['fast'] != 0 ? SizedBox(height: 7) : SizedBox(height: 0),
              coinFees['fast'] != 0 ? DropdownButtonFormField<String>(
                value: feeType,
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
                items: [
                  "fast",
                  "normal"
                ].map((String category) {
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
                    feeType = value!;
                  });
                  getBuyAmount();
                },
              ) : SizedBox(height: 0),
              SizedBox(height: 49),
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Color(0x80825728),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.5, color: Color(0x33D1D1D1))),
                  padding: EdgeInsets.fromLTRB(0, 31, 0, 9),
                  child: Column(
                    children: [
                      Text(
                        "You will pay ${_amountNGNController.text != "" ? NumberFormat('#,###.####').format(double.parse(_amountNGNController.text)) : ""} NGN",
                        style: NewStyle.tx28White.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "(Including 7.5% VAT =${NumberFormat('#,###.####').format(vatAmount.toDouble())} NGN)",
                        style: NewStyle.tx14SplashWhite.copyWith(
                          fontSize: 10,
                          height: 1.7,
                          color: Color(0xFFBFBFBF),
                        ),
                      ),
                      SizedBox(height: 11),
                      Text(
                        "You will receive -After Network fee deduction",
                        style: NewStyle.tx28White.copyWith(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                      ),
                      SizedBox(
                        height: 21,
                      ),
                      DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(5),
                        color: NewColor.btnBgGreenColor,
                        strokeWidth: 1,
                        dashPattern: [3, 3],
                        child: Container(
                          padding: EdgeInsets.fromLTRB(24, 14, 24, 14),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: NewColor.btnBgGreenColor),
                          child: Text(
                            "${NumberFormat('#,###.####').format(coinAmount.toDouble())} ${coinType != null ? coinType : "(Coin Type)"} = ${_amountController.text != "" ? _amountController.text : "0"}\$",
                            style: NewStyle.tx28White.copyWith(
                              fontSize: 12,
                              color: Color(0xFFEAF1F2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 11),
                      Text(
                        "Sending transaction within 60 minutes",
                        style: NewStyle.tx28White.copyWith(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => {
                    if (_formKey.currentState?.validate() ?? false) {
                      if(selectedCoin['coin_id'] != null)
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return BuyCoinPreviewScreen(data: buyData, memo: _memoController.text);
                            }))
                      else
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
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: NewColor.btnBgGreenColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Proceed",
                    style: NewStyle.btnTx16SplashBlue
                        .copyWith(color: NewColor.mainWhiteColor),
                  ),
                ),
              ),
            ],
          ),
        ))
      ),
    );
  }
}
