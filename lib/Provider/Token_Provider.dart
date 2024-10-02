import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Models/SearchTokenModel.dart';
import '../LocalDb/Local_Token_provider.dart';
import '../Models/AccountTokenModel.dart';
import '../Models/NetworkModel.dart';

class TokenProvider with ChangeNotifier {

  bool isLoading = true;
  bool isSuccess = false;

  // ignore: prefer_typing_uninitialized_variables
  var netWorkData;
  bool networkLoad = false;
  getNetworks(url) async {
    isLoading = true;
    networkLoad = false;
    notifyListeners();

      await ApiHandler.get(url).then((responseData) async {

        var value = json.decode(responseData.body);

        // print("get network");

        // await DbNetwork.dbNetwork.deleteAllNetwork();


        if(responseData.statusCode == 200 && value["status"] == true){
          // isSuccess = true;
          netWorkData = value;

          await DbNetwork.dbNetwork.getNetwork();
          (netWorkData["data"] as List).map((token) async {
            var index = DbNetwork.dbNetwork.networkList.indexWhere((element) => "${element.id}" == "${token["id"]}");
            if(index != -1 ){
              await DbNetwork.dbNetwork.updateNetwork(NetworkList.fromJson(token),token["id"]);
            }else {
              await DbNetwork.dbNetwork.createNetwork(NetworkList.fromJson(token));
            }
          }).toList();

          await DbNetwork.dbNetwork.getNetwork();

          networkLoad = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          // isSuccess = false;
          isLoading = false;
          networkLoad = false;

          notifyListeners();

          if (kDebugMode) {
            print("=========== Get Network Api Error ==========");
          }

        }

      });

  }


  bool isAddTokenDone = false;
  // ignore: prefer_typing_uninitialized_variables
  var allToken;
  getAccountToken(data, url,id) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data, url).then((responseData) async {

      var value = json.decode(responseData.body);
      // print("get Token api :- $value");
      if(responseData.statusCode == 200 && value["status"] == true){

        allToken = value;

        // await DBTokenProvider.dbTokenProvider.deleteAccountToken(id);


        await DBTokenProvider.dbTokenProvider.getAccountToken(id,);

        (allToken["data"] as List).map((token) async {
          var index = DBTokenProvider.dbTokenProvider.tokenList.indexWhere((element) {
            return "${element.id}"== "${token["id"]}";
          });
          // print(index);
          if(index != -1){
            await DBTokenProvider.dbTokenProvider.updateToken(AccountTokenList.fromJson(token,id), token["id"],id);
          }else{
            await DBTokenProvider.dbTokenProvider.createToken(AccountTokenList.fromJson(token,id));
          }
        }).toList();

        // print(tokenNote);

        isSuccess = true;
        isLoading = false;
        notifyListeners();

      }
      else {
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print("=========== Get Account Token Api Error ==========");
        }

      }

    });

  }

  // ignore: prefer_typing_uninitialized_variables
  var deleteData;
  deleteToken(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        // print(value);
        if(responseData.statusCode == 200 && value["status"] == true)
        {
          isSuccess = true;
          deleteData = value;
          isLoading = false;
          notifyListeners();
        }
        else
        {
          isLoading = false;
          isSuccess = false;
          notifyListeners();

          if (kDebugMode) {
            print("=========== Delete Token Api Error ==========");
          }

        }

      });

  }


  // ignore: prefer_typing_uninitialized_variables
  var tokenData;
  getCustomToken(data,url) async {
    isLoading = true;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print(value);
      if(responseData.statusCode == 200 && value["status"] == true)
      {
        isSuccess = true;
        tokenData = value;
        notifyListeners();
      }
      else
      {
        tokenData = null;
        isSuccess = false;
        isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print("=========== Get Custom Token Api Error ==========");
        }

      }

    });

  }


  bool isTokenLoading = false;
  bool isTokenAdded = false;
  // ignore: prefer_typing_uninitialized_variables
  var tokenDetail;
  addCustomToken(data,url,id) async {
    isTokenLoading = true;
    isTokenAdded = false;
    notifyListeners();

    await ApiHandler.post(data,url).then((responseData){

      var value = json.decode(responseData.body);
      // print("add token response ===> $value");
      if(responseData.statusCode == 200 && value["status"] == true)
      {
        tokenDetail = value;

        /* (tokenDetail["data"] as List).map((token){
          DBTokenProvider.dbTokenProvider.createToken(AccountTokenList.fromJson(token,id,0));
        }).toList(); */

        isTokenAdded = true;
        isTokenLoading = false;
        notifyListeners();
      }
      else
      {
        isTokenAdded = false;
        isTokenLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print("=========== Add Custom Token Api Error ==========");
        }

      }

    });
  }



  // ignore: prefer_typing_uninitialized_variables
  var tokenBalance;
  bool isBalance = false;

  /// get specific token balance use in coin detail page
  getTokenBalance(data,url) async {
    isLoading = true;
    notifyListeners();

    // print(data);

      await ApiHandler.post(data,url).then((responseData){

        var value = json.decode(responseData.body);
        // print("get balance ---> $value");

        if(responseData.statusCode == 200 && value["status"] == true) {
          tokenBalance = value;

          isBalance = true;
          isLoading = false;
          notifyListeners();
        }
        else {
          tokenBalance = null;

          isLoading = false;
          isBalance = false;
          notifyListeners();

          if (kDebugMode) {
            print("=========== get Token Balance Api Error ==========");
          }

        }

      });

  }



  List<SearchTokenModel> searchTokenList = [];
  List<Map<String,dynamic>> selectTokenBool = [];
  List<Map<String,dynamic>> searchSelectTokenBool = [];
  var allTokenDetails;
  bool isSearch = false;

  /// use in add assets page to get all token
  /// and show which selected and not
  getSearchToken(data,url) async {
    isLoading = true;
    notifyListeners();


    await ApiHandler.post(data, url).then((responseData) async {
      List<SearchTokenModel> list;

      var value = json.decode(responseData.body);
      if (responseData.statusCode == 200 && value["status"] == true) {
        searchTokenList.clear();
        selectTokenBool.clear();
        searchSelectTokenBool.clear();

        var items = value["data"];
        List client = items as List;

        list = client.map<SearchTokenModel>((json) {
          return SearchTokenModel.fromJson(json);
        }).toList();

        searchTokenList.addAll(list);
        selectTokenBool = List.generate(
            searchTokenList.length, (index) => {
              "tokenName": searchTokenList[index].name,
              "symbol": searchTokenList[index].symbol,
              "tokenId": searchTokenList[index].id,
              "isSelected": false
            }
        );

        for (int i = 0; i < DBTokenProvider.dbTokenProvider.tokenList.length; i++) {
          var index = searchTokenList.indexWhere((element) {
            return "${element.id}" == "${DBTokenProvider.dbTokenProvider.tokenList[i].token_id}";
          });
          if (index != -1) {
            selectTokenBool[index]['isSelected'] = true;
          }
        }

        searchSelectTokenBool = selectTokenBool;


        isSearch = true;
        isLoading = false;
        notifyListeners();
      } else {
        isSearch = true;
        isLoading = false;
        notifyListeners();

        print("=========== Search Token List Api Error ==========");
      }
    });


  }

}