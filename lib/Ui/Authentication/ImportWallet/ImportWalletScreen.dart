
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../LocalDb/Local_Account_address.dart';
import '../../../Provider/Token_Provider.dart';
import '../../Dashboard/DashboardScreen.dart';

class ImportWalletScreen extends StatefulWidget {
  bool isNew;
  ImportWalletScreen({
    super.key,
    required this.isNew
  });

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {

  TextEditingController phraseController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;

  bool showPassword = true;
  bool fingerBool = false;

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }


  Future<void> secureScreenOff() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);

    super.initState();

    secureScreen();
  }

  @override
  void dispose(){
    super.dispose();
    secureScreenOff();
  }

  bool isLoading = false;

  String deviceId = "";

  importAccount() async {
    setState(() {
      isLoading = true;
    });

    await DbNetwork.dbNetwork.getNetwork();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    //print(deviceId);

    var data = {
      "name": "MainWallet",
      "device_id": deviceId,
      "type": "mnemonic",
      "password": pinCodeController.text,
      "mnemonic":  phraseController.text.trim(),
    };

    // print("initCreateWallet");
    // print(jsonEncode(data));

    await accountProvider.addAccount(data, '/initCreateWallet');
    if (accountProvider.isSuccess == true) {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('isLogin', 'true');
      sharedPreferences.setInt('account', 1);
      sharedPreferences.setString('password', pinCodeController.text);
      sharedPreferences.setBool('fingerOn',fingerBool);

      // print("accountProvider.accountData === > ${accountProvider.accountData.length}");
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

        // print("create account db call");
        await DBAccountProvider.dbAccountProvider.createAccount(
            "${accountProvider.accountData[i]["id"]}",
            accountProvider.accountData[i]["device_id"],
            accountProvider.accountData[i]["name"],
            accountProvider.accountData[i]["mnemonic"]
        );

      }

      getAccount();

    } else {

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: "Invalid Seed Phrase",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0
      );

    }
  }

  getAccount() async {
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    getToken();
  }


  // var currency;
  getToken() async {
    for (int i = 0; i < DBAccountProvider.dbAccountProvider.newAccountList.length; i++) {

      await DbAccountAddress.dbAccountAddress.getAccountAddress(DBAccountProvider.dbAccountProvider.newAccountList[i].id);
      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;

      }
      //print(json.encode(data));
      await tokenProvider.getAccountToken(data, '/getAccountTokens', DBAccountProvider.dbAccountProvider.newAccountList[i].id);

    }


    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()
      ),(route) => false,
    );

    setState(() {
      isLoading = false;
    });
  }



  TextEditingController nameController = TextEditingController();
  newImportAccount() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    //print(deviceId);

    var data = {
      "name": nameController.text,
      "device_id": deviceId,
      "type": "mnemonic",
      "password": "",
      "mnemonic":  phraseController.text,
    };

    // print(jsonEncode(data));

    await accountProvider.addAccount(data, '/createWallet');
    if (accountProvider.isSuccess == true) {

      // print(accountProvider.accountData);
      for(int j=0; j<DbNetwork.dbNetwork.networkList.length; j++){

        await DbAccountAddress.dbAccountAddress.createAccountAddress(
            accountProvider.accountData[0]["id"],
            accountProvider.accountData[0][DbNetwork.dbNetwork.networkList[j].publicKeyName],
            accountProvider.accountData[0][DbNetwork.dbNetwork.networkList[j].privateKeyName],
            DbNetwork.dbNetwork.networkList[j].publicKeyName,
            DbNetwork.dbNetwork.networkList[j].privateKeyName,
            DbNetwork.dbNetwork.networkList[j].id,
            DbNetwork.dbNetwork.networkList[j].name
        );

      }

      await DBAccountProvider.dbAccountProvider.createAccount(
          "${accountProvider.accountData[0]["id"]}",
          accountProvider.accountData[0]["device_id"],
          accountProvider.accountData[0]["name"],
          accountProvider.accountData[0]["mnemonic"]
      );

      newAccount("${accountProvider.accountData[0]["id"]}");

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('accountId', "${accountProvider.accountData[0]["id"]}");
      sharedPreferences.setString('accountName', accountProvider.accountData[0]["name"]);


    } else {

      setState(() {
        isLoading = false;
      });

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Invalid Seed Phrase");

    }
  }

  newAccount(String acId) async {
    // await DBAccountProvider.dbAccountProvider.getAllAccount();
    newGetToken(acId);
  }

  newGetToken(String accountId) async {
    await DbAccountAddress.dbAccountAddress.getAccountAddress(accountId);

    var data = {};

    for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
      data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
    }
    await tokenProvider.getAccountToken(data, '/getAccountTokens', accountId);


    // ignore: use_build_context_synchronously
    Navigator.pop(context,"refresh");
    Navigator.pop(context,"refresh");

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    return Scaffold(

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
          widget.isNew
              ?
          InkWell(
            onTap: () {
              if(phraseController.text.isNotEmpty && nameController.text.isNotEmpty) {
                newImportAccount();
              }else{
                Helper.dialogCall.showToast(context, "Please provider all details");
              }
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(15,0,15,15),
              alignment: Alignment.center,
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: phraseController.text.isNotEmpty && nameController.text.isNotEmpty
                  ?
              MyStyle.buttonDecoration
                  :
              MyStyle.invalidDecoration,

              child: Text(
                "Import wallet",
                style:  MyStyle.tx18BWhite.copyWith(
                    color: phraseController.text.isNotEmpty && nameController.text.isNotEmpty
                        ?
                    MyColor.mainWhiteColor
                        :
                    MyColor.mainWhiteColor.withOpacity(0.4)
                ),
              ),
            ),
          )
              :
          InkWell(
            onTap: () {
              if(phraseController.text.isNotEmpty && pinCodeController.text.isNotEmpty) {
                importAccount();
              }else{
                Helper.dialogCall.showToast(context, "Please provider all details");
              }
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(15,0,15,15),
              alignment: Alignment.center,
              height: 45,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: phraseController.text.isNotEmpty && pinCodeController.text.isNotEmpty
                  ?
              MyStyle.buttonDecoration
                  :
              MyStyle.invalidDecoration,

              child: Text(
                "Import wallet",
                style:  MyStyle.tx18BWhite.copyWith(
                    color: phraseController.text.isNotEmpty && pinCodeController.text.isNotEmpty
                        ?
                    MyColor.mainWhiteColor
                        :
                    MyColor.mainWhiteColor.withOpacity(0.4)
                ),
              ),
            ),
          ),


          SizedBox(height: Platform.isIOS ? 10 : 5),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: MyColor.mainWhiteColor,
            size: 20,
          ),
        ),
        title: const Text(
          "Import Wallet",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SizedBox(
          height: height,
          width: width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 22),

                Text(
                  "Enter the 12 recovery phrase your wew given when you created your accounts",
                  style:MyStyle.tx22RWhite.copyWith(
                      fontSize: 18,
                      color: MyColor.grey01Color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.fromLTRB(18, 25, 18, 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: MyColor.darkGrey01Color,
                      border: Border.all(
                          color: MyColor.boarderColor,
                          width: 0.8
                      )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 15),
                      TextFormField(
                        textAlign: TextAlign.center,
                        controller: phraseController,
                        cursorColor: MyColor.greenColor,
                        style: MyStyle.tx18RWhite,
                        maxLines: 3,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Recovery Phrase",
                          hintStyle:MyStyle.tx22RWhite.copyWith(
                              fontSize: 18,
                              color: MyColor.whiteColor.withOpacity(0.7)
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                      InkWell(
                        onTap: () async {
                          ClipboardData? data = await Clipboard.getData('text/plain');
                          String? value = data?.text.toString();

                          List list = value!.trim().split(" ");
                          if(list.length == 12 || list.length == 24){

                            setState(() {
                              phraseController.text = value;
                              //seedList = value.split(" ");
                            });

                          }
                          else{

                            Fluttertoast.showToast(
                                msg: "Invalid_Seed_Phrase !!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );

                          }
                        },
                        child:  Text(
                          "Paste",
                          style:MyStyle.tx22RWhite.copyWith(
                              fontSize: 18
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Password TextFiled
                Visibility(
                  visible: !widget.isNew,
                  child: TextFormField(
                    controller: pinCodeController,
                    obscureText: showPassword,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter login password";
                      }else{
                        return null;
                      }
                    },
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Passwords",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15
                        ),
                        suffixIcon: showPassword
                            ?
                        IconButton(
                            onPressed: (){
                              setState(() {
                                showPassword = false;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility,
                              color: MyColor.mainWhiteColor,
                            )
                        )
                            :
                        IconButton(
                            onPressed: (){
                              setState(() {
                                showPassword = true;
                              });
                            },
                            icon: const Icon(
                              Icons.visibility_off,
                              color: MyColor.mainWhiteColor,
                            )
                        )
                    ),
                  ),
                ),
                SizedBox(height: widget.isNew ? 0 : 22),

                // Name TextFiled
                Visibility(
                  visible: widget.isNew,
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter wallet name";
                      }else{
                        return null;
                      }
                    },
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Wallet Name",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15
                        ),
                    ),
                  ),
                ),
                SizedBox(height: widget.isNew ? 0 : 10),

                // FingerPrint
                Visibility(
                  visible: !widget.isNew,
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        fingerBool = !fingerBool;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                              color: fingerBool ? MyColor.greenColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                width: 1.5,
                                color: fingerBool ?  MyColor.greenColor : MyColor.whiteColor.withOpacity(0.4)
                              )
                          ),
                          child: fingerBool ? const Center(child: Icon(Icons.check,size: 18,color: Colors.white,)) : const SizedBox(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Sign in with FaceID and Finger Print",
                            style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14,
                                color: fingerBool ? MyColor.whiteColor : MyColor.greyColor
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );

  }
}
