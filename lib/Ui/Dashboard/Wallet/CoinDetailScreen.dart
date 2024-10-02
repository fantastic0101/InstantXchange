import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/ExchangeTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WithdrawToken/WalletWithdrawDetails.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ExchangeCoin/ExchangeScreen.dart';
import 'ReceiveToken/ReceiveScreen.dart';
import 'SendToken/SendCoinScreen.dart';


// ignore: must_be_immutable
class CoinDetailScreen extends StatefulWidget {

  String selectedAccountAddress,tokenId,tokenNetworkId,tokenAddress,accAddress,tokenName,token_transection_Id,
      tokenSymbol,tokenBalance,tokenImage,tokenType,tokenMarketId,tokenDecimal,explorerUrl;
  double tokenUsdPrice,tokenUpDown,tokenFullPrice;

  CoinDetailScreen({
    super.key,
    required this.selectedAccountAddress,
    required this.tokenId,
    required this.token_transection_Id,
    required this.tokenNetworkId,
    required this.tokenAddress,
    required this.tokenName,
    required this.tokenImage,
    required this.tokenDecimal,
    required this.tokenType,
    required this.tokenSymbol,
    required this.tokenBalance,
    required this.tokenUsdPrice,
    required this.tokenUpDown,
    required this.tokenFullPrice,
    required this.tokenMarketId,
    required this.explorerUrl,
    required this.accAddress,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {

  late TransectionProvider transectionProvider;
  late ExchangeProvider exchangeProvider;

  String tokenId = "",tokenName = "",tokenNatewokrkId = "",
      tokenSymbol = "",tokenImage = "",tokenUsd = "",
      tokenBalance = "",tokenMarketId = "",sendTokenType = "";

  late TokenProvider tokenProvider;
  List<NetworkList> networkList = [];

  @override
  void initState() {
    super.initState();
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);

    transectionProvider.transectionList.clear();

    tokenId = widget.tokenId;
    tokenNatewokrkId = widget.tokenNetworkId;
    tokenName = widget.tokenName;
    tokenSymbol = widget.tokenSymbol;
    tokenImage = widget.tokenImage;
    tokenBalance = widget.tokenBalance;
    sendTokenType = widget.tokenType;
    tokenMarketId = widget.tokenMarketId;
    tokenUsd = "${widget.tokenUsdPrice}";

    getNetWork();

  }


  // get selected token network data
  getNetWork() async {
    await DbNetwork.dbNetwork.getNetwork();
    networkList = DbNetwork.dbNetwork.networkList.where((element) {
      return "${element.id}" == widget.tokenNetworkId;
    }).toList();

    setState(() {});
    getTransection();
    getCustomTokenBalance();
  }


  // get transaction list
  getTransection() async {

    var data = {
      "network_id": widget.tokenNetworkId,
      "token_id":widget.token_transection_Id,
      "tokenDecimal": widget.tokenDecimal,
      "tokenAddress":widget.tokenAddress,
      "address":widget.selectedAccountAddress,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "network_name":networkList.first.name,
      "explorer_url":networkList.first.explorerUrl,
      "symbol":networkList.first.symbol
    };
    // print(json.encode(data));
    await transectionProvider.getTransection(data,'/getTransactions');
    //print(transectionProvider.transectionList.length);
    setState(() {
      _showRefresh = false;
    });
  }


  // get token updated balance form api
  getCustomTokenBalance() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,9);
    var trxPrivateKey = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;


    var data = {
      "tokenAddress":widget.tokenAddress,
      "address":widget.selectedAccountAddress,
      "network_id":tokenNatewokrkId,
      "trxPrivateKey":trxPrivateKey,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "network_name":networkList.first.name,
    };


    // print("object ${jsonEncode(data)}");

    await tokenProvider.getTokenBalance(data,'/getTokenBalance');
    var body = tokenProvider.tokenBalance;
    if(body != null){

      var getPrice = await DBTokenProvider.dbTokenProvider.getTokenUsdPrice(tokenId);
      setState((){
        tokenBalance = "${body['data']['balance']}";
        tokenUsd = "${double.parse(tokenBalance) * getPrice[0]['price']}";
      });
    }

  }


  // pull to refresh
  bool _showRefresh = false;
  Future<void> _getData() async {
    setState(() {
      _showRefresh = true;
    });

    transectionProvider.transectionList.clear();
    getTransection();
    getCustomTokenBalance();

  }


