import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/Models/BuySellHistoryModel.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuyPaymentInstructions.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellStatusPage.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/WithdrawToken/WithdrawSendPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/SellHistoryModel.dart';

class BuySellProvider with ChangeNotifier{

  String loginButtonText = "Get Otp";
  var accessToken = "";

  bool getOtpBool = false;
  bool showOtpText = false;

  getLoginOTPApi(params,context)async{
    getOtpBool = true;
    showOtpText = false;
    notifyListeners();

    try {
      await ApiHandler.getInstantApi(params).then((responseData) {
        // print(responseData);

        var value = json.decode(responseData.body);
        // print("value getLoginOTPApi ==> $value");
        if (responseData.statusCode == 200 && value['error'] == null) {

          Helper.dialogCall.showToast(context, "${value['info']}");

          getOtpBool = false;
          showOtpText = true;

          loginButtonText = "Login";
          notifyListeners();
        } else {

          Helper.dialogCall.showToast(context, "${value['error']}");

          getOtpBool = false;
          notifyListeners();

        }
      });
    }catch(e){

      // print("$e");
      print("============  get Login OTP Api error  ============");

      getOtpBool = false;
      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      notifyListeners();

    }
  }

  bool isLoginLoader = false;
  LoginModel? loginModel;
  getLogIn(params,context,email)async{
    isLoginLoader = true;
    notifyListeners();

    try {
      await ApiHandler.getInstantApi(params).then((responseData) async {

        var value = json.decode(responseData.body);

        // print("Login value ${value}");
        if (responseData.statusCode == 200 && value['error'] == null) {
          loginModel = null;
          List<RatesInfo> ratesInfoList = [];
          value['rates_info'].keys.forEach((key){
            // print(value['rates_info'][key]);
              ratesInfoList.add(
                  RatesInfo.fromJson(value['rates_info'][key],key));
          });


          loginModel = LoginModel.fromJson(value,ratesInfoList);

          // print("check value here");
          SharedPreferences sharedPre = await SharedPreferences.getInstance();
          sharedPre.setString("email","$email");
          sharedPre.setString("expireDate","${DateTime.now().add(const Duration(days: 1))}");
          accessToken = value['access_token'];

          await getExRate({"action":"exchange_rate"},context);

          for(int i =0; i<loginModel!.ratesInfo.length; i++){
            // print(loginModel!.ratesInfo[i].memoLabel);
            var exListIndex = exchangeList.indexWhere((element) => element["name"] == loginModel!.ratesInfo[i].name);
            if(exListIndex != -1){
              loginModel!.ratesInfo[i].buyPrice = exchangeList[i]['buy'];
              loginModel!.ratesInfo[i].sellPrice = exchangeList[i]['sell'];
            }
          }

          const storage =  FlutterSecureStorage();
          String jsonString = jsonEncode(loginModel);
          // print("loginModel!.banks");
          var data = jsonDecode(jsonString);
          // print(data['rates_info'].map((e)=>debugPrint(e['memo_label'])).toList());
          await storage.write(key: "loginValue", value: jsonString);


          isLoginLoader = false;
          showOtpText = false;
          loginButtonText = "Get Otp";

          notifyListeners();
        } else {

          Helper.dialogCall.showToast(context, "${value['error']}");
          isLoginLoader = false;

          notifyListeners();

        }
      });
    }catch(e){

      // print("$e");
      print("============  get Login Api error  ============");

      isLoginLoader = false;
      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      notifyListeners();

    }
  }


  bool isExRateLoader = false;
  List exchangeList = [];

  getExRate(params,context)async  {
    isExRateLoader = true;
    notifyListeners();

    try {

      await ApiHandler.getInstantApi(params).then((responseData) async {
        var value = json.decode(responseData.body);

        if (responseData.statusCode == 200) {
          var buy =value['exchange_rate'].toString().split("Buy");

          for(int i = 0; i<buy.length; i++){
            if(buy[i].split("Sell").length >= 2) {

              var buyValue = buy[i].split("Sell")[0];
              var sellValue = buy[i].split("Sell")[1];
              // print("buy ====>${}");

              var buyMainValue = buyValue.split(".").last.split(" ")[1].trim();
              var sellMainValue = sellValue.split(".").last.split(" ")[1].trim();

              var dataValue = {
                "buy" : int.parse(buyMainValue),
                "sell" : int.parse(sellMainValue),
                "name": buyValue.split(".").first.split(" ").last.trim(),
              };

              exchangeList.add(dataValue);

            }
            else{
              var buyValue1 = buy[i].split("Sell")[0];
              List buyMainValue1 = buyValue1.split(".").last.split(" ").toList();

              if (buyMainValue1.length >= 2) {
                var currencyValue = buyMainValue1[1].trim();
                var dataValue ={
                  "buy" : int.parse(currencyValue),
                  "sell" : 0,
                  "name": currencyValue.split(".").first.split(" ").last.trim(),
                };
                exchangeList.add(dataValue);
              }

            }
          }

          isExRateLoader = false;
          notifyListeners();

        } else {

          isExRateLoader = false;
          notifyListeners();

        }
      });
    }catch(e){

      print("============  get Login Api error  ============");

      Helper.dialogCall.showToast(context, "Something is wrong please try again.");
      isExRateLoader = false;
      notifyListeners();

    }
  }

