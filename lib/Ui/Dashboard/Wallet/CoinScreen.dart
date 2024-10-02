import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/HistoryScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/AddAssetsScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/BuyCoin/BuyCoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ReceiveToken/ReceiveTokenList.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SellCoin/SellCoinScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenList.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WalletScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WithdrawToken/WithDrawTokenList.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CoinDetailScreen.dart';
import 'ExchangeCoin/ExchangeScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dotted_border/dotted_border.dart';
import 'CarouselWithLineNavigation.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  List<Map<String, dynamic>> data = [
    {
      "type": "receive",
      "risk": "low",
    },
    {
      "type": "receive",
      "risk": "high",
    },
    {
      "type": "send",
      "risk": "high",
    },
    {
      "type": "send",
      "risk": "high",
    },
    {
      "type": "send",
      "risk": "low",
    },
    {
      "type": "receive",
      "risk": "high",
    },
    {
      "type": "receive",
      "risk": "high",
    },
    {
      "type": "receive",
      "risk": "high",
    },
    {
      "type": "send",
      "risk": "high",
    },
    {
      "type": "send",
      "risk": "high",
    },
    {
      "type": "send",
      "risk": "high",
    },
    {
      "type": "receive",
      "risk": "low",
    },
  ];
  showAddAsserts(BuildContext context, selectedAccountId) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 2,
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: AddAssetsScreen(selectedAccountId: selectedAccountId));
      },
    ).whenComplete(() async {
      getToken();
      socket!.destroy();
      socket!.dispose();
      setState(() {});
      getSocketData();
    });
  }

  showSendTokenList(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 2,
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: const SendTokenList());
      },
    ).whenComplete(() {
      socket!.destroy();
      socket!.dispose();
      setState(() {});
      getSocketData();
    });
  }

  showReceiveTokenList(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 2,
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: const ReceiveTokenList());
      },
    ).whenComplete(() {
      socket!.destroy();
      socket!.dispose();
      setState(() {});
      getSocketData();
    });
  }

  showWithdrawTokenList(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: MyColor.darkGreyColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 2,
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: const WithDrawTokenList());
      },
    ).whenComplete(() {
      socket!.destroy();
      socket!.dispose();
      setState(() {});
      getSocketData();
    });
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
    socket!.disconnect();
    socket!.destroy();
    socket!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // backgroundColor: NewColor.dashboardPrimaryColor,

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: NewColor.dashboardPrimaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DashboardScreen();
                          }));
                          // Handle button press
                        },
                        child: Image.asset(
                          "assets/images/arrow_left.png",
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        )),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: "\$0.13 ",
                          style: NewStyle.tx28White.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: NewColor.splashContentWhiteColor)),
                      TextSpan(
                          text: "(1.63)",
                          style: NewStyle.tx28White.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF017F04))),
                    ])),
                  ],
                ),
                const SizedBox(height: 29),
                Text("USDT",
                    style: NewStyle.tx28White.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: NewColor.splashContentWhiteColor)),
                const SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: (width - 90) / 2,
                        decoration: BoxDecoration(
                          color: Color(0xFF16191E),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.fromLTRB(39, 20, 39, 20),
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              height: 22,
                              width: 22,
                              fit: BoxFit.fill,
                              imageUrl:
                                  "https://smanager.instantexchangers.net/assets/media/uploads/coin_logos/1711733661_c5ff428177b78a7fa50b.png",
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: NewColor.btnBgGreenColor),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 22,
                                width: 22,
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
                            SizedBox(height: 10),
                            Text("1.27 USD",
                                style: NewStyle.tx28White.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: NewColor.splashContentWhiteColor,
                                )),
                            Text("10.0 USDT",
                                style: NewStyle.tx28White.copyWith(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: NewColor.txGrayColor,
                                )),
                          ],
                        )),
                    Container(
                      width: (width - 90) / 2,
                      decoration: BoxDecoration(
                        color: Color(0xFF16191E),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.fromLTRB(39, 8, 39, 8),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              const AnimatedRadialGauge(
                                duration: Duration(seconds: 1),
                                curve: Curves.elasticOut,
                                radius: 50,
                                value: 20,
                                axis: GaugeAxis(
                                  min: 0,
                                  max: 100,
                                  degrees: 200,
                                  style: GaugeAxisStyle(
                                    thickness: 4,
                                    background: Colors.transparent,
                                    segmentSpacing: 5,
                                  ),
                                  pointer: null,
                                  progressBar: GaugeProgressBar.rounded(
                                    color: Colors.transparent,
                                  ),
                                  segments: [
                                    GaugeSegment(
                                      from: 0,
                                      to: 45,
                                      color: Color(0xFF017F04),
                                      cornerRadius: Radius.circular(8),
                                    ),
                                    GaugeSegment(
                                      from: 45,
                                      to: 70,
                                      color: Color(0xFFA73E03),
                                      cornerRadius: Radius.circular(8),
                                    ),
                                    GaugeSegment(
                                      from: 70,
                                      to: 85,
                                      color: Color(0xFFFFE606),
                                      cornerRadius: Radius.circular(8),
                                    ),
                                    GaugeSegment(
                                      from: 85,
                                      to: 100,
                                      color: Color(0xFFDE2323),
                                      cornerRadius: Radius.circular(8),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 30.0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text("25%",
                                          style: NewStyle.tx28White.copyWith(
                                            fontSize: 16,
                                            color: NewColor.mainWhiteColor,
                                          )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Text("Low Risk",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: Color(0xFF72B703),
                              )),
                          SizedBox(height: 1.4),
                          Text("Last Check on 21 Apr",
                              style: NewStyle.tx28White.copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                                color: NewColor.txGrayColor,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReceiveScreen(
                                      networkId: 1,
                                      tokenName: "Bitcoin",
                                      tokenSymbol: "BTC",
                                      tokenImage:
                                          "https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png",
                                      tokenType: "",
                                    )));
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
                              "assets/images/dashboard/receive.png",
                              height: 19,
                              width: 19,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Receive",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.splashContentWhiteColor),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BuyCoinScreen()));
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
                              "assets/images/dashboard/buy.png",
                              height: 19,
                              width: 19,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Buy",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.splashContentWhiteColor),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SellCoinScreen()));
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
                              "assets/images/dashboard/sell.png",
                              height: 19,
                              width: 19,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Sell",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.splashContentWhiteColor),
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
                            height: 41,
                            width: 41,
                            // padding: const EdgeInsets.all(13),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Color(0xFF16191E),
                                shape: BoxShape.circle),
                            child: Image.asset(
                              "assets/images/dashboard/history.png",
                              height: 19,
                              width: 19,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "History",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: NewColor.splashContentWhiteColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14)
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
              onRefresh: isCalculating == true ? doNothing : doNothing,
              refreshing: false,
              child: ListView.builder(
                itemCount: data.length,
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
                itemBuilder: (context, index) {
                  var list = data[index];
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Row(
                          children: [
                            // coin token
                            ClipRRect(
                                // borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                              list['type'] == "receive"
                                  ? "assets/images/receive_circle.png"
                                  : "assets/images/send_circle.png",
                              fit: BoxFit.cover,
                            )),

                            const SizedBox(width: 8),

                            // coin name and price and 24h
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  list['type'] == "receive"
                                      ? "Deposit"
                                      : "Withdraw",
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: NewColor.splashContentWhiteColor),
                                ),
                                const SizedBox(height: 4),
                                Text("From:TYDNDBD....JHGq",
                                    style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: NewColor.txGrayColor,
                                    )),
                              ],
                            )),
                            // const SizedBox(width: 10),

                            // balance and coin price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "+ 0.0009 USDT",
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF017F04)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "\$ 0.083547",
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      color: NewColor.txGrayColor,
                                      fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  list['risk'] == "low"
                                      ? "Low risk wallet"
                                      : "High risk wallet",
                                  style: NewStyle.tx28White.copyWith(
                                      fontSize: 12,
                                      color: list['risk'] == "low"
                                          ? Color(0xFF72B703)
                                          : Color(0xFFB76103),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // SizedBox(height: 33),
                    ],
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
