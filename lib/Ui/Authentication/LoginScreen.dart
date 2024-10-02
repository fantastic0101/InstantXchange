import 'dart:io';
import 'package:flutter/services.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Ex_Transaction_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Sell_History_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Walletv2_provider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:local_auth_ios/types/auth_messages_ios.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../LocalDb/Local_Account_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController passwordController = TextEditingController();

  bool showPassword = true;

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;
  late DashboardProvider dashProvider;

  final LocalAuthentication auth = LocalAuthentication();
  late String deviceId;
  bool fingerOn = false;
  String isLogin = "";

  var errorText = "";
  bool isLoading = false;

  getDeviceId() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      deviceId = sharedPreferences.getString('deviceId')!;
      isLogin = sharedPreferences.getString('isLogin') ?? "";
      fingerOn = sharedPreferences.getBool('fingerOn') ?? false;
    });
    //_authenticate();

    if (isLogin == "true") {
      if (fingerOn == true) {
        _authenticate();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _authorizedAvailable = false;
  Future<void> _authenticate() async {
    bool authenticated = false;

    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face) ||
          availableBiometrics.contains(BiometricType.strong)) {
        _authorizedAvailable = true;
        // Face ID.
      } else if (availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong)) {
        // Touch ID.
        _authorizedAvailable = true;
      }
    } else if (Platform.isAndroid) {
      if (availableBiometrics.contains(BiometricType.fingerprint) ||
          availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.weak)) {
        _authorizedAvailable = true;
      }
    }

    if (_authorizedAvailable == true) {
      try {
        IOSAuthMessages iosStrings = const IOSAuthMessages(
            cancelButton: "cancel",
            goToSettingsButton: "settings",
            goToSettingsDescription: "Please set up your Touch ID",
            lockOut: "Please Re-enable your Touch ID");

        authenticated = await auth.authenticate(
          localizedReason: "Please authenticate to Login your Account",
          authMessages: [iosStrings],
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
            useErrorDialogs: true,
          ),
        );
      } on PlatformException catch (_) {
        setState(() {
          isLoading = false;
        });
      }

      if (authenticated == true) {
        setState(() {
          isLoading = false;
        });

        autologin();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  autologin() async {
    setState(() {
      errorText = "";
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    String? password = sharedPreferences.getString('password');

    var data = {
      "device_id": deviceId,
      "password": "$password",
    };

    // print(json.encode(data));
    await accountProvider.loginAccount(data, '/deviceLogin');
    if (accountProvider.isSuccess == true) {
      getAccount();
    } else {
      setState(() {
        errorText = "Incorrect Password";
        isLoading = false;
      });
    }
  }

  getAccount() async {
    //print("Account");

    await DBAccountProvider.dbAccountProvider.getAllAccount();

    getToken();
  }

  getToken() async {
    for (int i = 0;
        i < DBAccountProvider.dbAccountProvider.newAccountList.length;
        i++) {
      await DbAccountAddress.dbAccountAddress.getAccountAddress(
          DBAccountProvider.dbAccountProvider.newAccountList[i].id);

      var data = {};

      for (int j = 0;
          j < DbAccountAddress.dbAccountAddress.allAccountAddress.length;
          j++) {
        data[DbAccountAddress
                .dbAccountAddress.allAccountAddress[j].publicKeyName] =
            DbAccountAddress
                .dbAccountAddress.allAccountAddress[j].publicAddress;
      }

      await tokenProvider.getAccountToken(
        data,
        '/getAccountTokens',
        DBAccountProvider.dbAccountProvider.newAccountList[i].id,
      );
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(
        "loginTime", "${DateTime.now().add(const Duration(minutes: 1))}");

    if (Utils.pageType == "NewPage" && Utils.wcUrlVal == "") {
      Navigator.pop(context);
    } else {
      if (Utils.pageType == "NewPage" && Utils.wcUrlVal != "") {
        Navigator.pop(context);
      } else {
        // print("object gooing in else");
        dashProvider.changeBottomIndex(0);
        // ignore: use_build_context_synchronously
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => true,
        );
      }
    }
    // ignore: use_build_context_synchronously

    setState(() {
      isLoading = false;
    });
  }

  loginAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;
    // print("object --> $deviceId");
    setState(() {
      errorText = "";
      isLoading = true;
    });

    var data = {
      "device_id": deviceId,
      "password": passwordController.text,
    };

    //print(json.encode(data));

    try {
      await accountProvider.loginAccount(data, '/deviceLogin');
      if (accountProvider.isSuccess == true) {
        getAccount();
      } else {
        setState(() {
          isLoading = false;
        });
        errorText = "Incorrect Password!!";
      }
    } catch (e) {
      errorText = "Incorrect Password!!";
      setState(() {
        isLoading = false;
      });
    }
  }

  deleteAlert() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColor.backgroundColor,
        title: Text("Are you sure?",
            style: MyStyle.tx18BWhite.copyWith(fontSize: 16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber,
              size: 17,
              color: MyColor.yellowColor,
            ),
            Flexible(
              child: Text("Do you want to delete your all accounts",
                  style: MyStyle.tx18RWhite.copyWith(fontSize: 14)),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No", style: MyStyle.tx18RWhite.copyWith(fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAllAccountApi();
            },
            /*Navigator.of(context).pop(true)*/
            child:
                Text("Yes", style: MyStyle.tx18RWhite.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  deleteAllAccountApi() async {
    var data = {"device_id": deviceId};

    await accountProvider.forgotPassword(data, '/forgotPassword');

    if (accountProvider.isPassword == true) {
      await DBAccountProvider.dbAccountProvider.deleteAllAccount();
      await DbAccountAddress.dbAccountAddress.deleteAllAccountAddress();
      await DbExTransaction.dbExTransaction.deleteAllExTransaction();
      await DbSellHistory.dbSellHistory.deleteAllSellHistory();
      await DBTokenProvider.dbTokenProvider.deleteAllToken();
      await DBWalletConnectV2.dbWalletConnectV2.deleteAllWallet();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('isLogin', 'false');
      sharedPreferences.clear();

      createDeviceId();
    }
  }

  createDeviceId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? deviceId = "";
    sharedPreferences = await SharedPreferences.getInstance();

    var uuid = const Uuid();
    deviceId = uuid.v1();

    if (sharedPreferences.getString("deviceId") == null ||
        sharedPreferences.getString("deviceId") == "") {
      setState(() {
        sharedPreferences.setString('deviceId', deviceId!);
      });
    }

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => WelcomeScreen(isNew: false)));
  }

  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    dashProvider = Provider.of<DashboardProvider>(context, listen: false);

    super.initState();

    Future.delayed(Duration.zero, () {
      getDeviceId();
    });
  }

  @override
  Widget build(BuildContext context) {
    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);
    dashProvider = Provider.of<DashboardProvider>(context, listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              child: Column(
                children: [
                  // app image
                  Image.asset(
                    "assets/images/logo.png",
                    height: 60,
                    width: width * 0.4,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 5),

                  // title
                  Text(
                    "Please Enter your password \nto proceed!",
                    textAlign: TextAlign.center,
                    style: MyStyle.tx18RWhite
                        .copyWith(fontSize: 14, color: MyColor.grey01Color),
                  ),
                  SizedBox(height: height * 0.09),

                  //password field
                  TextFormField(
                    controller: passwordController,
                    readOnly: isLoading,
                    obscureText: showPassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter login password";
                      } else {
                        return null;
                      }
                    },
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Passwords",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 15),
                        suffixIcon: showPassword
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.visibility,
                                  color: MyColor.mainWhiteColor,
                                ))
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.visibility_off,
                                  color: MyColor.mainWhiteColor,
                                ))),
                  ),
                  Visibility(
                      visible: errorText.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          errorText,
                          style: MyStyle.tx18BWhite
                              .copyWith(color: MyColor.redColor, fontSize: 14),
                        ),
                      )),
                  const SizedBox(height: 30),

                  // login button
                  isLoading == true
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: MyColor.greenColor,
                        ))
                      : InkWell(
                          onTap: () async {
                            if (passwordController.text.isNotEmpty) {
                              FocusScope.of(context).unfocus();
                              loginAccount();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            margin: const EdgeInsets.only(
                                left: 12, right: 12, bottom: 15),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: MyStyle.buttonDecoration,
                            child: Text("Login",
                                style: MyStyle.tx18BWhite
                                    .copyWith(color: MyColor.mainWhiteColor)),
                          ),
                        ),
                  const SizedBox(height: 15),

                  // reset button
                  InkWell(
                    onTap: () {
                      deleteAlert();
                    },
                    child:
                        const Text("Reset wallet", style: MyStyle.tx18RWhite),
                  ),

                  Visibility(
                    visible: fingerOn,
                    child: InkWell(
                      onTap: () {
                        _authenticate();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Image.asset(
                          "assets/images/fingerprint.png",
                          height: 45,
                          width: 60,
                          fit: BoxFit.contain,
                          color: MyColor.whiteColor,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: height*0.07),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