  dynamic getValidData;
  bool isValidBuyLoading = true;
  String receiveValue = "";
  validateBuyOrder(params)async{
    isValidBuyLoading = true;
    getValidData = null;
    receiveValue = "";
    notifyListeners();

    await ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);

      // print("${value['info'].toString()}");
      if (responseData.statusCode == 200) {
        isValidBuyLoading = false;
        getValidData = value;
        if(getValidData['info'].toString().contains("RAW AMOUNT :")){
          var data = getValidData['info'].toString().split("RAW AMOUNT :").last.trim().split(" ");
          receiveValue = "${double.parse(data[0]).toStringAsFixed(3)} ${data[1].trim().split("\n").first}" ;
        }


        notifyListeners();
      }else{
        isValidBuyLoading = false;
        notifyListeners();
      }
    });
  }

  bool orderLoading = false;
  placeBuyOrder(params,context)async{
    orderLoading = true;
    notifyListeners();

    await ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);
      if (responseData.statusCode == 200) {

        Navigator.pop(context,"refresh");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyPaymentInstructions(
                buyResponse: value,
              ),
            )
        );

        // Helper.dialogCall.showToast(context, "Your order placed successfully.");
        orderLoading = false;

        notifyListeners();

      }else{
        Helper.dialogCall.showToast(context, "something is wrong please try again.");

        orderLoading = false;
        notifyListeners();
      }
    });
  }

  bool buyHistoryLoading = false;
  List<BuySellHistoryModel> buyHistoryList = [];
  buyHistory(params)async{
    buyHistoryLoading = true;
    notifyListeners();
    List<BuySellHistoryModel> list = [];


    await ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);
      if (responseData.statusCode == 200) {
        buyHistoryLoading = false;


        var items = value["transactions"];
        List client = items as List;
        // print("client length----> ${client.length}");

        list = client.map<BuySellHistoryModel>((json) {
          // print(json);
          return BuySellHistoryModel.fromJson(json);
        }).toList();

        buyHistoryList.addAll(list.where((element) => element.details.transactionType == "Buy").toList());
        notifyListeners();

      }else{
        buyHistoryLoading = false;
        notifyListeners();
      }
    });
  }


  bool sellHistoryLoading = false;
  List<BuySellHistoryModel> sellHistoryList = [];
  sellHistory(params)async{
    sellHistoryLoading = true;
    notifyListeners();
    List<BuySellHistoryModel> list = [];


    await ApiHandler.getInstantApi(params).then((responseData){
      var value = json.decode(responseData.body);
      if (responseData.statusCode == 200) {


        var items = value["transactions"];
        List client = items as List;

        list = client.map<BuySellHistoryModel>((json) {

          return BuySellHistoryModel.fromJson(json);
        }).toList();

        sellHistoryList.addAll(list.where((element) => element.details.transactionType == "Sell").toList());
        sellHistoryLoading = false;

        notifyListeners();

      }else{
        sellHistoryLoading = false;
        notifyListeners();
      }
    });
  }


  bool sellValidOrder = false,isValidSuccess = false;
  dynamic getSellValidation;
  List<dynamic> sellRateList = [];
  List<String> sellBankList = [];
  int minSellAmount =0;

  validateSellOrder(params,accountId,context,symbol)async{
    sellValidOrder = true;
    isValidSuccess = false;
    getSellValidation = null;
    notifyListeners();

    await ApiHandler.getInstantApi(params).then((responseData) async {
      try {
        var value = json.decode(responseData.body);
        // print("validateSellOrder----> $value");

        if (responseData.statusCode == 200 && value["info"] != null) {
          sellValidOrder = false;
          isValidSuccess = true;
          getSellValidation = value;
          notifyListeners();
        }
        else {
          sellBankList.clear();
          sellRateList.clear();

          if (value['rates_info'] != null) {
            value['rates_info'].keys.forEach((key) {
               var data = {
                  "name": value['rates_info'][key]['name'],
                  "symbol": key,
                  "sellPrice": value['rates_info'][key]['sell_price'],
                  "minSellAmount": value['rates_info'][key]['min_sell_amount'],
                };
                sellRateList.add(data);
            });

            List myNewList;
            if (symbol != ""){
              myNewList = sellRateList.where((element) {
                return "${element["symbol"]}" == "$symbol";
              }).toList();

              minSellAmount = int.parse(myNewList[0]["minSellAmount"].toString());
              notifyListeners();

            }


          }

          if (value['sell_banks'] != null) {
            List<String> list = List<String>.from(
                value['sell_banks'].map((x) => x)
            );
            sellBankList.addAll(list);
          }

          if(value['error'].toString().contains("Amount must be at least")){
            Helper.dialogCall.showToast(context, value['error']);
          }

          sellValidOrder = false;
          notifyListeners();
        }
      }catch(e){
        sellValidOrder = false;
        // print("----> $e");
        Helper.dialogCall.showToast(context, "Something is wrong.Please letter");

        notifyListeners();
      }
    });

  }


  bool sellOderLoading = false;
  bool sellSuccess = false;
  var sellResponce;
  sellOrder(params,accountId,BuildContext context,send,Map<String,dynamic> sendData,coinName) async {
    sellOderLoading = true;
    sellSuccess = false;
    notifyListeners();
    await ApiHandler.getInstantApi(params).then((responseData) async {
      var value = json.decode(responseData.body);

      // print("object id ---> $value");
      if (responseData.statusCode == 200 && value['error'] == null) {
        await DbSellHistory.dbSellHistory.getSellHistory(accountId);
        sellResponce = value;
        var trxIndex = DbSellHistory.dbSellHistory.sellHistoryList.indexWhere((element) => element.invoice == "${value['invoice']}");

        if(trxIndex == -1) {
          await DbSellHistory.dbSellHistory.createSellHistory(
              SellHistoryModel.fromJson(value,accountId,coinName,params['bank'],params['account_no'],params['account_name'])
          );
        }
        else{
          await DbSellHistory.dbSellHistory.updateSellHistory(
              SellHistoryModel.fromJson(value,accountId,coinName,params['bank'],params['account_no'],params['account_name']),
              value["invoice"],
              accountId
          );
        }


        if(send == "send") {
          // ignore: use_build_context_synchronously
          Navigator.pop(context,"refresh");

          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WithdrawSendPage(
                  selectTokenUSD:"${sendData['selectTokenUSD']}",
                  explorerUrl:sendData['explorerUrl'],
                  tokenUpDown:"${sendData['tokenUpDown']}",
                  sendTokenId:"${sendData['sendTokenId']}",
                  selectTokenMarketId:"${sendData['selectTokenMarketId']}",
                  sendTokenAddress:sendData['sendTokenAddress'],
                  sendTokenBalance:sendData['sendTokenBalance'],
                  sendTokenDecimals:int.parse("${sendData['sendTokenDecimals']}"),
                  sendTokenImage:sendData['sendTokenImage'],
                  sendTokenName:sendData['sendTokenName'],
                  sendTokenNetworkId:"${sendData['sendTokenNetworkId']}",
                  sendTokenSymbol:sendData['sendTokenSymbol'],
                  sendTokenUsd:"${sendData['sendTokenUsd']}",
                  sellInvoice: value["invoice"],
                  sellResponce:sellResponce,
                  params: params,
                ),
              )
          );
        }
        else{
          // ignore: use_build_context_synchronously
          Navigator.pop(context,"refresh");

          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SellStatusPage(
                  invoiceNo: sellResponce['invoice'],
                  tokenName: coinName,
                  pageName: "",
                ),
              )
          );
        }


        sellSuccess = true;
        sellOderLoading = false;

        notifyListeners();

      }else{
        Helper.dialogCall.showToast(context, value['error']);
        sellOderLoading = false;
        notifyListeners();
      }
    });

  }


  bool checkOrderLoading = false;
  checkOrderStatus(params,accountId,context,name) async {
    checkOrderLoading = true;
    notifyListeners();
    await ApiHandler.getInstantApi(params).then((responseData) async {
      var value = json.decode(responseData.body);

      // print("checkOrderStatus $value");
      if (responseData.statusCode == 200) {
        await DbSellHistory.dbSellHistory.getSellHistory(accountId);
        await DbSellHistory.dbSellHistory.updateStatus(
            SellHistoryModel.fromJson(value, accountId, name,"","",""),
            accountId
        );

        checkOrderLoading = false;

        notifyListeners();

      }else{
        print("--------> check order status api error <--------");
        checkOrderLoading = false;
        notifyListeners();
      }
    });

  }

  bool placeNotifyOrder = false;
  bool notifyLoading = false;
  notifyOrder(params,context,String? pageName)async{
    placeNotifyOrder = false;
    notifyLoading = true;
    notifyListeners();

    await ApiHandler.getInstantApi(params).then((responseData) {
      var value = json.decode(responseData.body);

      if (responseData.statusCode == 200 && value['info'] != null) {
        if(pageName == "") {
          Navigator.pop(context);
        }
        placeNotifyOrder = true;
        notifyLoading = false;
        notifyListeners();
      }
      else{
        placeNotifyOrder = false;
        notifyLoading = false;
        notifyListeners();
        Navigator.pop(context);
        notifyListeners();
      }
    });
  }


}