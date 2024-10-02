import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/BankScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/BuyCoin/BuyCoinDetailScreen.dart';
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

class BuyCoinPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String memo;
  const BuyCoinPreviewScreen({Key? key, required this.data, required this.memo}) : super(key: key);

  @override
  State<BuyCoinPreviewScreen> createState() => _BuyCoinPreviewScreenState();
}

class _BuyCoinPreviewScreenState extends State<BuyCoinPreviewScreen> {
  String selectedAccountName = "";
  int type = 0;
  TextEditingController ngnController = TextEditingController();
  TextEditingController coinController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  int isBuy = 0;
  String coinType = "Tether TRC20";
  String? bankType;
  int selectedBank = 0;
  late Map<String, dynamic> buyAmount;
  late List<Map<String, dynamic>> banks = [];
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? memoInfo;

  getBanks() async {
    final String url = 'https://instantexchangers.com/mobile_server/get-banks';
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
          if(info.length == 0) {
            Fluttertoast.showToast(
                msg: "Select Preferred Bank",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          setState(() {
            banks = info;
            bankType = banks[0]['bank_id'];
          });
        }
      } else {
      }
    } catch (e) {
    }
  }

  createBuyOrder() async {
    setState(() {
      isLoading = true;
    });
    final String url = 'https://instantexchangers.com/mobile_server/create-buy-order';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
        body: {
          'coin_id': buyAmount['coin_id'],
          'amount': buyAmount['usd_amount'],
          'fee_type': buyAmount['fee_type'],
          'direction': 'forward',
          'user_wallet': walletController.text,
          'bank_id': bankType,
          'memo_details': memoInfo
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        setState(() {
          isLoading = false;
        });
        Navigator.push(context,
          MaterialPageRoute(builder: (context) {
            return BuyCoinDetailScreen(data: res, bank: banks[selectedBank]);
        }));
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    buyAmount = widget.data;
    ngnController.text = buyAmount['send_ngn_amount'].toString();
    coinController.text = buyAmount['get_coin_amount'].toString();
    memoInfo = widget.memo;
    getBanks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
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
                    "Preview",
                    style: NewStyle.tx28White.copyWith(fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 35),
              Text(
                "You will pay",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 7),
              TextFormField(
                controller: ngnController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                enabled: false,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                    hintText: "Amount",
                    suffixIcon: SizedBox(
                        width: 120,
                        child: Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            // color: Color(0xFF141416),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              // const SizedBox(width: 5),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight, // Aligns the text to the right
                                  child: Text(
                                    "NGN",
                                    style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ))),
              ),
              SizedBox(height: 24),
              Text(
                "You will get",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 7),
              TextFormField(
                controller: coinController,
                cursorColor: NewColor.btnBgGreenColor,
                enabled: false,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                    hintText: "Amount",
                    suffixIcon: SizedBox(
                        width: 120,
                        child: Container(
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            // color: Color(0xFF141416),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight, // Aligns the text to the right
                                  child: Text(
                                    buyAmount['coin_code'],
                                    style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ))),
              ),
              SizedBox(height: 35),
              Container(
                  height: 0.5,
                  decoration: BoxDecoration(color: Color(0x33D1D1D1))),
              SizedBox(height: 24),
              Text(
                "Recipient's wallet address",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 2,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 3),
              TextFormField(
                controller: walletController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.searchInputDecoration.copyWith(
                  hintText: "Wallet Address",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Wallet Address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text(
                "Bank",
                style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),
              ),
              SizedBox(height: 7),
              DropdownButtonFormField<String>(
                value: bankType,
                isExpanded: true,
                style: NewStyle.tx28White.copyWith(fontSize: 12),
                hint: Text(
                  banks.length != 0 ? "Select Bank" : "You should add personal bank information.",
                  style: NewStyle.tx28White.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: NewColor.txGrayColor),),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(
                    color: Colors.grey, // Set the hint text color here
                    fontSize: 12,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: NewColor.dashboardPrimaryColor, // Background color
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x33D1D1D1),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x33D1D1D1),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0x33D1D1D1),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Color(0xFF646565),
                ),
                dropdownColor: NewColor.dashboardPrimaryColor,
                items: banks.map<DropdownMenuItem<String>>((Map<String, dynamic> bank) {
                  return DropdownMenuItem(
                      value: bank['bank_id'],
                      child: Text(
                        bank['bank_name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: NewStyle.tx28White.copyWith(fontSize: 12),
                      ));
                }).toList(),
                onChanged: (String? value) async {
                  setState(() {
                    bankType = value!;
                  });
                },
              ),
              SizedBox(height: 59),
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
                      "Note:",
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
                          child: Text(
                              "Bank Transfer remark such as PM, crypto, BTC , or USDT or anything indicating crypto is Not allowed.",
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
                              "Bank Transfer remark such as PM, crypto, BTC , or USDT or anything indicating crypto is Not allowed.",
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
                              "Do not use our service to fund a 3rd party account to prevent loss of funds ",
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
                              "Exchange orders are funded within our working hours, which are from Monday to Saturday, 8:00AM to 10:00PM +1GMT",
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
                              "Please double check your receiving address/account, we are not liable for any loss due to incorrect address/account specifiations",
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
                              "Please chat us via what’sapp +2349035899595 for more clarification if needed",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 10,
                                  height: 2,
                                  fontWeight: FontWeight.w400,
                                  color: NewColor.splashContentWhiteColor)),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 59),
              isLoading == true
                  ? const Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  ))
                  : SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => banks.length != 0 ? {
                    if (_formKey.currentState?.validate() ?? false)
                      createBuyOrder()
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
        ),)
      ),
    );
  }
}
