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
class WithdrawDetails extends StatefulWidget {


  const WithdrawDetails({
    super.key,
  });

  @override
  State<WithdrawDetails> createState() => _WithdrawDetailsState();
}

class _WithdrawDetailsState extends State<WithdrawDetails> {


  TextEditingController priceController = TextEditingController();
  TextEditingController bankNoController = TextEditingController();
  TextEditingController acNameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? selectedBank,selectedAccountId = "",
      networkFees,sellBank,
      selectedAccountAddress = "",
      selectedAccountPrivateAddress = "";
  bool isLoading = true;
  var usdError = "",emailError = "";

  late BuySellProvider buySellProvider;
  late DashboardProvider dashboardProvider;
  late TransectionProvider transectionProvider;

  AccountTokenList? selectedCoin;

  sellValidateOrder(context)async{

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    selectedAccountId = sharedPre.getString('accountId') ?? "";

    await DbNetwork.dbNetwork.getNetwork();


    var params = {
      "action":"validate_sell_order",
      "email":emailController.text.isEmpty ? "a@gmail.com" : emailController.text.trim(),
      "token":"",
      // "token":buySellProvider.loginModel== null ? "" : buySellProvider.loginModel!.accessToken,
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

      double selectTokenUSD;

      if(selectedCoin!.price == null){
        selectTokenUSD = 0.0;
      }
      else{
        selectTokenUSD = double.parse(selectedCoin!.balance) * selectedCoin!.price;
      }

      var sendData = {
        "sendTokenDecimals":selectedCoin!.decimals,
        "sendTokenName":selectedCoin!.name,
        "sendTokenAddress":selectedCoin!.address,
        "sendTokenNetworkId":selectedCoin!.networkId,
        "sendTokenSymbol":sendTokenSymbol,
        "selectTokenMarketId":selectedCoin!.marketId,
        "sendTokenImage":selectedCoin!.logo,
        "tokenUpDown":selectedCoin!.percentChange24H,
        "sendTokenBalance":sendTokenBalance,
        "sendTokenId":selectedCoin!.token_id,
        "sendTokenUsd":sendTokenUsd,
        "explorerUrl":selectedCoin!.explorer_url,
        "selectTokenUSD":selectTokenUSD,
      };

      var value =  await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellValidationPage(
              params: params,
              coinName: selectedCoin!.name,
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
    setState(() {
      isLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DbNetwork.dbNetwork.getNetwork();
    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId!);

    setState(() {
      isLoading = false;
    });
  }


  double usdAmount = 0.0;
  String sendTokenSymbol = "",sendTokenBalance="0",sendTokenUsd = "0";




  @override
  void initState() {
    super.initState();
    dashboardProvider = Provider.of<DashboardProvider>(context,listen: false);
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    transectionProvider = Provider.of<TransectionProvider>(context, listen: false);

    buySellProvider.accessToken = "";
    buySellProvider.sellValidOrder = false;


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
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, selectedCoin!.networkId);

    setState(() {
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
    });

    var data = {

      "network_id": selectedCoin!.networkId,
      "privateKey": selectedAccountPrivateAddress,
      "from": selectedAccountAddress,
      "to": selectedCoin!.networkId == 9 ? "TF2JHvbiHbLyUyP3GyfnEzvRCD3P66u6VZ" : selectedAccountAddress,
      "token_id": selectedCoin!.token_id,
      "value": type == "max" ? (double.parse(sendTokenBalance) * 0.50) : priceController.text,
      "gasPrice": "",
      "gas":"",
      "nonce": 0,
      "isCustomeRPC": false,
      "network_url":networkList.first.url,
      "tokenAddress":selectedCoin!.address,
      "decimals":selectedCoin!.decimals
    };

    // print(json.encode(data));

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

          // print("----> ${selectedCoin!.address}");

          if (selectedCoin!.address != "") {
            priceController.text = "${double.parse(sendTokenBalance)}";
          } else {
            // print("----> ${selectedCoin!.address}");

            priceController.text = "${double.parse(sendTokenBalance) - double.parse(sendTransactionFee)}";
          }

          usdAmount = double.parse(priceController.text) * double.parse(sendTokenUsd);
          if (usdAmount < buySellProvider.minSellAmount) {
            usdError = "Min. ${buySellProvider.minSellAmount}";
          } else {
            usdError = "";
          }
        }

        List<AccountTokenList> tokenBalance = DBTokenProvider.dbTokenProvider.tokenList.where((element) {
          return element.networkId == selectedCoin!.networkId && element.type == "";
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

        body:isLoading
            ?
        Helper.dialogCall.showLoader()
            :
        SafeArea(
          child : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),


              // sell and token name text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Withdraw",
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
              ),


              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      DropdownButtonFormField<AccountTokenList>(
                        value: selectedCoin,
                        decoration: MyStyle.textInputDecoration.copyWith(
                          contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: MyColor.greenColor,
                        ),
                        hint: Text(
                          "Select coin",
                          style:MyStyle.tx22RWhite.copyWith(
                              fontSize: 18,
                              color: MyColor.whiteColor.withOpacity(0.7)
                          ),
                        ),
                        dropdownColor: MyColor.backgroundColor,
                        isExpanded: true,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                        items: DBTokenProvider.dbTokenProvider.tokenList.where((element) => element.type != "TRC20").map((AccountTokenList category) {

                          return DropdownMenuItem(
                              value: category,
                              child: Text(
                                "${category.name} ${category.type == ""? "" : "(${category.type})"}",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              )
                          );
                        }).toList(),
                        onChanged: (AccountTokenList? value) async {
                          setState(() {
                            networkFees = null;
                            selectedCoin = null;
                            usdError = "";
                            priceController.clear();
                            usdAmount = 0;
                            selectedCoin = value;
                            sendTokenBalance= value!.balance;
                            sendTokenUsd ="${value.price}";
                            sendTokenSymbol = value.symbol;
                            networkList = DbNetwork.dbNetwork.networkList.where((element) {
                              return "${element.id}" == "${value.networkId}";
                            }).toList();

                            sellValidateOrder(context);
                          });
                        },
                      ),

                      // token details name
                      selectedCoin == null ? const SizedBox() :
                      Container(
                        margin: const EdgeInsets.only(
                            top: 15),
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
                                imageUrl:  selectedCoin!.logo,
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
                                selectedCoin!.name,
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
                                  sendTokenBalance == "0" ?
                                  "0 $sendTokenSymbol"
                                      :
                                  "${ApiHandler.showFiveBalance(sendTokenBalance)} $sendTokenSymbol",
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 15
                                  ),
                                ),
                                Text(
                                  "${ApiHandler.calculateLength3((double.parse(selectedCoin!.balance) * selectedCoin!.price).toString())} \$",
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
                          // print(buySellProvider.minSellAmount);
                          if(value.isNotEmpty) {
                            if(isMax){
                              isMax = false;
                            }
                            usdAmount = (double.parse(value) * double.parse(double.parse(sendTokenUsd).toStringAsFixed(2)));
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
                          "Amount in USD ~ ${usdAmount.toStringAsFixed(3)}",
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
                      const SizedBox(height: 30),

                      // Proceed button

                      buySellProvider.sellValidOrder || feesLoading
                          ?
                      Helper.dialogCall.showLoader()
                          :
                      priceController.text.isEmpty
                          || sellBank == null || emailError.isNotEmpty
                          || usdAmount < buySellProvider.minSellAmount
                          || phoneNoController.text.isEmpty
                          || double.parse(sendTokenBalance) <  double.parse(priceController.text)
                          || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                          ?
                      InkWell(
                        onTap: () {
                          // print(usdAmount < buySellProvider.minSellAmount);

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
                              ||  phoneNoController.text.isEmpty ||emailError.isNotEmpty
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
                                      || double.parse(sendTokenBalance) <=  double.parse(priceController.text)
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


                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
