import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jost_pay_wallet/Models/ExchangeTokenModel.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Values/utils.dart';
import 'ExChangeTokenList.dart';
import 'ExchangeAddressScreen.dart';
import 'ExchangeHistory.dart';

class ExchangeScreen extends StatefulWidget {
  final ExchangeTokenModel? tokenList;
  const ExchangeScreen({
    super.key,
     this.tokenList
  });

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {

  TextEditingController sendCoinController = TextEditingController();
  late ExchangeProvider exchangeProvider;
  var selectedAccountId = "",sendError ="";
  bool showSendError = false,isLoading = true;


  // get token list
  getExToken() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    // ignore: use_build_context_synchronously
    await exchangeProvider.getTokenList("/v1/currencies",context);

    if(widget.tokenList != null){
      setState(() {
        exchangeProvider.changeSendToken(widget.tokenList!, context,"oldValue");
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  // get receive token animate amount
  estimateExchangeAmount(context)async{
    String sendSymbol = exchangeProvider.sendCoin.ticker.toLowerCase();
    String receiveSymbol = exchangeProvider.receiveCoin.ticker.toLowerCase();
    var data = {
      "api_key":Utils.apiKey
    };
    await exchangeProvider.estimateExchangeAmount("v1/exchange-amount/fixed-rate/${sendCoinController.text.trim()}/${sendSymbol}_$receiveSymbol",data,context);
  }

  // swap UpDown methods
  swapUpDown(context) async {
    var tempSend = exchangeProvider.sendCoin;
    var tempReceive = exchangeProvider.receiveCoin;

    setState(() {
      exchangeProvider.sendCoin = tempReceive;
      exchangeProvider.receiveCoin = tempSend;
    });


    if(sendCoinController.text.isNotEmpty) {
      await exchangeProvider.getMinMax(
          "v1/exchange-range/fixed-rate/${exchangeProvider.sendCoin.ticker
              .toLowerCase()}_"
              "${exchangeProvider.receiveCoin.ticker.toLowerCase()}",
          {"api_key": Utils.apiKey}, context);

      estimateExchangeAmount(context);
    }
  }

  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    exchangeProvider.getCoinController.clear();
    super.initState();
    Future.delayed(Duration.zero,(){
      getExToken();
    });
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);

    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          exchangeProvider.isLoading || exchangeProvider.exRateLoading || exchangeProvider.estimateLoading
              ?
          Visibility(
            visible: exchangeProvider.exMinMaxLoading,
            child: SizedBox(
              height: 55,
              child: Helper.dialogCall.showLoader(),
            ),
          )
              :
          InkWell(
            onTap: () async {
              if(showSendError || exchangeProvider.getCoinController.text.isEmpty || sendCoinController.text.isEmpty){
                Helper.dialogCall.showToast(context, "Please provide all details");
              }else {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExchangeAddressScreen(
                            sendAmount: sendCoinController.text.trim(),
                          ),
                    )
                );

                setState(() {
                  sendCoinController.clear();
                  exchangeProvider.getCoinController.clear();
                });
              }
            },
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: showSendError || exchangeProvider.getCoinController.text.isEmpty ? MyStyle.invalidDecoration : MyStyle.buttonDecoration,
              child:  Text(
                "Continue",
                style: MyStyle.tx18BWhite.copyWith(
                  color: showSendError || exchangeProvider.getCoinController.text.isEmpty ? MyColor.dotBoarderColor : MyColor.mainWhiteColor,
                ),
              ),
            ),
          ),
          SizedBox(height: Platform.isIOS ? 10 : 5),

        ],
      ),

      body:exchangeProvider.isLoading || exchangeProvider.exRateLoading || isLoading
          ?
      Helper.dialogCall.showLoader()
          :
      SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              FocusScope.of(context).unfocus();
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus!.unfocus();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const SizedBox(
                          height: 25,
                          width: 25,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: MyColor.mainWhiteColor,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "Exchange",
                          style: MyStyle.tx18BWhite,
                        ),
                      ),
                      IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ExchangeHistory(),
                                  )
                              );
                            },
                            icon: const Icon(
                              Icons.history,
                              color: MyColor.mainWhiteColor,
                            )
                        )
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: width,
                    decoration: BoxDecoration(
                      color:MyColor.blackColor,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(
                      children: [

                        // text filed and title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                                child: Text(

                                  "You send ${exchangeProvider.sendCoin.name.split(" ").first} (${exchangeProvider.sendCoin.ticker})",
                                  style:MyStyle.tx18RWhite.copyWith(
                                      fontSize: 12,
                                      color: MyColor.grey01Color
                                  ),
                                ),
                              ),
                              TextFormField(
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  if(double.parse(value.isEmpty ? "0" : value) < exchangeProvider.minAmount){
                                    setState(() {
                                      showSendError = true;
                                      sendError = "Amount must be more then ${exchangeProvider.minAmount}";
                                    });
                                  }else if(exchangeProvider.maxAmount!=-1 && double.parse(value) > exchangeProvider.maxAmount){
                                    setState(() {
                                      showSendError = true;
                                      sendError = "Amount must be less then ${exchangeProvider.maxAmount}";
                                    });
                                  }else{
                                    setState(() {
                                      showSendError = false;
                                      sendError = "";
                                    });
                                    estimateExchangeAmount(context);

                                  }
                                },
                                controller: sendCoinController,
                                cursorColor: MyColor.greenColor,
                                style: MyStyle.tx18RWhite,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                                  ],
                                decoration: InputDecoration(
                                    hintText: "0.0",
                                    border: InputBorder.none,
                                    hintStyle:MyStyle.tx22RWhite.copyWith(
                                        fontSize: 18,
                                        color: MyColor.whiteColor.withOpacity(0.7)
                                    ),
                                    errorStyle: const TextStyle(fontSize: 0,height: 0),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                )
                              )
                            ],
                          ),
                        ),


                        const SizedBox(width: 8),
                        const SizedBox(height: 60,
                          child: VerticalDivider(
                            thickness: 1.5,
                            color: MyColor.backgroundColor,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // coin images and name
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExChangeTokenList(
                                  pageType: "send"
                                ),
                              )
                            );
                            setState(() {
                              sendCoinController.clear();
                              exchangeProvider.getCoinController.clear();
                            });
                          },
                          child: SizedBox(
                            width: width * 0.3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: SvgPicture.network(
                                      exchangeProvider.sendCoin.image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      "${exchangeProvider.sendCoin.name.split(" ").first} (${exchangeProvider.sendCoin.ticker})",
                                      style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 14
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showSendError,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        sendError,
                        style: MyStyle.tx18BWhite.copyWith(
                            color: MyColor.redColor,
                            fontSize: 12
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // middle send coin value and price
                  Row(
                    children: [

                      const Spacer(),
                      InkWell(
                        onTap: () {
                          swapUpDown(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          color:MyColor.blackColor,
                          child: Image.asset(
                            "assets/images/dashboard/up_down_arrow.png",
                            height: 20,
                            width: 20,
                            color: MyColor.mainWhiteColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                    ],
                  ),
                  const SizedBox(height: 20),

                  // get coin details
                  Container(
                    width: width,
                    decoration: BoxDecoration(
                        color:MyColor.blackColor,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(
                      children: [

                        // text filed and title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                                child: Text(
                                  "You get ${exchangeProvider.receiveCoin.name.split(" ").first} (${exchangeProvider.receiveCoin.ticker})",
                                  style:MyStyle.tx18RWhite.copyWith(
                                      fontSize: 12,
                                      color: MyColor.grey01Color
                                  ),
                                ),
                              ),
                              TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: exchangeProvider.getCoinController,
                                  readOnly: true,
                                  cursorColor: MyColor.greenColor,
                                  style: MyStyle.tx18RWhite,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "0.0",
                                    border: InputBorder.none,
                                    hintStyle:MyStyle.tx22RWhite.copyWith(
                                        fontSize: 18,
                                        color: MyColor.whiteColor.withOpacity(0.7)
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                  )
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        const SizedBox(height: 60,
                          child: VerticalDivider(
                            thickness: 1.5,
                            color: MyColor.backgroundColor,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // coin images and name
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExChangeTokenList(
                                    pageType: "receive"
                                ),
                              )
                            );
                            setState(() {
                              sendCoinController.clear();
                              exchangeProvider.getCoinController.clear();
                            });
                          },
                          child: SizedBox(
                            width: width * 0.3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: SvgPicture.network(
                                      exchangeProvider.receiveCoin.image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "${exchangeProvider.receiveCoin.name.split(" ").first} (${exchangeProvider.receiveCoin.ticker})",
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 14
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }

}
