import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Ex_Transaction_address.dart';
import 'package:jost_pay_wallet/Models/ExTransactionModel.dart';
import 'package:jost_pay_wallet/Models/ExchangeTokenModel.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/ExchangeCoin/ExchangeTransactionStatus.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/utils.dart';

class ExchangeProvider with ChangeNotifier{
  

  List<ExchangeTokenModel> exTokenList = [];
  List<ExchangeTokenModel> searchExToList = [];
  List<ExchangeTokenModel> tempExTokenList = [];
  // List<AccountTokenList> exTokenList = [];

  late ExchangeTokenModel sendCoin;
  late ExchangeTokenModel receiveCoin;

  bool isLoading = true;

  getTokenList(String url,context)async{
    isLoading = true;

    notifyListeners();


    isLoading = false;
    notifyListeners();

    await ApiHandler.getExchange(url).then((responseData) async {
      var value = json.decode(responseData.body);
      // print("Get Exchange Token ----> $value");

      if(responseData.statusCode == 200) {
        exTokenList.clear();
        searchExToList.clear();
        tempExTokenList.clear();

        List<ExchangeTokenModel> list = [];
        (value as List).map((token) {
          list.add(ExchangeTokenModel.fromJson(token));
        }).toList();

        exTokenList = list;
        searchExToList.addAll(exTokenList);
        tempExTokenList.addAll(exTokenList);
        sendCoin = exTokenList[0];
        receiveCoin = exTokenList[1];
        notifyListeners();

        await getExchangeMinMax(
            "v1/exchange-range/fixed-rate/${sendCoin.ticker.toLowerCase()}_${receiveCoin.ticker.toLowerCase()}",
            {"api_key":Utils.apiKey},
            context
        );

        isLoading = false;
        notifyListeners();

      }else{
        isLoading = false;
        notifyListeners();
      }
    });

  }

  double minAmount = 0,maxAmount = 0;
  bool exRateLoading= true;
  getExchangeMinMax(String url,params,context)async{
    exRateLoading = true;
    notifyListeners();

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);
      // print("object ---> $value");

