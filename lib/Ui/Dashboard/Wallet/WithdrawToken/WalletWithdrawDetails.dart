import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Provider/Transection_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellHistory.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellValidationPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class WalletWithdrawDetails extends StatefulWidget {
  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      sendTonkenType = "",
      selectTokenMarketId = "",
      tokenUpDown = "",
      sendTokenImage = "",
      selectTokenUSD = "",
      sendTokenBalance = "",
      sendTokenId = "",
      explorerUrl = "",
      accAddress = "",
      sendTokenUsd = "";
  int sendTokenDecimals;

  WalletWithdrawDetails({
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
    required this.sendTokenUsd,
    required this.accAddress,
    required this.sendTonkenType,
    required this.sendTokenDecimals,
  });

  @override
  State<WalletWithdrawDetails> createState() => _WalletWithdrawDetailsState();
}

class _WalletWithdrawDetailsState extends State<WalletWithdrawDetails> {


  TextEditingController priceController = TextEditingController();
  TextEditingController bankNoController = TextEditingController();
  TextEditingController acNameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  late TransectionProvider transectionProvider;


  String? selectedBank,selectedAccountId = "",networkFees,sellBank,selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";
  bool isLoading = true;
  var usdError = "",emailError = "";

  late BuySellProvider buySellProvider;
  late DashboardProvider dashboardProvider;

  sellValidateOrder(context)async{

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    selectedAccountId = sharedPre.getString('accountId') ?? "";


    await DbNetwork.dbNetwork.getNetwork();


    var params = {
      "action":"validate_sell_order",
      "email":emailController.text.isEmpty ? "a@gmail.com" : emailController.text.trim(),
      "token":"",
      "item_code":sendTokenSymbol,
      "amount":usdAmount.toString(),
      "bank":sellBank ?? "",
      "account_no":bankNoController.text.trim(),
      "account_name":acNameController.text.trim(),
      "phone":phoneNoController.text,
      "auth":"p1~\$*)Ze(@"
    };

    // print("object ${jsonEncode(params)}");

    await buySellProvider.validateSellOrder(
        params,
        selectedAccountId,
        context,
        sendTokenSymbol
    );


    // print(buySellProvider.getSellValidation);

    if(buySellProvider.getSellValidation != null){

      var sendData = {
        "sendTokenDecimals":sendTokenDecimals,
        "sendTokenName":sendTokenName,
        "sendTokenAddress":sendTokenAddress,
        "sendTokenNetworkId":sendTokenNetworkId,
        "sendTokenSymbol":sendTokenSymbol,
        "selectTokenMarketId":selectTokenMarketId,
        "sendTokenImage":sendTokenImage,
        "tokenUpDown":tokenUpDown,
        "sendTokenBalance":sendTokenBalance,
        "sendTokenId":sendTokenId,
        "sendTokenUsd":sendTokenUsd,
        "explorerUrl":explorerUrl,
        "selectTokenUSD":selectTokenUSD,
      };

      var value =  await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellValidationPage(
              params: params,
              coinName: sendTokenName,
              pageName: "send",
              sendData: sendData,
            ),

          )
      );

