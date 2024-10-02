import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/LoginWithPasscode.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late SharedPreferences sharedPreferences;
  late String deviceId;
  String isLogin = "false";
  bool isLoading = false;

  getDeviceId() async {
    sharedPreferences = await SharedPreferences.getInstance();

    // final deviceInfoPlugin = DeviceInfoPlugin();
    var uuid = const Uuid();
    deviceId = uuid.v1();

    // print("deviceId---> $deviceId");

    /*if(Platform.isAndroid){
      final  deviceInfo = await deviceInfoPlugin.androidInfo;
      deviceId = deviceInfo.id;
      // print("deviceId $deviceId");
    }else{

     final deviceInfo = await deviceInfoPlugin.iosInfo;
     deviceId = deviceInfo.identifierForVendor!;
    }*/

    if (sharedPreferences.getString("deviceId") == null ||
        sharedPreferences.getString("deviceId") == "") {
      setState(() {
        sharedPreferences.setString('deviceId', deviceId);
      });
    }
    getNetwork();
  }

  getNetwork() async {
    await tokenProvider.getNetworks('/getNetworks');
    getAccount();
  }

  getAccount() async {
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    await DbNetwork.dbNetwork.getNetwork();
    // print("get Account List ===> ${DBAccountProvider.dbAccountProvider.newAccountList.length}");
    for (int i = 0;
        i < DBAccountProvider.dbAccountProvider.newAccountList.length;
        i++) {
      await importAccount(
          DBAccountProvider.dbAccountProvider.newAccountList[i].id,
          DBAccountProvider.dbAccountProvider.newAccountList[i].name,
          DBAccountProvider.dbAccountProvider.newAccountList[i].mnemonic);
    }

    checkIfLogin();
  }

  importAccount(id, name, seed) async {
    setState(() {
      isLoading = true;
    });

    var data = {
      "acc_id": "$id",
      "name": "$name",
      "device_id": deviceId,
      "type": "mnemonic",
      "mnemonic": "$seed"
    };

    await accountProvider.addAccount(data, '/iniWalletCheck');

    if (accountProvider.isAccountLoad) {
      await DBAccountProvider.dbAccountProvider.deleteAccount("$id");
      await DbAccountAddress.dbAccountAddress.deleteAccountAddress("$id");

      for (int i = 0; i < accountProvider.accountData.length; i++) {
        for (int j = 0; j < DbNetwork.dbNetwork.networkList.length; j++) {
          await DbAccountAddress.dbAccountAddress.createAccountAddress(
              accountProvider.accountData[i]["id"],
              accountProvider.accountData[i]
                  [DbNetwork.dbNetwork.networkList[j].publicKeyName],
              accountProvider.accountData[i]
                  [DbNetwork.dbNetwork.networkList[j].privateKeyName],
              DbNetwork.dbNetwork.networkList[j].publicKeyName,
              DbNetwork.dbNetwork.networkList[j].privateKeyName,
              DbNetwork.dbNetwork.networkList[j].id,
              DbNetwork.dbNetwork.networkList[j].name);
        }

        await DBAccountProvider.dbAccountProvider.createAccount(
            "${accountProvider.accountData[i]["id"]}",
            accountProvider.accountData[i]["device_id"],
            accountProvider.accountData[i]["name"],
            accountProvider.accountData[i]["mnemonic"]);
      }
    }
  }

  checkIfLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isLogin = sharedPreferences.getString('isLogin') ?? "false";
    if (sharedPreferences.getString('isLogin') != null) {
      var passwordType = sharedPreferences.getBool('passwordType') ?? false;
      if (isLogin == "true") {
        // ignore: use_build_context_synchronously

        if (passwordType) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginWithPassCode()));
        } else {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomeScreen(
                      isNew: false,
                    )));
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                    isNew: false,
                  )));
    }
  }

  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    super.initState();
    getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Image.asset(
          "assets/images/logo.png",
          height: 65,
          width: width * 0.4,
          fit: BoxFit.contain,
        ),
      )),
    );
  }
}
