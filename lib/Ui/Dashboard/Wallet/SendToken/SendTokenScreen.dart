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
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/SendTokenConfirmScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/NewStyle.dart';
import 'package:jost_pay_wallet/Values/NewColor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'QrScannerPage.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class SendTokenScreen extends StatefulWidget {
  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      selectTokenMarketId = "",
      tokenUpDown = "",
      sendTokenImage = "",
      selectTokenUSD = "",
      sendTokenBalance = "",
      sendTokenId = "",
      explorerUrl = "",
      sendTokenUsd = "",
      accAddress = "",
      pageName = "",
      sendTokenType = "";
  int sendTokenDecimals;

  SendTokenScreen({
    super.key,
    required this.sendTokenAddress,
    required this.sendTokenNetworkId,
    required this.sendTokenName,
    required this.sendTokenSymbol,
    required this.selectTokenMarketId,
    required this.tokenUpDown,
    required this.sendTokenImage,
    required this.sendTokenBalance,
    required this.selectTokenUSD,
    required this.sendTokenId,
    required this.explorerUrl,
    required this.sendTokenType,
    required this.sendTokenUsd,
    required this.sendTokenDecimals,
    required this.pageName,
    required this.accAddress,
  });

  @override
  State<SendTokenScreen> createState() => _SendTokenScreenState();
}

class _SendTokenScreenState extends State<SendTokenScreen> {
  TextEditingController toController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();
  List<NetworkList> networkList = [];
  bool isLoaded = false, checkBox = false;
  String _response = "";
  String _network = "";

  final List<String> tokenTypes = ["ETH", "BNB", "MATIC", "BTC", "TRX", "DOGE", "LTC", "USDT(BEP20)", "USDT(TRC20)"];
  String? selectedToken;

  late String deviceId;
  String selectedAccountId = "",
      selectedAccountName = "",
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";

  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      selectTokenMarketId = "",
      sendTokenType = "",
      sendTokenImage = "",
      tokenUpDown = "",
      selectTokenUSD = "",
      explorerUrl = "",
      sendTokenBalance = "0",
      sendTokenId = "",
      sendTokenUsd = "0",
      tokenType = "";
  int sendTokenDecimals = 0;

  String networkSymbol = "";
  int? isTxfees;

  TextEditingController fromAddressController = TextEditingController();
  TextEditingController sendTokenQuantity = TextEditingController();

  // getNetworkFees() async {
  //   final String url = 'http://https://instantexchangers.com/mobile_server/api/transaction/tokenNetworkIds';
  //   final Map<String, dynamic> body = {
  //     'networkName': selectedToken
  //   };
  //
  //   try {
  //     http.Response response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 201) {
  //       setState(() {
  //         _response = 'Response: ${response.body}';
  //         print(_response);
  //       });
  //     } else {
  //       setState(() {
  //         _response = 'Error: ${response.statusCode} ${response.reasonPhrase}';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _response = 'Exception: $e';
  //     });
  //   }
  // }

