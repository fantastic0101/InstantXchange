import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/AlarmScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/HistoryScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/AddAssetsScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/BuyCoin/BuyCoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveTokenList.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SellCoin/SellCoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenList.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WithdrawToken/WithDrawTokenList.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'CoinDetailScreen.dart';
import 'ExchangeCoin/ExchangeScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dotted_border/dotted_border.dart';
import 'CarouselWithLineNavigation.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> recentData = [];
  double totalBalance = 0.0;
  Map<String, dynamic> profile = {};

  Future<void> getWalletData() async {
    setState(() {
      _showRefresh = true;
    });
    try {
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
        info.sort((a, b) => b['naira_price'].compareTo(a['naira_price']));
        if(mounted) {
          setState(() {
            data = info;
            _showRefresh = false;
          });
        }
      } else {
        if(response.statusCode == 301) {
          final redirectedResponse = await http.post(
            Uri.parse(response.headers['location']!),
              headers: {
                'Authorization': 'Bearer ${token}'
              },
              body: {
                'type': 'buy'
              }
          );

          Map<String, dynamic> res= await jsonDecode(redirectedResponse.body);
          List<dynamic> result = res['coins'];
          List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
          info.sort((a, b) => b['naira_price'].compareTo(a['naira_price']));
          if(mounted) {
            setState(() {
              data = info;
              _showRefresh = false;
            });
          }
        }
        else {
          setState(() {
          _showRefresh = false;
          });
          // If the server did not return a 200 OK response, throw an exception.
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      }

      setState(() {
        _showRefresh = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";

  bool isCalculating = false;
  bool isLoaded = false;

  @override
  void initState() {
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    super.initState();
    selectedAccount();
    getWalletData();
    getProfileInfo();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _showVerifyDialog(BuildContext context) async {
    if(profile['verified'] == '0'){
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                decoration: BoxDecoration(
                    color: MyColor.backgroundColor,
                    border: Border.all(
                      color: MyColor.darkGreyColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(6.0)
                ),
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Verification Notice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NewColor.mainWhiteColor)),
                    SizedBox(height: 12.0),
                    Text('To access the buying feature, you need to complete the verification process.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewColor.txGrayColor)),
                    SizedBox(height: 16.0),
                    Image.asset(
                      "assets/images/verify.png",
                      height: 120,
                      width: 120,
                    ),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Verify Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColor.blueColor)),
                    ),
                    SizedBox(height: 12.0),
                    Text('Tap "Verify Account" to go to the website. Log in, complete verification, and chat with support to speed up approval. Once approved, return to the app and tap "Update Verification" to refresh your status.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewColor.mainWhiteColor)),
                    SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColor.greenColor)),
                    ),
                    SizedBox(height: 12.0),
                    Text("Once you've finished verification, tap the button below to update your status and gain access to buy feature.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NewColor.mainWhiteColor)),
                    SizedBox(height: 24.0),
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: TextButton(
                              onPressed: () => {
                                _launchURL(Utils.verifyUrl)
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: MyColor.blueColor,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              child: Text(
                                "Verify Account",
                                style: NewStyle.btnTx16SplashBlue
                                    .copyWith(fontSize: 14, color: NewColor.mainWhiteColor),
                              ),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            width: 130,
                            child: TextButton(
                              onPressed: () async {
                                await updateProfileInfo();
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: MyColor.greenColor,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              child: Text(
                                "Update Status",
                                style: NewStyle.btnTx16SplashBlue
                                    .copyWith(fontSize: 14, color: NewColor.mainWhiteColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
            ),
          );
        },
      );
    }
  }

  getProfileInfo() async {
    final String url = 'https://instantexchangers.com/mobile_server/get-user-profile';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${token}',
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        if(mounted) {
          setState(() {
            profile = res['user'];
          });
        }
      } else {
      }
    } catch (e) {
      print(e);
    }
  }

  updateProfileInfo() async {
    final String url = 'https://instantexchangers.com/mobile_server/get-user-profile';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      http.Response response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${token}',
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        if(mounted) {
          setState(() {
            profile = res['user'];
          });
          if(res['user']['verified'] == "1") {
            Fluttertoast.showToast(
                msg: "Your account is verified",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          else {
            Fluttertoast.showToast(
                msg: "Your account is not verified",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        }
      } else {
      }
    } catch (e) {
      print(e);
    }
  }

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
          'type': 'all',
          'status': 'completed'
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> res= await jsonDecode(response.body);
        List<dynamic> result = res['transactions'];
        List<Map<String, dynamic>> info = result.map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          recentData = info;
        });
      } else {
      }
    } catch (e) {
      print(e);
    }
  }

  double showTotalValue = 0.0;
  var trxPrivateKey = "";

  // get selected account
  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      isLoaded = false;
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      selectedAccountAddress =
          sharedPreferences.getString('accountAddress') ?? "";
      selectedAccountPrivateAddress =
          sharedPreferences.getString('accountPrivateAddress') ?? "";
      showTotalValue = sharedPreferences.getDouble('myBalance') ?? 0.00;
    });

    // print("object selectedAccountId ${selectedAccountId}");

    if (selectedAccountId == "") {
      setState(() {
        selectedAccountId =
            DBAccountProvider.dbAccountProvider.newAccountList[0].id;
        selectedAccountName =
            DBAccountProvider.dbAccountProvider.newAccountList[0].name;

        sharedPreferences.setString('accountId', selectedAccountId);
        sharedPreferences.setString('accountName', selectedAccountName);
      });
    }

    await DbAccountAddress.dbAccountAddress
        .getAccountAddress(selectedAccountId);
    await DbNetwork.dbNetwork.getNetwork();

    for (int i = 0;
        i < DbAccountAddress.dbAccountAddress.allAccountAddress.length;
        i++) {
      if (DbAccountAddress
              .dbAccountAddress.allAccountAddress[i].publicKeyName ==
          "address") {
        if (mounted) {
          setState(() {
            selectedAccountAddress = DbAccountAddress
                .dbAccountAddress.allAccountAddress[i].publicAddress;
            selectedAccountPrivateAddress = DbAccountAddress
                .dbAccountAddress.allAccountAddress[i].privateAddress;
            sharedPreferences.setString(
                'accountAddress', selectedAccountAddress);
            sharedPreferences.setString(
                'accountPrivateAddress', selectedAccountPrivateAddress);
          });
        }
      }
    }

    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, 9);

    if (mounted) {
      setState(() {
        trxPrivateKey =
            DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
      });

      getToken();
    }
  }

  bool _showRefresh = false, isNeeded = false;

  //cry lawn discover subway captain rib claw spice sure frequent struggle yellow
  // getToken for coin market cap
  getToken() async {
    if (isNeeded == true) {
      await DbAccountAddress.dbAccountAddress
          .getAccountAddress(selectedAccountId);

      var data = {};

      for (int j = 0;
          j < DbAccountAddress.dbAccountAddress.allAccountAddress.length;
          j++) {
        data[DbAccountAddress
                .dbAccountAddress.allAccountAddress[j].publicKeyName] =
            DbAccountAddress
                .dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      // print(jsonEncode(data));

      await tokenProvider.getAccountToken(
          data, '/getAccountTokens', selectedAccountId);

      if (mounted) {
        setState(() {
          isNeeded = false;
        });
      }
    } else {
      await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
      setState(() {});
    }

    getSocketData();

    if (mounted) {
      setState(() {
        _showRefresh = false;
        isLoaded = true;
      });
    }
  }

  IO.Socket? socket;

  // socket for get updated balance
  getSocketData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    // print("deviceId ----> $deviceId");
    socket = IO.io('https://https://instantexchangers.com/mobile_server/', <String, dynamic>{
      "secure": true,
      "path": "/api/socket.io",
      "rejectUnauthorized": false,
      "transports": ["websocket", "polling"],
      "upgrade": false,
      "query": {"deviceId": deviceId}
    });

    socket!.connect();

    socket!.onConnect((_) {
      socket!.on("getTokenBalance", (response) async {
        // print("response ----> $response");
        if (mounted) {
          if (response["status"] == true) {
            if (response["data"]["balance"] != "null") {
              await DBTokenProvider.dbTokenProvider.updateTokenBalance(
                '${response["data"]["balance"]}',
                '${response["data"]["id"]}',
              );
            }
          }

          // print("Socket ac id $selectedAccountId");

          await DBTokenProvider.dbTokenProvider
              .getAccountToken(selectedAccountId);
          if (mounted) {
            setState(() {});
          }
          getAccountTotal();
        }
      });
    });

    for (int i = 0; i < DBTokenProvider.dbTokenProvider.tokenList.length; i++) {
      List<NetworkList> networkList = DbNetwork.dbNetwork.networkList
          .where((element) =>
              element.id ==
              DBTokenProvider.dbTokenProvider.tokenList[i].networkId)
          .toList();
      var data = {
        "id": "${DBTokenProvider.dbTokenProvider.tokenList[i].id}",
        "network_id":
            "${DBTokenProvider.dbTokenProvider.tokenList[i].networkId}",
        "tokenAddress": DBTokenProvider.dbTokenProvider.tokenList[i].address,
        "address": DBTokenProvider.dbTokenProvider.tokenList[i].accAddress,
        "trxPrivateKey": trxPrivateKey,
        "isCustomeRPC": false,
        "network_url": networkList.isEmpty ? "" : networkList.first.url,
      };

      // print("socket emit ==>  ${jsonEncode(data)}");
      socket!.emit("getTokenBalance", jsonEncode(data));
    }
  }

  bool updatingValue = false;
  double updatingTotalValue = 0.00;

  // Calculate all amount
  getAccountTotal() async {
    if (mounted) {
      setState(() {
        showTotalValue = 0.0;
      });
    }

    double valueUsd = 0.0;

    for (int i = 0; i < DBTokenProvider.dbTokenProvider.tokenList.length; i++) {
      // print("${DBTokenProvider.dbTokenProvider.tokenList[i].name} balance:- ${DBTokenProvider.dbTokenProvider.tokenList[i].balance} price:- ${DBTokenProvider.dbTokenProvider.tokenList[i].price}");

      if (DBTokenProvider.dbTokenProvider.tokenList[i].balance == "" ||
          DBTokenProvider.dbTokenProvider.tokenList[i].balance == "0" ||
          DBTokenProvider.dbTokenProvider.tokenList[i].price == 0.0) {
        valueUsd += 0;
      } else {
        valueUsd +=
            double.parse(DBTokenProvider.dbTokenProvider.tokenList[i].balance) *
                DBTokenProvider.dbTokenProvider.tokenList[i].price;
      }
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        showTotalValue = valueUsd;
        sharedPreferences.setDouble("myBalance", showTotalValue);
        updatingValue = false;
      });
    }
    // print("show Total Value === > $showTotalValue");
  }

  Future<void> _getData() async {
    setState(() {
      updatingValue = false;
    });

    socket!.close();
    socket!.destroy();
    socket!.dispose();

    if (DBTokenProvider.dbTokenProvider.tokenList.isNotEmpty) {
      setState(() {
        updatingValue = true;
        updatingTotalValue = showTotalValue;
      });
    }

    setState(() {
      _showRefresh = true;
      isNeeded = true;
      getToken();
    });
  }

  doNothing() {}

  @override
  void dispose() {
    // socket!.disconnect();
    // socket!.destroy();
    // socket!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    return Scaffold(
      // backgroundColor: NewColor.dashboardPrimaryColor,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 68),
            decoration: const BoxDecoration(
              color: NewColor.dashboardPrimaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AlarmScreen()));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 41,
                            width: 41,
                            // padding: const EdgeInsets.all(13),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Color(0xFF16191E),
                                shape: BoxShape.circle),
                            child: Image.asset(
                              "assets/images/dashboard/notification.png",
                              height: 19,
                              width: 19,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Visibility(child: CarouselWithLineNavigation()),
          Padding(
            padding:
                const EdgeInsets.only(top: 22, bottom: 22, left: 24, right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    profile['verified'] == "1" ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BuyCoinScreen())) :
                        _showVerifyDialog(context);

                    // Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => BuyCoinScreen()));
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 76,
                        width: 105,
                        // padding: const EdgeInsets.all(13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: NewColor.dashboardPrimaryColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            Image.asset(
                              "assets/images/dashboard/receive.png",
                              height: 19,
                              width: 19,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Buy",
                              style: MyStyle.tx18RWhite
                                  .copyWith(fontSize: 12, color: MyColor.whiteColor),
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    // profile['verified'] == 1 ? Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => SellCoinScreen())) :
                    //     _showVerifyDialog(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SellCoinScreen()));
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 76,
                        width: 105,
                        // padding: const EdgeInsets.all(13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: NewColor.dashboardPrimaryColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            Image.asset(
                              "assets/images/dashboard/send.png",
                              height: 19,
                              width: 19,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Sell",
                              style: MyStyle.tx18RWhite
                                  .copyWith(fontSize: 12, color: MyColor.whiteColor),
                            ),
                          ],
                        )
                      ),

                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()));
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 76,
                        width: 105,
                        // padding: const EdgeInsets.all(13),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: NewColor.dashboardPrimaryColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            Image.asset(
                              "assets/images/dashboard/history.png",
                              height: 19,
                              width: 19,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "History",
                              style: MyStyle.tx18RWhite
                                  .copyWith(fontSize: 12, color: MyColor.whiteColor),
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // coin list
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
            decoration: const BoxDecoration(
              color: MyColor.backgroundColor,
            ),
            child: DeclarativeRefreshIndicator(
              color: MyColor.greenColor,
              backgroundColor: MyColor.mainWhiteColor,
              onRefresh: getWalletData,
              refreshing: _showRefresh,
              child: ListView.builder(
                itemCount: data.length,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 30),
                itemBuilder: (context, index) {
                  var list = data[index];
                  return InkWell(
                    onTap: () async {
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 22),
                          child: Row(
                            children: [
                              // coin token
                              ClipRRect(
                                // borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.fill,
                                  imageUrl: list['coin_image'],
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                        color: MyColor.greenColor),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 30,
                                    width: 30,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: MyColor.whiteColor,
                                    ),
                                    child: Image.asset(
                                      "assets/images/bitcoin.png",
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // coin name and price and 24h
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    list['coin_name'],
                                    style: NewStyle.tx28White.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      text: list['coin_code'],
                                      style: NewStyle.tx28White.copyWith(
                                          fontSize: 12,
                                          color: NewColor.txGrayColor,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ])),
                                ],
                              )),
                              // const SizedBox(width: 10),

                              // balance and coin price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isCalculating == true
                                        ? "--"
                                        : "\$ ${NumberFormat('#,###.##').format(double.parse(list['usd_price']))}",
                                    style: NewStyle.tx28White.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "\ ${NumberFormat('#,###.##').format(list['naira_price'])} NGN",
                                    style: NewStyle.tx28White.copyWith(
                                        fontSize: 12,
                                        color: NewColor.txGrayColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(0),
                          color: Color(0x24D1D1D1),
                          strokeWidth: 0.01,
                          dashPattern: [
                            6,
                            3
                          ], // Dash pattern [dashLength, gapLength]
                          child: Container(
                            height: 0.4, // Height of the dashed border
                            decoration: BoxDecoration(
                              color: Color(0x24D1D1D1),
                            ),
                          ),
                        ),
                        SizedBox(height: 33),
                      ],
                    ),
                  );
                },
              ),
            ),
          ))
        ],
      ),
    );
  }
}