  @override
  Widget build(BuildContext context) {
    final dashProvider = Provider.of<DashboardProvider>(context);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    exchangeProvider = Provider.of<ExchangeProvider>(context, listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return  Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
        leading:  InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: MyColor.mainWhiteColor,
            size: 20,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // coin details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: MyColor.darkGreyColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.tokenName,
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 18,
                                color: MyColor.grey01Color
                            ),
                          ),

                          Visibility(
                            visible: widget.tokenType.isNotEmpty,
                            child: Text(
                              "Type: ${widget.tokenType}",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 13,
                                  color: MyColor.grey01Color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$${widget.tokenFullPrice.toStringAsFixed(2)} ",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                      ),
                    ),
                    Text(
                      "(${widget.tokenUpDown.toStringAsFixed(2)})",
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                          color:widget.tokenUpDown < 0 ? MyColor.redColor :  MyColor.greenColor
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: MyColor.darkGrey01Color,
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    height: 45,
                    width: 45,
                    fit: BoxFit.fill,
                    imageUrl: tokenImage,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: MyColor.greenColor),
                    ),
                    errorWidget: (context, url, error) =>

                      Container(
                            height: 45,
                            width: 45,
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
                const SizedBox(height: 18),

                Text(
                  "${ApiHandler.calculateLength(tokenUsd)} USD",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 28,
                  ),
                ),