      if(responseData.statusCode == 200) {

        minAmount = value['minAmount'] ?? -1;
        maxAmount = value['maxAmount'] ?? -1;

        exRateLoading = false;
        notifyListeners();
      }else{
        Helper.dialogCall.showToast(context, "Please change receive coin this is InValid pair");
        exRateLoading = false;
        notifyListeners();

      }
    });
  }


  bool exMinMaxLoading= false;
  getMinMax(String url,params,context)async{
    exMinMaxLoading = true;
    notifyListeners();

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);
      // print("object getMinMax ---> $value");

      if(responseData.statusCode == 200) {

        minAmount = value['minAmount'] ?? -1;
        maxAmount = value['maxAmount'] ?? -1;

        exMinMaxLoading = false;
        notifyListeners();
      }else{
        Helper.dialogCall.showToast(context, "Please change receive coin this is InValid pair");
        exMinMaxLoading = false;
        notifyListeners();

      }
    });
  }

  changeSendToken(ExchangeTokenModel newToken, context,valueType) async {
    if (receiveCoin.ticker != newToken.ticker) {
      // Create a copy of newToken
      ExchangeTokenModel copiedToken = ExchangeTokenModel.fromJson(newToken.toJson());
      sendCoin = copiedToken;

      if(valueType == "") {
        Navigator.pop(context);
      }


      await getMinMax(
          "v1/exchange-range/fixed-rate/${sendCoin.ticker.toLowerCase()}_${receiveCoin.ticker.toLowerCase()}",
          {"api_key":Utils.apiKey},
          context
      );

      notifyListeners();
    } else {
      Helper.dialogCall.showToast(context, "You can't select the same coin");
    }
  }

  changeReceiveToken(ExchangeTokenModel newToken,context) async {
    if(sendCoin.ticker != newToken.ticker ) {
      ExchangeTokenModel copiedToken = ExchangeTokenModel.fromJson(newToken.toJson());
      receiveCoin = copiedToken;

      Navigator.pop(context);

      await getMinMax(
          "v1/exchange-range/fixed-rate/${sendCoin.ticker.toLowerCase()}_${receiveCoin.ticker.toLowerCase()}",
          {"api_key":Utils.apiKey},
          context
      );
      notifyListeners();

    }else{
      Helper.dialogCall.showToast(context, "You can't select same coin");
    }
  }


  bool estimateLoading = false;
  double estimatedAmount =0;
  TextEditingController getCoinController = TextEditingController();
  estimateExchangeAmount(String url,params,context)async{
    estimateLoading = true;
    notifyListeners();

    // print("object--->  $url");
    // print("object--->  $params");

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);

      // print("estimate object --->  $value");

      if(responseData.statusCode == 200) {

        estimatedAmount = value['estimatedAmount']??0;
        getCoinController.text = estimatedAmount.toStringAsFixed(6);
        notifyListeners();
        estimateLoading = false;

      }else{
        estimateLoading = false;
        Helper.dialogCall.showToast(context, "Please change receive coin this is InValid pair");
        notifyListeners();
        print(" =====> exchange estimate Exchange Amount api error <====");
      }
    });
  }


  String payinAddress ="",payoutAddress ="",fromCurrency ="",toCurrency ="",validUntil ="",trxId ="";
  double amount = 0;

  bool createExLoading = false,createExSuccess = false;
  createExchange(url,body,context)async{

    createExSuccess = false;
    createExLoading = true;
    notifyListeners();

    await ApiHandler.postExchange(url,body).then((responseData) async {

      var value = json.decode(responseData.body);
      // print("object url ---> $value");
      if(responseData.statusCode == 200) {
        payinAddress = value["payinAddress"];
        payoutAddress = value["payoutAddress"];
        fromCurrency = value["fromCurrency"];
        toCurrency = value["toCurrency"];
        validUntil = value["validUntil"];
        trxId = value["id"];
        amount = value["amount"];
        // print("object ---> $value");


        Navigator.pop(context,"refresh");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  return ExchangeTransactionStatus(statusId: trxId);
                }
            )
        );

        createExLoading = false;
        createExSuccess = true;
        // print("createExSuccess $createExSuccess");
        notifyListeners();
      }
      else{
        Helper.dialogCall.showToast(context, "${value['message']}");
        createExLoading = false;
        createExSuccess = false;
        notifyListeners();
      }
    });
  
  }


  bool getTrxStatus = false,statusLoading = false;
  transactionStatus(url,accountId) async {
    statusLoading = true;
    getTrxStatus = false;
    notifyListeners();

    await ApiHandler.getExchange(url).then((responseData) async {
      var value = json.decode(responseData.body);
      // print("object url ---> $url");
      // print("transactionStatus ---> $value");

      if(responseData.statusCode == 200) {

        await DbExTransaction.dbExTransaction.getExTransaction();

        var trxIndex = DbExTransaction.dbExTransaction.exTransactionList.indexWhere((element) => element.id == "${value['id']}");

        if(trxIndex == -1) {
          // print("object 1");
          await DbExTransaction.dbExTransaction.createExTransaction(
              ExTransactionModel.fromJson(value)
          );
        }else{
          // print("object 2");
          await DbExTransaction.dbExTransaction.updateExTransaction(
              ExTransactionModel.fromJson(value),
              value["id"],
          );
        }


        statusLoading = false;
        getTrxStatus = true;
        notifyListeners();

      }else{
        statusLoading = false;
        getTrxStatus = false;
        notifyListeners();
        print("-----> transactionStatus api error <------");
      }
    });
  }


  bool isAddressVerify = false,verifyAddressLoading =false;
  addressVerification(String url,params,context) async {
    verifyAddressLoading = true;
    notifyListeners();

    await ApiHandler.getExchangeParams(url, params).then((responseData){
      var value = json.decode(responseData.body);
      // print("object url ---> $params");
      // print("object ---> $value");
      // print("statusCode ---> ${responseData.statusCode}");

      if(responseData.statusCode == 200 && value["result"] == true) {
        isAddressVerify = value["result"];
        verifyAddressLoading = false;
        notifyListeners();
      }else{
        // print("result 0");

        if(value["result"] != null) {
          // print("result 1");
          isAddressVerify = value["result"];
          Helper.dialogCall.showToast(context, "${value['message']}");
        }else{
          // print("result 2");
          isAddressVerify = value["result"];
          Helper.dialogCall.showToast(context, "Address is not valid");
        }
        verifyAddressLoading = false;
        notifyListeners();

      }
    });
  }

}