  getNetworkFullName() async {
    switch(selectedToken) {
      case "ETH":
        return "Ethereum";
      case "BNB":
        return "Binance Smart Chain";
      case "MATIC":
        return "Polygon";
      case "BTC":
        return "Bitcoin";
      case "TRX":
        return "Tron";
      case "DOGE":
        return "Dogecoin";
      case "LTC":
        return "Litecoin";
      case "USDT(BEP20)":
        return "USDT(BEP20)";
      case "USDT(TRC20)":
        return "USDT(TRC20)";
      default:
        return "";
    }
  }

  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isLoaded = false;
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    });

    await DbAccountAddress.dbAccountAddress
        .getAccountAddress(selectedAccountId);
    await DbNetwork.dbNetwork.getNetwork();

    setState(() {
      sendTokenName = widget.sendTokenName;
      sendTokenAddress = widget.sendTokenAddress;
      sendTokenNetworkId = widget.sendTokenNetworkId;
      sendTokenSymbol = widget.sendTokenSymbol;
      selectTokenMarketId = widget.selectTokenMarketId;
      sendTokenImage = widget.sendTokenImage;
      tokenUpDown = widget.tokenUpDown;
      sendTokenBalance = widget.sendTokenBalance;
      sendTokenId = widget.sendTokenId;
      sendTokenType = widget.sendTokenType;
      sendTokenUsd = widget.sendTokenUsd;
      explorerUrl = widget.explorerUrl;
      selectTokenUSD = widget.selectTokenUSD;
      sendTokenDecimals = widget.sendTokenDecimals;
    });

    await DbAccountAddress.dbAccountAddress
        .getPublicKey(selectedAccountId, sendTokenNetworkId);

    setState(() {
      selectedAccountAddress =
          DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress =
          DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
    });

    networkList = DbNetwork.dbNetwork.networkList
        .where((element) => "${element.id}" == sendTokenNetworkId)
        .toList();

    setState(() {
      networkSymbol = networkList[0].symbol;
      isTxfees = networkList[0].isTxfees;
      fromAddressController =
          TextEditingController(text: selectedAccountAddress);
    });
  }

  late TransectionProvider transectionProvider;
  late TokenProvider tokenProvider;
  bool isLoading = false;

  @override
  void initState() {
    transectionProvider =
        Provider.of<TransectionProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    super.initState();
    selectedAccount();
  }

  String sendGasPrice = "";
  String sendGas = "";
  String? sendNonce = "";
  String sendTransactionFee = "0";
  double totalUsd = 0.0;
  double totalSendValue = 0.0;

  getNetworkFees() async {
    setState(() {
      isLoading = true;
    });

    var data = {
      "network_id": sendTokenNetworkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": toController.text,
      "token_id": sendTokenId,
      "value": sendTokenQuantity.text,
      "gasPrice": "",
      "gas": "",
      "nonce": 0,
      "isCustomeRPC": false,
      "network_url": networkList.first.url,
      "tokenAddress": sendTokenAddress,
      "decimals": sendTokenDecimals
    };

    // print(json.encode(data));

    await transectionProvider.getNetworkFees(data, '/getNetrowkFees', context);

    if (transectionProvider.isSuccess == true) {
      var body = transectionProvider.networkData;

      setState(() {
        isLoading = false;

        sendGasPrice = "${body['gasPrice']}";
        sendGas = "${body['gas']}";
        sendNonce = "${body['nonce']}";
        sendTransactionFee = "${body['transactionFee']}";

        double networkUsd = 0.0, tokenUsd = 0.0;

        tokenUsd = double.parse(sendTokenQuantity.text) *
            double.parse(widget.sendTokenUsd);
        networkUsd = double.parse(sendTransactionFee) *
            double.parse(widget.sendTokenUsd);

        var tokenPrice = DBTokenProvider.dbTokenProvider.tokenList
            .where((element) {
              return "${element.networkId}" == sendTokenNetworkId &&
                  element.type == "";
            })
            .first
            .price;

        if (sendTokenAddress != "") {
          totalSendValue = double.parse(sendTokenQuantity.text);
          totalUsd = tokenUsd + double.parse(sendTransactionFee) * tokenPrice;
        } else {
          totalSendValue = double.parse(sendTokenQuantity.text) +
              double.parse(sendTransactionFee);
          totalUsd = tokenUsd + networkUsd;
        }
      });

      // ignore: use_build_context_synchronously
      confirmBottomSheet(context);
    } else {
      var data = DbNetwork.dbNetwork.networkList
          .where((element) => "${element.id}" == sendTokenNetworkId)
          .toList();

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context,
          "Insufficient ${data[0].symbol} balance please deposit some ${data[0].symbol}");
      setState(() {
        isLoading = false;
      });
    }
  }

  confirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: MyColor.backgroundColor,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        builder: (context) {
          List<AccountTokenList> tokenBalance =
              DBTokenProvider.dbTokenProvider.tokenList.where((element) {
            return "${element.networkId}" == sendTokenNetworkId &&
                element.type == "";
          }).toList();
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // print("object $sendTransactionFee");
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // dos icon
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColor.lightGreyColor),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 10),
                    child: Text("Asset", style: MyStyle.tx18BWhite),
                  ),

                  Container(
                    decoration: BoxDecoration(
                        color: MyColor.darkGrey01Color,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: CachedNetworkImage(
                              width: 40,
                              height: 40,
                              fit: BoxFit.fill,
                              imageUrl: sendTokenImage,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: MyColor.greenColor),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                  "assets/images/bitcoin.png",
                                  width: 40,
                                  height: 40),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                Text(sendTokenName, style: MyStyle.tx18BWhite),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                        color: MyColor.darkGrey01Color,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("From address",
                                style:
                                    MyStyle.tx18BWhite.copyWith(fontSize: 16)),
                          ),
                          const SizedBox(height: 7),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              fromAddressController.text,
                              style: MyStyle.tx18RWhite.copyWith(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("To address",
                                style:
                                    MyStyle.tx18BWhite.copyWith(fontSize: 16)),
                          ),
                          const SizedBox(height: 7),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              toController.text,
                              style: MyStyle.tx18RWhite.copyWith(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("Token quantity",
                                style:
                                    MyStyle.tx18BWhite.copyWith(fontSize: 14)),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${ApiHandler.showFiveBalance(sendTokenQuantity.text)} $sendTokenSymbol',
                                    style: MyStyle.tx18BWhite
                                        .copyWith(fontSize: 14),
                                  ),
                                ),
                                Text(
                                    double.parse(
                                            "${double.parse(sendTokenQuantity.text) * double.parse(sendTokenUsd)}")
                                        .toStringAsFixed(3),
                                    style: MyStyle.tx18RWhite
                                        .copyWith(fontSize: 14)),
                                Text(" USD",
                                    style: MyStyle.tx18RWhite
                                        .copyWith(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                        color: MyColor.darkGrey01Color,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Network Fee",
                                  style: MyStyle.tx18BWhite
                                      .copyWith(fontSize: 14)),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                      "${ApiHandler.showFiveBalance(sendTransactionFee)} $networkSymbol (~\$ ${(double.parse(sendTransactionFee) * tokenBalance[0].price).toStringAsFixed(3)})",
                                      textAlign: TextAlign.end,
                                      style: MyStyle.tx18RWhite
                                          .copyWith(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text("Max total",
                                    style: MyStyle.tx18BWhite
                                        .copyWith(fontSize: 14)),
                              ),
                              Text('\$ ${totalUsd.toStringAsFixed(3)} USD',
                                  style: MyStyle.tx18RWhite
                                      .copyWith(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor:
                              MyColor.greenColor.withOpacity(0.5),
                        ),
                        child: Checkbox(
                          checkColor: MyColor.whiteColor,
                          activeColor: MyColor.greenColor,
                          value: checkBox,
                          onChanged: (value) {
                            setState(() {
                              checkBox = value!;
                            });
                          },
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "I understand all the risk",
                            style: MyStyle.tx18RWhite.copyWith(fontSize: 14),
                          ),
                          Row(
                            children: [
                              Text(
                                "I agree to the",
                                style:
                                    MyStyle.tx18RWhite.copyWith(fontSize: 14),
                              ),
                              Text(
                                "Terms and Conditions",
                                style:
                                    MyStyle.tx18RWhite.copyWith(fontSize: 14),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  isLoading == true
                      ? Helper.dialogCall.showLoader()
                      : checkBox == false ||
                              (sendTokenAddress == "" &&
                                  totalSendValue >
                                      double.parse(sendTokenBalance)) ||
                              double.parse(tokenBalance[0].balance) <
                                  double.parse(sendTransactionFee)
                          ? Center(
                              child: InkWell(
                                onTap: () {
                                  if ((sendTokenAddress == "" &&
                                          totalSendValue >
                                              double.parse(sendTokenBalance)) ||
                                      double.parse(tokenBalance[0].balance) <
                                          double.parse(sendTransactionFee)) {
                                    Helper.dialogCall.showToast(context,
                                        "Insufficient ${networkList[0].symbol} balance please deposit some ${networkList[0].symbol}");
                                  }
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 180,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color:
                                          MyColor.greenColor.withOpacity(0.23)),
                                  child: const Center(
                                    child: Text("Confirm send",
                                        style: MyStyle.tx18RWhite),
                                  ),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await confirmSend();
                                setState(() {});
                              },
                              child: Center(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width - 180,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: MyColor.greenColor),
                                  child: const Center(
                                    child: Text("Confirm send",
                                        style: MyStyle.tx18RWhite),
                                  ),
                                ),
                              ),
                            ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          });
        }).whenComplete(() {
      setState(() {
        checkBox = false;
      });
    });
  }

  confirmSend() async {
    var data = {
      "network_id": sendTokenNetworkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": toController.text,
      "token_id": sendTokenId,
      "value": sendTokenNetworkId == "9"
          ? double.parse(sendTokenQuantity.text).toStringAsFixed(5)
          : sendTokenQuantity.text,
      "gasPrice": sendGasPrice,
      "gas": sendGas,
      "nonce": sendNonce,
      "networkFee": sendTransactionFee,
      "isCustomeRPC": false,
      "network_url": networkList.first.url,
      "tokenAddress": sendTokenAddress,
      "decimals": sendTokenDecimals
    };

    // print(jsonEncode(data));
    await transectionProvider.sendToken(data, '/sendAssets');
    if (transectionProvider.isSend == true) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context, "refresh");

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Send Token Successfully Done");

      setState(() {
        isLoading = false;

        if (widget.pageName == "coinDetails") {
          Navigator.pop(context);
          sendGasPrice = "";
          sendGas = "";
          sendNonce = "";
          sendTransactionFee = "0.0";

          // fromAddressController.clear();
          toController.clear();
          sendTokenQuantity.text = "0.0";
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          sendGasPrice = "";
          sendGas = "";
          sendNonce = "";
          sendTransactionFee = "0.0";
          toController.clear();
          sendTokenQuantity.text = "0.0";
        }
        showSendProcessingPage(context);
      });
    }

    //unfair pact message plastic lunch drama comfort faint start board black job
    else {
      if (sendTokenNetworkId == "9" &&
          transectionProvider.sendTokenData["status"] == false) {
        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context,
            "Insufficient ${networkList[0].symbol} balance please deposit some ${networkList[0].symbol}");
        setState(() {
          isLoading = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context, "Send token error");
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  String networkFees = "0";
  getWeb3NetWorkFees() async {
    setState(() {
      isLoading = true;
    });

    var data = {
      "network_id": sendTokenNetworkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": toController.text,
      "token_id": sendTokenId,
      "value": (double.parse(sendTokenBalance) * 0.50),
      "gasPrice": "",
      "gas": "",
      "nonce": 0,
      "isCustomeRPC": false,
      "network_url": networkList.first.url,
      "tokenAddress": sendTokenAddress,
      "decimals": sendTokenDecimals
    };

    // print(json.encode(data));

    await transectionProvider.getNetworkFees(data, '/getNetrowkFees', context);

    if (transectionProvider.isSuccess == true) {
      var body = transectionProvider.networkData;

      setState(() {
        isLoading = false;
        networkFees = "${body['transactionFee']}";

        // print("networkFees ${double.parse(networkFees).toStringAsFixed(5)}");
        // print(networkFees);

        if (sendTokenAddress != "") {
          sendTokenQuantity.text = "${double.parse(sendTokenBalance)}";
          // totalUsd = tokenUsd + double.parse(sendTransactionFee) * tokenPrice;
        } else {
          sendTokenQuantity.text =
              "${(double.parse(sendTokenBalance) - double.parse(networkFees))}";
        }

        setState(() {});
      });

      // ignore: use_build_context_synchronously
      // confirmBottomSheet(context);
    } else {
      var data = DbNetwork.dbNetwork.networkList
          .where((element) => "${element.id}" == sendTokenNetworkId)
          .toList();

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context,
          "Insufficient ${data[0].symbol} balance please deposit some ${data[0].symbol}");
      setState(() {
        isLoading = false;
      });
    }
  }

  showSendProcessingPage(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: CoinSendProcessingPage(
              accAddress: widget.accAddress,
              selectedAccountAddress: selectedAccountAddress,
              tokenDecimal: "$sendTokenDecimals",
              tokenId: sendTokenId,
              tokenNetworkId: sendTokenNetworkId,
              tokenAddress: sendTokenAddress,
              tokenName: sendTokenName,
              tokenSymbol: sendTokenSymbol,
              tokenBalance: sendTokenBalance,
              tokenMarketId: selectTokenMarketId,
              tokenType: tokenType,
              tokenImage: sendTokenImage,
              tokenUsdPrice: double.parse(selectTokenUSD),
              tokenFullPrice: double.parse(sendTokenUsd),
              tokenUpDown: double.parse(tokenUpDown),
              token_transection_Id: sendTokenId,
              explorerUrl: explorerUrl,
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    transectionProvider =
        Provider.of<TransectionProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    // print(networkList[0].toJson());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  SizedBox(width: MediaQuery.of(context).size.width / 2 - 78),
                  Text(
                    "Send",
                    style: NewStyle.tx28White.copyWith(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Container(
                  padding: EdgeInsets.all(11),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Color(0xFFFFE606),
                      width: 1,
                    ),
                    color: Color(0x40FFE606),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          "assets/images/alert.png",
                          width: 18,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            "Your action failed due to insufficient balance, kindly fund your wallet to continue this transaction",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 10,
                                height: 2,
                                fontWeight: FontWeight.w400,
                                color: NewColor.splashContentWhiteColor)),
                      )
                    ],
                  )),
              const SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.all(11),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Color(0xFFDE2323),
                      width: 1,
                    ),
                    color: Color(0x34DE2323),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          "assets/images/alert.png",
                          width: 18,
                          height: 18,
                          color: Color(0xFFDE2323),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            "Address is a High-Risk Address; you can not send fund to this wallet. kindly use another wallet address.",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 10,
                                height: 2,
                                fontWeight: FontWeight.w400,
                                color: NewColor.splashContentWhiteColor)),
                      )
                    ],
                  )),
              const SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.all(11),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Color(0xFF00A478),
                      width: 1,
                    ),
                    color: Color(0x4A00A478),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Image.asset(
                          "assets/images/alert.png",
                          width: 18,
                          height: 18,
                          color: Color(0xFF00A478),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            "Address is a No- Risk Address; you may proceed",
                            style: NewStyle.tx14SplashWhite.copyWith(
                                fontSize: 10,
                                height: 2,
                                fontWeight: FontWeight.w400,
                                color: NewColor.splashContentWhiteColor)),
                      )
                    ],
                  )),
              const SizedBox(height: 10),
              Text(
                "Token Type",
                style: NewStyle.tx28White.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: NewColor.txGrayColor),
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Color(0x99D1D1D1),
                    width: 0.5,
                  ),
                  color: NewColor.dashboardPrimaryColor,
                ),
                child: DropdownButton<String>(
                  value: selectedToken,  // This is the currently selected item.
                  hint: Text(
                    'Select a token type.',
                    style: TextStyle(color: NewColor.txGrayColor), // Change the color here
                  ),  // Placeholder text.
                  elevation: 16,  // Elevation for the dropdown menu.
                  isExpanded: true,
                  style: TextStyle(color: NewColor.txGrayColor),  // Text style for the dropdown items.
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,  // Color of the underline when dropdown is selected.,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedToken = newValue!;  // Update the selected value.
                    });
                  },
                  dropdownColor: NewColor.dashboardPrimaryColor,
                  items: tokenTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value)
                    );
                  }).toList(),  // Map the list of items to DropdownMenuItem widgets.
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Address",
                style: NewStyle.tx28White.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: NewColor.txGrayColor),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: toController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12, height: 2.5),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.dashboardInputDecoration.copyWith(
                    hintText: "${selectedToken != null ? selectedToken : ""} Address",
                    suffixIcon: SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              width: 1, height: 19, color: Color(0x5CD1D1D1)),
                          const SizedBox(width: 11),
                          InkWell(
                            onTap: () async {
                              final value = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const QrScannerPage()));

                              if (value != null) {
                                setState(() {
                                  toController.text = value;
                                });
                              }
                            },
                            child: Image.asset(
                              "assets/images/qr.png",
                              height: 18,
                              width: 18,
                            ),
                          ),
                          const SizedBox(width: 12.5),
                        ],
                      ),
                    )),
              ),
              const SizedBox(height: 19),
              Text(
                "Amount",
                style: NewStyle.tx28White.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: NewColor.txGrayColor),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: amountController,
                cursorColor: NewColor.btnBgGreenColor,
                style: NewStyle.tx28White.copyWith(fontSize: 12, height: 2.5),
                onChanged: (value) {
                  setState(() {});
                },
                decoration: NewStyle.dashboardInputDecoration.copyWith(
                    hintText: " ",
                    suffixIcon: SizedBox(
                      width: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${selectedToken != null ? selectedToken : ""}",
                              style: NewStyle.tx14SplashWhite.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: NewColor.txGrayColor)),
                          const SizedBox(width: 5),
                          InkWell(
                              onTap: () async {
                                amountController.text = "5";
                              },
                              child: Text(
                                "MAX",
                                style: NewStyle.tx14SplashWhite.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: NewColor.btnBgGreenColor),
                              )),
                          const SizedBox(width: 12.5),
                        ],
                      ),
                    )),
              ),
              const SizedBox(height: 5),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "Available: ",
                    style: NewStyle.tx14SplashWhite.copyWith(
                        fontSize: 10,
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                        color: NewColor.txGrayColor)),
                TextSpan(
                    text: "0.0000000 ${selectedToken != null ? selectedToken : ""} ",
                    style: NewStyle.tx14SplashWhite.copyWith(
                        fontSize: 10,
                        height: 1.7,
                        fontWeight: FontWeight.w700,
                        color: NewColor.splashContentWhiteColor)),
              ])),
              const SizedBox(height: 46),
              Container(
                height: 0.5,
                width: double.infinity,
                decoration: BoxDecoration(color: Color(0x5CD1D1D1)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Network fee",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite
                        .copyWith(fontSize: 10, color: NewColor.txGrayColor),
                  ),
                  Text(
                    "0.0000000045",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite
                        .copyWith(fontSize: 10, color: NewColor.mainWhiteColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite
                        .copyWith(fontSize: 10, color: NewColor.txGrayColor),
                  ),
                  Text(
                    "0.00087645",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite
                        .copyWith(fontSize: 10, color: NewColor.mainWhiteColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estimated Time",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite
                        .copyWith(fontSize: 10, color: NewColor.txGrayColor),
                  ),
                  Text(
                    "10 minutes",
                    textAlign: TextAlign.center,
                    style: NewStyle.tx14SplashWhite
                        .copyWith(fontSize: 10, color: NewColor.mainWhiteColor),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => (Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return SendTokenConfirmScreen(
                      address: toController.text,
                      network: selectedToken!,
                      fee: "",
                      amount: ""
                    );
                  }))),
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
              SizedBox(height: 40),
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
                              "Kindly note  that each address check for security purpose incurs a fee of  \$0.30.",
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
                              "wallet AML check takes at least 30 seconds max",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