                Text(
                  tokenBalance == "0" ? "0 $tokenSymbol" : "${double.parse(ApiHandler.calculateLength3(tokenBalance))} $tokenSymbol",
                  style: MyStyle.tx22RWhite.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // receive
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiveScreen(
                              networkId: int.parse(widget.tokenNetworkId),
                              tokenName: widget.tokenName,
                              tokenSymbol: widget.tokenSymbol,
                              tokenType: widget.tokenType,
                              tokenImage: widget.tokenImage,
                            ),
                          )
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(13),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: MyColor.backgroundColor,
                                shape: BoxShape.circle
                            ),
                            child: Image.asset(
                              "assets/images/dashboard/receive.png",
                              height: 18,
                              width: 18,
                              color: MyColor.greenColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Receive",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // withdraw
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletWithdrawDetails(
                                sendTokenAddress: widget.tokenAddress,
                                sendTokenNetworkId: widget.tokenNetworkId,
                                sendTokenName: widget.tokenName,
                                sendTokenSymbol: widget.tokenSymbol,
                                selectTokenMarketId: widget.tokenMarketId,
                                sendTokenImage : widget.tokenImage,
                                sendTokenBalance : widget.tokenBalance,
                                sendTokenId : widget.tokenId,
                                sendTokenUsd : "${widget.tokenFullPrice}",
                                sendTokenDecimals:int.parse(widget.tokenDecimal),
                                tokenUpDown:widget.tokenUpDown.toString() ,
                                explorerUrl: widget.explorerUrl,
                                selectTokenUSD: widget.tokenUsdPrice.toString(),
                                accAddress: widget.accAddress,
                                sendTonkenType:widget.tokenType,

                              ),
                            )
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(13),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: MyColor.backgroundColor,
                                shape: BoxShape.circle
                            ),
                            child: Image.asset(
                              "assets/images/dashboard/card.png",
                              height: 18,
                              width: 18,
                              color: MyColor.greenColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Withdraw",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    //Exchange
                    InkWell(
                      onTap: () {

                        ExchangeTokenModel model = ExchangeTokenModel(
                            ticker: tokenSymbol,
                            name: tokenName,
                            image: tokenImage
                        );

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExchangeScreen(
                                tokenList: model,
                              ),
                            )
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(13),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: MyColor.backgroundColor,
                                shape: BoxShape.circle
                            ),
                            child: Image.asset(
                              "assets/images/dashboard/exchange.png",
                              height: 18,
                              width: 18,
                              color: MyColor.greenColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Exchange",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 12,
                                color: MyColor.whiteColor
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cannot find your transaction
          InkWell(
            onTap: () {
              if(sendTokenType == "BEP20"){
                launchUrl(
                  Uri.parse("https://bscscan.com/token/${widget.tokenAddress}?a=${widget.selectedAccountAddress}"),
                  mode: LaunchMode.externalApplication,
                );
              }else if(sendTokenType ==  "TRC20") {
                launchUrl(
                  Uri.parse("https://tronscan.org/#/address/${widget.selectedAccountAddress}"),
                  mode: LaunchMode.externalApplication,
                );
              }else {
                launchUrl(
                  Uri.parse(widget.explorerUrl),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MyColor.boarderColor
                )
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Cannot find your transaction? ",
                      style: MyStyle.tx18BWhite.copyWith(
                        color: MyColor.dotBoarderColor,
                        fontSize: 14
                      ),
                    ),

                    TextSpan(
                      text: "Check explorer",
                      style: MyStyle.tx18BWhite.copyWith(
                        color: MyColor.greenColor,
                        fontSize: 14
                      ),
                    )
                  ]
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Transactions list
          Expanded(
            child: DeclarativeRefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              color: MyColor.greenColor,
              backgroundColor: MyColor.mainWhiteColor,
              onRefresh: _getData,
              refreshing: _showRefresh,
              child: transectionProvider.isLoading == true && !_showRefresh
                    ?
                const Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  ),
                )
                    :
                transectionProvider.transectionList.isEmpty
                    ?
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: height * 0.45,
                    width: width,
                    child: Center(
                      child: Text(
                        "No Transaction Yet.",
                        textAlign: TextAlign.center,
                        style: MyStyle.tx18RWhite.copyWith(
                            color: MyColor.grey01Color
                        ),
                      ),
                    ),
                  ),
                )
                    :
                GroupedListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  elements: transectionProvider.transectionList,
                  groupComparator: (value1, value2) => value2.compareTo(value1),
                  groupBy: (element) {
                    return element.timeStamp == "undefined"
                      ?
                  DateTime.now().toString().substring(0,10)
                      :
                  DateTime.fromMillisecondsSinceEpoch(int.parse(element.timeStamp) * 1000).toString().substring(0,10);
                  },

                  groupHeaderBuilder: (value) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        value.timeStamp == "undefined"
                            ?
                        DateFormat("dd MMM yyyy").format(DateTime.now())
                            :
                        DateFormat("dd MMM yyyy").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse( value.timeStamp) * 1000
                          )
                        ),
                        style:MyStyle.tx18RWhite.copyWith(
                            fontSize: 14,
                            color: MyColor.grey01Color
                        ),
                      ),
                    );
                  },
                  itemBuilder: (context,  element) {

                    return InkWell(
                      onTap: () {
                        launchUrl(
                          Uri.parse(element.explorerUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Transactions type icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: MyColor.darkGrey01Color,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                element.from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                    ?
                                "assets/images/dashboard/send.png"
                                    :
                                "assets/images/dashboard/receive.png",
                                height: 17,
                                width: 17,
                                fit: BoxFit.contain,
                                color: MyColor.greenColor,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // coin name text
                                      Expanded(
                                        child:

                                        Text(

                                        element.txType != ""
                                            ?
                                          element.txType
                                            :
                                          element.from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                              ?
                                          "Transfer" : "Deposit",
                                          style: MyStyle.tx18RWhite.copyWith(
                                              fontSize: 15,
                                            color: MyColor.whiteColor
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // receive text
                                      Text(
                                        element.from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                            ?
                                        "- ${ApiHandler.showFiveBalance("${element.value}")} ${widget.tokenSymbol}"
                                            :
                                        "+ ${ApiHandler.showFiveBalance("${element.value}")} ${widget.tokenSymbol}",
                                        style: MyStyle.tx22RWhite.copyWith(
                                            fontSize: 15,
                                            color:  element.from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                                ?
                                            MyColor.whiteColor
                                                :
                                            MyColor.greenColor
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          element.from.toLowerCase() == widget.selectedAccountAddress.toLowerCase()
                                              ?
                                          "To: ${element.to.substring(0,5)}...${"${element.to}".substring("${element.to}".length-5,"${element.to}".length)}"
                                              :
                                          "From: ${element.from.substring(0,5)}...${"${element.from}".substring("${element.from}".length-5,"${element.from}".length)}",
                                          style: MyStyle.tx18RWhite.copyWith(
                                              fontSize: 13,
                                            color: MyColor.grey01Color
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "\$ ${ApiHandler.calculateLength("${(widget.tokenFullPrice * element.value)}")}",

                                        style: MyStyle.tx18RWhite.copyWith(
                                            fontSize: 14,
                                            color: MyColor.grey01Color
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 2),
                                  // Text(
                                  //     DateFormat('dd MM yyyyy hh:mma').format(DateTime.fromMillisecondsSinceEpoch(int.parse(element.timeStamp) * 1000)),
                                  //   style: MyStyle.tx18BWhite.copyWith(
                                  //     fontSize: 15
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
          ),

        ],
      ),
    );
  }

}
