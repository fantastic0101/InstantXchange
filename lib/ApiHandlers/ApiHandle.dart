
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jost_pay_wallet/Values/utils.dart';

class ApiHandler {


  static Future<dynamic> post(body, url) async {

      setHeadersPost() => {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
          };

      var baseUrl = Uri.http(Utils.url, '/api$url');

      http.Response response = await http.post(
          baseUrl,
          headers: setHeadersPost(),
          body: jsonEncode(body)
      );

      return response;

  }
  static Future<dynamic> get(url) async {

      var baseUrl = Uri.http(Utils.url, '/api$url');

      setHeadersGet() => {
            'Content-type': 'application/json',
            'Authorization':
                '4fe0c4203533aa61c0fae455ac8d9d07cb237fbf5b8b1e92a783319c02fa5a8d'
          };

      http.Response response =
          await http.get(baseUrl, headers: setHeadersGet());

      return response;
  }
  static String calculateLength(String value){

    int showLength = 0;
    if(double.parse(value) < 1){
      showLength = 1;
      var splitted = value.split('.');

      for(int i=0;i<splitted[1].length;i++){

        if(splitted[1][i] == "0"){
          showLength = showLength+1;
        }
        else{
          break;
        }

      }
    }
    else{
      showLength = 2;
    }

    return double.parse(value).toStringAsFixed(showLength);

  }
  static String calculateLength3(String value){

    int showLength = 0;
    if(double.parse(value) < 1){
      showLength = 1;
      var splitted = value.split('.');

      for(int i=0;i<splitted[1].length;i++){

        if(splitted[1][i] == "0"){
          showLength = showLength+1;
        }
        else{
          break;
        }

      }

      showLength = showLength + 2;

    }
    else{
      showLength = 2;
    }

    return double.parse(value).toStringAsFixed(showLength);

  }


  static String showFiveBalance(String value){

    String getValue = double.parse(value).toStringAsFixed(7);
    String firstValue = getValue.split(".").first;
    String newValue = "";
    if(value.contains(".")){
      if(getValue.split(".").last.length > 5){
        newValue = "$firstValue.${getValue.split(".").last.substring(0,5)}";
      }else{
        newValue = value;
      }
    }else{
      newValue = value;
    }

    // print(value);
    // print(newValue);
    return newValue;

  }



  // this method use for call instantexchangers.net api's
  // use-in: BuySellProvider
  static Future<dynamic> getInstantApi(params) async {
    var baseUrl = Uri.http(
        'instantexchangers.net', '/mobile_server/',
        params,
    );

    setHeadersGet() => {
      'Content-type': 'application/json',
    };

    http.Response response = await http.get(
      baseUrl,
      headers: setHeadersGet(),
    );

    return response;
  }



  // this method use to call changenow exchange apis
  // use-in: ExchangeProvider
  static Future<dynamic> getExchange(url) async {
    var baseUrl = Uri.http(
        'api.changenow.io', '$url',
    );

    setHeadersGet() => {
      'Content-type': 'application/json',
    };

    http.Response response = await http.get(
      baseUrl,
      headers: setHeadersGet(),
    );

    return response;
  }

  // use-in: ExchangeProvider
  static Future<dynamic> getExchangeParams(url,params) async {
    var baseUrl = Uri.http(
        'api.changenow.io', '$url',params
    );

    setHeadersGet() => {
      'Content-type': 'application/json',
    };

    http.Response response = await http.get(
      baseUrl,
      headers: setHeadersGet(),
    );

    return response;
  }

  // use-in: ExchangeProvider
  static Future<dynamic> postExchange(url,body) async {
    var baseUrl = Uri.http(
        'api.changenow.io', '$url'
    );

    setHeadersGet() => {
      'Content-type': 'application/json',
    };

    http.Response response = await http.post(
      baseUrl,
      body: jsonEncode(body),
      headers: setHeadersGet(),
    );

    return response;
  }


}