      // print("object value --> ${value}");
      if(value != null) {
        setState(() {
          priceController.text = "0";
          phoneNoController.clear();
          bankNoController.clear();
          acNameController.clear();
          sellBank = null;
        });
      }
    }

  }

  storeData() async {
    await DbNetwork.dbNetwork.getNetwork();
    setState(() {
      isLoading = true;



      sendTokenName = widget.sendTokenName;
      sendTokenAddress = widget.sendTokenAddress;
      sendTokenNetworkId = widget.sendTokenNetworkId;
      sendTokenSymbol = widget.sendTokenSymbol;
      selectTokenMarketId = widget.selectTokenMarketId;
      sendTokenImage  = widget.sendTokenImage;
      tokenUpDown  = widget.tokenUpDown;
      sendTokenBalance  = widget.sendTokenBalance;
      sendTokenId  = widget.sendTokenId;
      sendTokenUsd  = widget.sendTokenUsd;
      explorerUrl  = widget.explorerUrl;
      selectTokenUSD  = widget.selectTokenUSD;
      sendTokenDecimals  = widget.sendTokenDecimals;

      networkList = DbNetwork.dbNetwork.networkList.where((element) {
        return "${element.id}" == sendTokenNetworkId;
      }).toList();
      isLoading = false;
    });


    sellValidateOrder(context);

  }


  double usdAmount = 0.0;

  String sendTokenAddress = "",
      sendTokenNetworkId = "",
      sendTokenName = "",
      sendTokenSymbol = "",
      selectTokenMarketId = "",
      sendTokenImage = "",
      tokenUpDown = "",
      selectTokenUSD = "",
      explorerUrl = "",
      sendTokenBalance = "0",
      sendTokenId = "",
      sendTokenUsd = "0",
      tokenType = ""; int sendTokenDecimals = 0;


  @override
  void initState() {
    super.initState();
    dashboardProvider = Provider.of<DashboardProvider>(context,listen: false);
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.sellValidOrder = true;
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);
    buySellProvider.accessToken = "";

    Future.delayed(const Duration(milliseconds: 500),(){
      storeData();
    });
  }


  List<NetworkList> networkList = [];

  String sendGasPrice = "";
  String sendGas = "";
  String? sendNonce = "";
  String sendTransactionFee = "0";
  bool feesLoading = false,isMax = false;

  getNetworkFees(String type) async {
    setState(() {
      feesLoading = true;
    });
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, sendTokenNetworkId);

    setState(() {
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
    });

    // print("sendTokenBalance  $sendTokenBalance");

    var data = {

      "network_id": sendTokenNetworkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": sendTokenNetworkId == "9" ? "TF2JHvbiHbLyUyP3GyfnEzvRCD3P66u6VZ" : selectedAccountAddress,
      "token_id": sendTokenId,
      "value": type == "max" ? ((double.parse(sendTokenBalance) * 0.50).toStringAsFixed(3)) : priceController.text,
      "gasPrice": "",
      "gas":"",
      "nonce": 0,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "tokenAddress":sendTokenAddress,
      "decimals":sendTokenDecimals
    };

    // print(json.encode(data));
    //
    // ignore: use_build_context_synchronously
    await transectionProvider.getNetworkFees(data,'/getNetrowkFees',context);

    if( transectionProvider.isSuccess == true){

      var body = transectionProvider.networkData;

      setState(() {
        isLoading = false;

        sendGasPrice = "${body['gasPrice']}";
        sendGas = "${body['gas']}";
        sendNonce = "${body['nonce']}";
        sendTransactionFee = "${body['transactionFee']}";

        if(type == "max" || isMax) {
          if (sendTokenAddress != "") {
            priceController.text = "${double.parse(sendTokenBalance)}";
            // totalUsd = tokenUsd + double.parse(sendTransactionFee) * tokenPrice;
            usdAmount = double.parse(priceController.text) * double.parse(sendTokenUsd);
          } else {
            priceController.text =
                "${double.parse(sendTokenBalance) - double.parse(sendTransactionFee)}";
            // totalUsd = tokenUsd + networkUsd;
            usdAmount =
                double.parse(priceController.text) * double.parse(sendTokenUsd);
          }

          if (usdAmount < buySellProvider.minSellAmount) {
            usdError = "Min. ${buySellProvider.minSellAmount}";
          } else {
            usdError = "";
          }
        }

        List<AccountTokenList> tokenBalance = DBTokenProvider.dbTokenProvider.tokenList.where((element) {
          return "${element.networkId}" == sendTokenNetworkId && element.type == "";
        }).toList();

        if(double.parse(tokenBalance[0].balance) < double.parse(sendTransactionFee)){
          Helper.dialogCall.showToast(context, "Insufficient balance to cover fees, reduce withdraw amount");
        }

        setState(() {});

        if(type == ""){
          sellValidateOrder(context);
        }

      });

      // ignore: use_build_context_synchronously
    }
    else{
      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Insufficient balance to cover fees, reduce withdraw amount");

    }
    setState(() {
      feesLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);
    dashboardProvider = Provider.of<DashboardProvider>(context,listen: true);
    transectionProvider = Provider.of<TransectionProvider>(context, listen: true);

    return Scaffold(

        appBar: AppBar(
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
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellHistory(),
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

        body:isLoading || buySellProvider.sellValidOrder
            ?
        Helper.dialogCall.showLoader()
            :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // sell and token name text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sell $sendTokenName",
                    style: MyStyle.tx18BWhite.copyWith(
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    "Sell coin to any Bank in Nigeria Receive Naira",
                    style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 12,
                        color: MyColor.grey01Color
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // token details name
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
                      decoration: BoxDecoration(
                        color: MyColor.darkGrey01Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              height: 40,
                              width: 40,
                              fit: BoxFit.fill,
                              imageUrl:  sendTokenImage,
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
                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              sendTokenName,
                              style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 15
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                sendTokenBalance == "0"
                                    ?
                                "$sendTokenBalance $sendTokenSymbol"
                                    :
                                "${ApiHandler.showFiveBalance(sendTokenBalance)} $sendTokenSymbol",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 15
                                ),
                              ),
                              Text(
                                "${ApiHandler.calculateLength3(selectTokenUSD)} \$",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 12,
                                    color: MyColor.grey01Color
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Withdraw amount
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: priceController,
                      cursorColor: MyColor.greenColor,
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      onChanged: (value){
                        if(value.isNotEmpty) {
                          if(isMax){
                            isMax = false;
                          }
                          usdAmount = double.parse(value) * double.parse(sendTokenUsd);
                          if (usdAmount < buySellProvider.minSellAmount) {
                            usdError = "Min. ${buySellProvider.minSellAmount}";
                          } else {
                            usdError = "";
                          }
                        }
                        setState(() {});
                      },
                      decoration: MyStyle.textInputDecoration.copyWith(
                          hintText: "Withdraw amount",
                          isDense: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                          suffixIcon: IntrinsicWidth(
                            child: Center(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isMax = true;
                                      });
                                      getNetworkFees("max");
                                    },
                                    child: Text(
                                      "Max",
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 14,
                                        color: MyColor.greenColor
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    sendTokenSymbol,
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 14
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                ],
                              ),
                            ),
                          )
                      ),
                    ),
                    Visibility(
                        visible: usdError.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0,left: 10),
                          child: Text(
                            usdError,
                            style: MyStyle.tx18BWhite.copyWith(
                                color: MyColor.redColor,
                                fontSize: 14
                            ),
                          ),
                        )
                    ),
                    const SizedBox(height: 08),

                    // Amount in usd
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Amount in USD ~ ${usdAmount.toStringAsFixed(2)}",
                        style: MyStyle.tx18BWhite.copyWith(
                            fontSize: 13,
                            color: MyColor.grey01Color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bank Account No.
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: bankNoController,
                      cursorColor: MyColor.greenColor,
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Bank Account No.",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                      ),

                    ),
                    const SizedBox(height: 20),

                    // Account Name
                    TextFormField(
                      controller: acNameController,
                      cursorColor: MyColor.greenColor,
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Account Name",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // bank DropDown
                    DropdownButtonFormField<String>(
                      value: sellBank,
                      isExpanded: true,
                      decoration: MyStyle.textInputDecoration.copyWith(
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: MyColor.greenColor,
                      ),
                      hint: Text(
                        "Select Bank",
                        style:MyStyle.tx22RWhite.copyWith(
                            fontSize: 18,
                            color: MyColor.whiteColor.withOpacity(0.7)
                        ),
                      ),
                      dropdownColor: MyColor.backgroundColor,
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),

                      items: buySellProvider.sellBankList.map((String category) {

                        return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            )
                        );
                      }).toList(),
                      onChanged: (String? value) async {
                        setState(() {
                          sellBank = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),


                    // Your Phone No
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: phoneNoController,
                      cursorColor: MyColor.greenColor,
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Your Phone No",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                      ),

                    ),
                    const SizedBox(height: 20),

                    // Your Email Address
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      cursorColor: MyColor.greenColor,
                      onChanged: (value) {
                        RegExp checkMail =  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if(!checkMail.hasMatch(value)){
                          emailError = "Please enter valid email id.";
                        }else{
                          emailError = "";
                        }
                        setState(() {});
                      },
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                      decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Your Email Address",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                      ),

                    ),
                    Visibility(
                        visible: emailError.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0,left: 10),
                          child: Text(
                            emailError,
                            style: MyStyle.tx18BWhite.copyWith(
                                color: MyColor.redColor,
                                fontSize: 14
                            ),
                          ),
                        )
                    ),
                    const SizedBox(height: 40),

                    // Proceed button

                    buySellProvider.sellValidOrder || feesLoading
                        ?
                    Helper.dialogCall.showLoader()
                        :
                     priceController.text.isEmpty
                         || sellBank == null
                         || emailError.isNotEmpty
                         || usdAmount < buySellProvider.minSellAmount
                         || phoneNoController.text.isEmpty
                         || double.parse(sendTokenBalance) <  double.parse(priceController.text)
                         || acNameController.text.isEmpty
                         || bankNoController.text.isEmpty
                         || emailController.text.isEmpty
                        ?
                    InkWell(
                      onTap: () {
                        if(usdAmount < buySellProvider.minSellAmount || double.parse(sendTokenBalance) <  double.parse(priceController.text)){
                          Helper.dialogCall.showToast(context, "Insufficient balance");
                        }else{
                          Helper.dialogCall.showToast(context, "Please provider all details");
                        }
                        setState(() {});
                      },
                      child : Container(
                        alignment: Alignment.center,
                        height: 45,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration:
                         priceController.text.isEmpty || sellBank == null
                            ||  phoneNoController.text.isEmpty ||
                             emailError.isNotEmpty
                            || usdAmount < buySellProvider.minSellAmount
                             || double.parse(sendTokenBalance) <  double.parse(priceController.text)
                             || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                            ?
                        MyStyle.invalidDecoration
                            :
                        MyStyle.buttonDecoration,

                        child: Text(
                            "Proceed",
                            style:  MyStyle.tx18BWhite.copyWith(
                                color:   priceController.text.isEmpty || sellBank == null
                                    || phoneNoController.text.isEmpty
                                    || usdAmount < buySellProvider.minSellAmount
                                    || double.parse(sendTokenBalance) <  double.parse(priceController.text)
                                    || acNameController.text.isEmpty || bankNoController.text.isEmpty
                                    || emailController.text.isEmpty
                                    ?
                                MyColor.mainWhiteColor.withOpacity(0.4)
                                    :
                                MyColor.mainWhiteColor
                            )
                        ),
                      ),
                    )
                        :
                    InkWell(
                      onTap: () {
                        getNetworkFees("");

                        // sellValidateOrder(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: MyStyle.buttonDecoration,
                        child: const Text(
                          "Proceed",
                          style: MyStyle.tx18BWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),


                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
