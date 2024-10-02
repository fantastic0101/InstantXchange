import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuyScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/InstantLoginScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuySellPage extends StatefulWidget {
  const BuySellPage({super.key});

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {

  var selectedType = "Buy";
  late BuySellProvider buySellProvider;

  bool isLoading = false;


  checkLogin()async{

    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var date  = sharedPre.getString("expireDate")??"";
    const storage = FlutterSecureStorage();

    if(date != "") {
      DateTime expireDate = DateTime.parse(date);
      if(!expireDate.isAfter(DateTime.now())){
        await storage.deleteAll();
        setState(() {
          buySellProvider.accessToken = "";
          buySellProvider.loginModel = null;
          sharedPre.remove("expireDate");
          sharedPre.remove("email");
        });
        // ignore: use_build_context_synchronously
        Helper.dialogCall.showToast(context, "Your Login is expire.Please login again");
      }else {

        var data = await storage.read(key: "loginValue");
        var deCode = jsonDecode(data!);

        setState(() {
          List<RatesInfo> ratesInfoList = [];
          deCode['rates_info'].map((e) {
            ratesInfoList.add(
                RatesInfo.fromJson(
                    e,
                    e['itemCode']
                )
            );
          }).toList();

          buySellProvider.loginModel = null;
          buySellProvider.loginModel = LoginModel.fromJson(deCode, ratesInfoList);
        });

      }
    }else{
      setState(() {
        buySellProvider.loginModel = null;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.accessToken = "";
    buySellProvider.loginButtonText = "Get Otp";
    buySellProvider.showOtpText = false;

    super.initState();

    Future.delayed(Duration.zero,(){
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    return

     SafeArea(
      child:  buySellProvider.loginModel == null
          ?
      const InstantLoginScreen()
          :
      isLoading ? Helper.dialogCall.showLoader():
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: MyColor.darkGrey01Color
              ),
              child: Row(
                children: [
                  Expanded(
                    child : InkWell(
                      onTap: (){
                        setState(() {
                          selectedType = "Buy";
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: selectedType == "Buy" ? MyColor.greenColor :Colors.transparent
                        ),
                        child: Text(
                          "Buy",
                          style: MyStyle.tx18BWhite.copyWith(
                            color: selectedType == "Buy" ? MyColor.mainWhiteColor : MyColor.dotBoarderColor,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child : InkWell(
                      onTap: (){
                        setState(() {
                          selectedType = "Sell";
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: selectedType == "Sell" ? MyColor.greenColor :Colors.transparent
                        ),
                        child: Text(
                          "Sell",
                          style: MyStyle.tx18BWhite.copyWith(
                            color: selectedType == "Sell" ? MyColor.mainWhiteColor : MyColor.dotBoarderColor,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
                child: selectedType == "Buy"
                    ?
                const BuyScreen()
                    :
                const SellScreen()
            )
          ],
        ),
      ),
    );
  }
}
