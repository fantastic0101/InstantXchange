import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WalletConnect/WalletConnectScreen.dart';
import 'WalletsPages/WalletsListingScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jost_pay_wallet/Values/utils.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  String selectedAccountName = "";
  TextEditingController bankController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  late List<Map<String, dynamic>> banks = [];
  late List<Map<String, dynamic>> data = [];
  String? bankType;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  getWalletName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });
  }

  getUserBanks() async {
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
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['banks'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        return info;
      } else {
        if(response.statusCode == 301)
          {
            final redirectedResponse = await http.post(
              Uri.parse(response.headers['location']!),
              headers: {
                'Authorization': 'Bearer ${token}',
              },
            );
          }
      }
    } catch (e) {
    }
  }

  getBanks() async {
    setState(() {
      isLoading = true;
    });
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
          'type': 'sell'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['banks'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        print(info);
        if(mounted) {
          setState(() {
            banks = info;
            bankType = banks[0]['bank_id'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
    }
  }

  addNewBank() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    final String url = 'https://instantexchangers.com/mobile_server/add-user-bank';

    final Map<String, dynamic> body = {
      'bank_id': bankType,
      'account_number': accountNumberController.text,
      'account_name': accountNameController.text
    };

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': "Bearer ${token}"
        },
        body: {
          'bank_id': bankType,
          'account_number': accountNumberController.text,
          'account_name': accountNameController.text
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "New bank account added successfully.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else {
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getWalletName();
    getBanks();
  }

  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey, child: Scaffold(
      body: isLoading ?
      Align(
        alignment: Alignment.center,
        child: const Center(
            child: CircularProgressIndicator(
              color: MyColor.greenColor,
            )),
      ) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 68),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(width: MediaQuery.of(context).size.width / 2 - 92),
                  Text(
                    "Add Bank",
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
                  Text(
                    "Bank",
                    style: NewStyle.tx14SplashWhite.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 2,
                        color: NewColor.txGrayColor),
                  ),
                  SizedBox(height: 3),
                  DropdownButtonFormField<String>(
                    value: bankType,
                    isExpanded: true,
                    style: NewStyle.tx28White.copyWith(fontSize: 12),
                    hint: Text("Select Bank",
                      style: NewStyle.tx28White.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: NewColor.txGrayColor),),
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: NewColor.dashboardPrimaryColor,
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
                  SizedBox(height: 14),
                  Text(
                    "Bank account number",
                    style: NewStyle.tx14SplashWhite.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 2,
                        color: NewColor.txGrayColor),
                  ),
                  SizedBox(height: 3),
                  TextFormField(
                    controller: accountNumberController,
                    cursorColor: NewColor.btnBgGreenColor,
                    style: NewStyle.tx28White.copyWith(fontSize: 12),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: NewStyle.searchInputDecoration.copyWith(
                      hintText: "Enter account number",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a number';
                      }
                      final number = int.tryParse(value);
                      if (number == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Bank account name",
                    style: NewStyle.tx14SplashWhite.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 2,
                        color: NewColor.txGrayColor),
                  ),
                  SizedBox(height: 3),
                  TextFormField(
                    controller: accountNameController,
                    cursorColor: NewColor.btnBgGreenColor,
                    style: NewStyle.tx28White.copyWith(fontSize: 12),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: NewStyle.searchInputDecoration.copyWith(
                      hintText: "Enter account name",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please input account name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 72) / 2,
                        child: TextButton(
                          onPressed: () => (Navigator.pop(context)),
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
                            "Cancel",
                            style: NewStyle.btnTx16SplashBlue
                                .copyWith(color: NewColor.mainWhiteColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 72) / 2,
                        child: TextButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              addNewBank();
                              Navigator.pop(context, getUserBanks());
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
                            "Add",
                            style: NewStyle.btnTx16SplashBlue
                                .copyWith(color: NewColor.mainWhiteColor),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
