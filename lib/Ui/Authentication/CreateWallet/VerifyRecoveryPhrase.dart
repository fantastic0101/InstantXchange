import 'dart:io';

import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class VerifyRecoveryPhrase extends StatefulWidget {
  List selectedParse;
  List seedPhrase;
  final bool isNew;

  VerifyRecoveryPhrase({
    super.key,
    required this.seedPhrase,
    required this.isNew,
    required this.selectedParse,
  });

  @override
  State<VerifyRecoveryPhrase> createState() => _VerifyRecoveryPhraseState();
}

class _VerifyRecoveryPhraseState extends State<VerifyRecoveryPhrase> {

  confirmBottomSheet(BuildContext context){
    showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: false,
      backgroundColor: MyColor.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal:20,vertical:22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // dos icon
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: MyColor.lightGreyColor
                ),
              ),
              const SizedBox(height: 25),
              // check icon
              Image.asset(
                "assets/images/check.png",
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 25),

              //title congratulations text
              Text(
                "Congratulations",
                style:MyStyle.tx22RWhite.copyWith(
                  color: MyColor.mainWhiteColor,
                  fontSize: 25
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              //subtitle text
              Text(
                "You've successfully protected your wallet. Remember to "
                    "keep your recovery phrase safe, its your responsibility!",
                textAlign: TextAlign.center,
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 17,
                    color: MyColor.grey01Color
                ),
              ),
              const SizedBox(height: 28),

              //setting recovery text
              Text(
                "You can find your recovery phrase in",
                textAlign: TextAlign.center,
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 17,
                    color: MyColor.whiteColor
                ),
              ),
              const SizedBox(height: 4),

              // setting info
              Text(
                "Settings > Wallets",
                textAlign: TextAlign.center,
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 17,
                    color: MyColor.greenColor
                ),
              ),
              const SizedBox(height: 30),

              // done button
              InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ), (route) => false
                  );
                },
                child : Container(
                  alignment: Alignment.center,
                  height: 45,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: MyStyle.buttonDecoration,
                  child:  const Text(
                      "Done",
                      style: MyStyle.tx18BWhite
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  late String firstId,secondId,thardId;
  String firstSeed = "",secondSeed = "", thardSeed = "";

  late String firstSelectId = "",secondSelectId = "", thardSelectId = "";

  List newList = [];
  List boolList = [];
  List selectedItem = [];

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  String deviceId = "";
  bool isLoading =  false;

  bool isFirst = false,isSecond = false,isThird = false;


  getAccount() async {
    setState(() {
      isLoading = true;
    });


    for(int i=0; i<accountProvider.accountData.length; i++){

      for(int j=0; j<DbNetwork.dbNetwork.networkList.length; j++){

        await DbAccountAddress.dbAccountAddress.createAccountAddress(
            accountProvider.accountData[i]["id"],
            accountProvider.accountData[i][DbNetwork.dbNetwork.networkList[j].publicKeyName],
            accountProvider.accountData[i][DbNetwork.dbNetwork.networkList[j].privateKeyName],
            DbNetwork.dbNetwork.networkList[j].publicKeyName,
            DbNetwork.dbNetwork.networkList[j].privateKeyName,
            DbNetwork.dbNetwork.networkList[j].id,
            DbNetwork.dbNetwork.networkList[j].name
        );

      }

      await DBAccountProvider.dbAccountProvider.createAccount(
          "${accountProvider.accountData[i]["id"]}",
          accountProvider.accountData[i]["device_id"],
          accountProvider.accountData[i]["name"],
          accountProvider.accountData[i]["mnemonic"]
      );


    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('accountId', "${accountProvider.accountData[0]["id"]}");
    sharedPreferences.setString('accountName', accountProvider.accountData[0]["name"]);


    await DBAccountProvider.dbAccountProvider.getAllAccount();

    if(widget.isNew){
      getTokenForOld("${accountProvider.accountData[0]["id"]}");
    }else {
      getToken();
    }
  }

  getToken() async {

    for (int i = 0; i < DBAccountProvider.dbAccountProvider.newAccountList.length; i++) {

      await DbAccountAddress.dbAccountAddress.getAccountAddress(DBAccountProvider.dbAccountProvider.newAccountList[i].id);
      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      await tokenProvider.getAccountToken(data, '/getAccountTokens', DBAccountProvider.dbAccountProvider.newAccountList[i].id,);

    }

    if(tokenProvider.isSuccess){
      // ignore: use_build_context_synchronously
      confirmBottomSheet(context);
    }


    setState(() {
      isLoading = false;
    });
  }

  getTokenForOld(String accountId) async {

    await DbAccountAddress.dbAccountAddress.getAccountAddress(accountId);
    var data = {};

    for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
      data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
    }

    await tokenProvider.getAccountToken(data, '/getAccountTokens', accountId);

    if(tokenProvider.isSuccess) {

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setDouble('myBalance',0.00);

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
            (route) => false,
      );
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    super.initState();

    var newList1 = [];
    newList1.addAll(widget.seedPhrase);

    newList.addAll(newList1..shuffle());
    newList1 = [];

    firstId = "${widget.selectedParse[0]['id']}";
    secondId = "${widget.selectedParse[1]['id']}";
    thardId = "${widget.selectedParse[2]['id']}";


    firstSeed = "${widget.selectedParse[0]['id']}";
    secondSeed = "${widget.selectedParse[1]['id']}";
    thardSeed = "${widget.selectedParse[2]['id']}";
    boolList = List.filled(widget.seedPhrase.length, false);



  }

  @override
  Widget build(BuildContext context) {

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    return  Scaffold(
      // continue button
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading == true
              ?
          const SizedBox(
              height:52,
              child: Center(
                  child: CircularProgressIndicator(
                    color: MyColor.greenColor,
                  )
              )
          )
              :
          InkWell(
            onTap: () async {
              if(firstId == firstSelectId && secondId == secondSelectId && thardId == thardSelectId){

                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                sharedPreferences.setString('isLogin', 'true');

                getAccount();

              }
              else{
                Helper.dialogCall.showToast(context, "Confirm Seed Phrase Failed Try Again");
              }

            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration:firstId == firstSelectId && secondId == secondSelectId && thardId == thardSelectId
                  ?
              MyStyle.buttonDecoration
                  :
              MyStyle.invalidDecoration,
              child: Text(
                  "Continue",
                  style: MyStyle.tx18BWhite.copyWith(
                      color:firstId == firstSelectId && secondId == secondSelectId && thardId == thardSelectId
                          ?
                      MyColor.mainWhiteColor
                          :
                      MyColor.mainWhiteColor.withOpacity(0.4)
                  )
              ),
            ),
          ),

          SizedBox(height: Platform.isIOS ? 10 : 5),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
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
        title: Text(
          "Verify Recovery Phrase",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 15),

              // select 3 phrase container
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 20),
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: MyColor.darkGreyColor,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Tap each world in the order it was presented to you.",
                      style: MyStyle.tx18RWhite,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                int index = newList.indexWhere((element) => element == firstSeed);
                                boolList[index] = false;
                                selectedItem.remove(firstSeed);
                                firstSeed = firstId;
                                firstSelectId = "";
                                isFirst = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isFirst ? MyColor.greenColor : firstSeed != firstId ?  MyColor.redColor : MyColor.transparentColor,
                              ),
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                width: double.maxFinite,
                                decoration: DottedDecoration(
                                    shape: Shape.box,
                                    borderRadius: BorderRadius.circular(10),
                                    color: isFirst ? MyColor.whiteColor :  MyColor.dotBoarderColor
                                ),
                                child: Text(
                                  firstSeed,
                                  textAlign: TextAlign.center,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      color: isFirst ? MyColor.whiteColor : firstSeed != firstId ?  MyColor.whiteColor : MyColor.dotBoarderColor
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                int index = newList.indexWhere((element) => element == secondSeed);
                                boolList[index] = false;
                                selectedItem.remove(secondSeed);
                                secondSeed = secondId;
                                secondSelectId = "";
                                isSecond = false;
                                secondSelectId = "";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isSecond ? MyColor.greenColor : secondSeed != secondId ?  MyColor.redColor : MyColor.transparentColor,
                              ),
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                width: double.maxFinite,
                                decoration: DottedDecoration(
                                    shape: Shape.box,
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSecond ? MyColor.whiteColor :  MyColor.dotBoarderColor
                                ),
                                child: Text(
                                  secondSeed,
                                  textAlign: TextAlign.center,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      color: isSecond ? MyColor.whiteColor : secondSeed != secondId ?  MyColor.whiteColor : MyColor.dotBoarderColor
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                int index = newList.indexWhere((element) => element == thardSeed);
                                boolList[index] = false;
                                isThird = false;
                                selectedItem.remove(thardSeed);
                                thardSeed = thardId;
                                thardSelectId = "";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isThird ? MyColor.greenColor : thardSeed != thardId ?  MyColor.redColor : MyColor.transparentColor,
                              ),
                              child: Container(
                                height: 50,
                                alignment: Alignment.center,
                                width: double.maxFinite,
                                decoration: DottedDecoration(
                                    shape: Shape.box,
                                    borderRadius: BorderRadius.circular(10),
                                    color: isThird ? MyColor.whiteColor :  MyColor.dotBoarderColor
                                ),
                                child: Text(
                                  thardSeed,
                                  textAlign: TextAlign.center,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      color: isThird ? MyColor.whiteColor : thardSeed != thardId ?  MyColor.whiteColor : MyColor.dotBoarderColor
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                      ],
                    )
                  ],
                )
              ),
              const SizedBox(height: 15),

              //  Grid View Phrase
              AlignedGridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: newList.length,
                itemBuilder: (context, index) {
                  var list = newList[index];
                  return InkWell(
                    onTap: (){
                      if(firstId == firstSeed){
                        firstSeed = list;
                        selectedItem.add(list);
                        if(widget.selectedParse[0]['name'] == list){
                          isFirst = true;
                          firstSelectId = firstId;
                        }
                        boolList[index] = true;
                        setState(() {});
                      }else if(secondId == secondSeed){
                        secondSeed = list;
                        selectedItem.add(list);
                        if(widget.selectedParse[1]['name'] == list){
                          secondSelectId = secondId;
                          isSecond = true;
                        }
                        boolList[index] = true;
                        setState(() {});
                      }else if(thardId == thardSeed ){
                        thardSeed = list;
                        selectedItem.add(list);
                        if(widget.selectedParse[2]['name'] == list){
                          isThird = true;
                          thardSelectId = thardId;
                        }
                        boolList[index] = true;
                        setState(() {});
                      }
                    },
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColor.darkGrey01Color
                      ),
                      child: Text(
                        "$list",
                        textAlign: TextAlign.center,
                        style: MyStyle.tx18RWhite.copyWith(
                          color:! boolList[index] ? MyColor.mainWhiteColor : MyColor.mainWhiteColor.withOpacity(0.4),
                        ),
                      ),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}


// axis acquire beach trip donkey away feel hood differ rug large noble