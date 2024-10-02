
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {

  bool fingerPrint = false;
  bool passwordType = false;

  String savePassword = "",savePasscode = "";
  bool pinNotSave = false;
  bool hideSetCode = true,hideSetReCode = true;
  late AccountProvider accountProvider;

  // used in update old password
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController reNewPassController = TextEditingController();
  String oldPassError = "",newPassError = "", reNewPassError = "";
  bool hideOldPass =true,hideNewPass =true,hideReNewPass = true;

  // use in set new pinCode
  TextEditingController setPassCodeController = TextEditingController();
  TextEditingController setRePassCodeController = TextEditingController();
  String newPassMess = "",newRePassMess = "";


  // used in update old passcode
  TextEditingController oldPassCodeController = TextEditingController();
  TextEditingController newPassCodeController = TextEditingController();
  TextEditingController reNewPassCodeController = TextEditingController();
  String oldCodeError = "",newCodeError = "", reNewCodeError = "";
  bool hideOldCode =true,hideNewCode =true,hideReNewCode = true;


  getData()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      fingerPrint = sharedPreferences.getBool('fingerOn') ?? false;
      passwordType = sharedPreferences.getBool('passwordType') ?? false;
      // var deviceId = sharedPreferences.getString('deviceId');
      savePassword = sharedPreferences.getString('password') ?? "";

      savePasscode = sharedPreferences.getString('passcode') ?? "";
      // print(" deviceId $savePassword ");
    });
  }

  final newPassCodeKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final passcodeFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  changePasswordApi(bool passwordChange,context) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var deviceId = sharedPreferences.getString('deviceId');
    var oldPassword = "",  newPassword = "";

    if(passwordChange){
      oldPassword = passwordType ? savePasscode : savePassword;
    }else {
       oldPassword = !passwordType ? savePasscode : savePassword;
    }


    if(!passwordChange){
      newPassword =  passwordType ? savePasscode : savePassword;
    }else{
      newPassword = passwordType ? newPassCodeController.text : newPassController.text;
    }

    // print("newPassword-----> $newPassword");
    // print("oldPassword-----> $oldPassword");
    var data = {
      "device_id":deviceId,
      "old_password":oldPassword,
      "new_password":pinNotSave ? setPassCodeController.text : newPassword,
    };

    // print(json.encode(data));
    await accountProvider.forgotPassword(data, "/changePassword");

    if(accountProvider.isPassword){
      sharedPreferences.setBool("passwordType", true);
      if(passwordType){
         sharedPreferences.setString('passcode',newPassword);
         sharedPreferences.setBool('passwordType',passwordType);
      }else{
        sharedPreferences.setString('password',newPassword);
        sharedPreferences.setBool('passwordType',passwordType);
      }
      if(pinNotSave){
        sharedPreferences.setString('passcode',setPassCodeController.text);
        savePasscode = sharedPreferences.getString('passcode')?? "";
        setState(() {
          passwordType = true;
          sharedPreferences.setBool('passwordType',passwordType);

          pinNotSave = false;
        });
        Helper.dialogCall.showToast(context, "A New Passcode has been set");
      }
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context,listen: false);
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    accountProvider = Provider.of<AccountProvider>(context,listen: true);

    return  Scaffold(
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
          "Security",
          style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // touchId and FaceId toggle button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color:MyColor.darkGrey01Color
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Use Enhanced Security",
                            style: MyStyle.tx18RWhite,
                          ),
                        ),

                        FlutterSwitch(
                          width: 50.0,
                          height: 24.0,
                          toggleSize: 15.0,
                          valueFontSize: 0.0,
                          borderRadius: 30.0,
                          inactiveColor: MyColor.boarderColor,
                          activeColor: MyColor.greenColor,
                          value: fingerPrint,
                          showOnOff: false,
                          onToggle: (val) async {
                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                            setState(() {
                              fingerPrint = val;
                              sharedPreferences.setBool('fingerOn',fingerPrint);
                            });

                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Use PassCode, TouchID or FaceID of your device to secure "
                          "the application at different key areas like launching"
                          " the app, sending tokens or changing wallets!",
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 14,
                          color: MyColor.grey01Color
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // password container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color:MyColor.darkGrey01Color
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Use App Password Or PassCode",
                      style: MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            !passwordType ? "Password is Enable" : "Passcode is Enable",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14
                            ),
                          ),
                        ),
                        FlutterSwitch(
                          width: 50.0,
                          height: 24.0,
                          toggleSize: 15.0,
                          valueFontSize: 0.0,
                          borderRadius: 30.0,
                          inactiveColor: MyColor.boarderColor,
                          inactiveToggleColor: MyColor.greenColor,
                          activeColor: MyColor.greenColor,
                          value: passwordType,
                          showOnOff: false,
                          onToggle: (val) async {

                            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                            var savePince2 = sharedPreferences.getString("passcode")??"";

                            if(savePince2 == ""){
                              setState(() {
                                pinNotSave = true;
                              });
                              // ignore: use_build_context_synchronously
                              Helper.dialogCall.showToast(context, "Please set your passcode.");
                            }
                            else{
                              setState(() {
                                passwordType = val;
                                changePasswordApi(false,context);
                              });
                            }

                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "The App PassCode helps you keep your wallet secured and safe.",
                      style:MyStyle.tx18RWhite.copyWith(
                          fontSize: 13,
                          color: MyColor.grey01Color
                      ),
                    ),
                    const SizedBox(height: 15),

                    pinNotSave
                        ?
                    // set new passcode text widgets
                    Form(
                      key: newPassCodeKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // new passcode
                            TextFormField(
                                obscureText: hideSetCode,
                                readOnly: accountProvider.passwordLoading,
                                controller: setPassCodeController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6)
                                ],
                                validator: (value) {
                                  if(value!.isEmpty){
                                    newPassMess = "Enter your passcode";
                                    return "";
                                  }else if(setPassCodeController.text.length < 6){
                                    newRePassMess = "Passcode must be 6 digit";
                                    return "";
                                  }else if(value != setRePassCodeController.text){
                                    newRePassMess = "Passcode not matched!";
                                    return "";
                                  }else{
                                    newPassMess = "";
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  if(value.isEmpty){
                                    newPassMess = "Enter your passcode";
                                  }else if(value != setRePassCodeController.text){
                                    newRePassMess = "Passcode not matched!";
                                  }else{
                                    newPassMess = "";
                                  }
                                  setState(() {});
                                },
                                keyboardType: TextInputType.number,
                                cursorColor: MyColor.greenColor,
                                style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                                ),
                                decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText:"Enter new passcode",
                                    errorStyle: const TextStyle(height: 0,fontSize: 0),
                                    suffixIcon: hideSetCode
                                        ?
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            hideSetCode = false;
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
                                            hideSetCode = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off,
                                          color: MyColor.mainWhiteColor,
                                        )
                                    )
                                )
                            ),
                            Visibility(
                                visible: newPassMess.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0,left: 10),
                                  child: Text(
                                    newPassMess,
                                    style: MyStyle.tx18BWhite.copyWith(
                                        color: MyColor.redColor,
                                        fontSize: 14
                                    ),
                                  ),
                                )
                            ),
                            const SizedBox(height: 15),

                            //Confirm new passcode
                            TextFormField(
                                readOnly: accountProvider.passwordLoading,
                                obscureText: hideSetReCode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6)
                                ],
                                controller: setRePassCodeController,
                                cursorColor: MyColor.greenColor,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                                validator: (value) {
                                    if(value!.isEmpty){
                                      newRePassMess = "Enter your passcode";
                                      return "";
                                    }else if(setPassCodeController.text.length < 6){
                                      newRePassMess = "Passcode must be 6 digit";
                                      return "";
                                    }else if(setPassCodeController.text != value){
                                      newRePassMess = "Passcode not matched!";
                                      return "";
                                    }else{
                                      newRePassMess = "";
                                      return null;
                                    }
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if(value.isEmpty){
                                      newRePassMess = "Enter your passcode";
                                    }else if(setPassCodeController.text != value){
                                      newRePassMess = "Passcode not matched!";
                                    }else{
                                      // print("object");
                                      newRePassMess = "";
                                    }
                                  });
                                },
                                decoration: MyStyle.textInputDecoration.copyWith(
                                    hintText: "Confirm new passcode",
                                    errorStyle: const TextStyle(height: 0,fontSize: 0),

                                    suffixIcon: hideSetReCode
                                        ?
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            hideSetReCode = false;
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
                                            hideSetReCode = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off,
                                          color: MyColor.mainWhiteColor,
                                        )
                                    )
                                )
                            ),
                            Visibility(
                                visible: newRePassMess.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0,left: 10),
                                  child: Text(
                                    newRePassMess,
                                    style: MyStyle.tx18BWhite.copyWith(
                                        color: MyColor.redColor,
                                        fontSize: 14
                                    ),
                                  ),
                                )
                            ),
                          ]
                      ),
                    )
                        :
                    passwordType
                        ?
                    // passcode text widgets
                    Form(
                      key: passcodeFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //old passcode
                          Visibility(
                            visible: savePasscode.isNotEmpty ,
                            child: TextFormField(
                                readOnly: accountProvider.passwordLoading,
                                obscureText: hideOldCode,
                                validator: (value) {
                                  if(value!.isEmpty){
                                    oldCodeError = "please enter you passcode";
                                    return "";
                                  }else if(value != savePasscode){
                                    oldCodeError = "Entered old passcode not matched!";
                                    return "";
                                  }else{
                                    oldCodeError = "";
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  if(value.isEmpty){
                                    oldCodeError = "please enter you passcode";
                                  }else if(value != savePasscode){
                                    // print("savePasscode $savePasscode");

                                    oldCodeError = "Entered old passcode not matched!";
                                  }else{
                                    oldCodeError = "";
                                  }
                                  setState(() {});
                                },
                                inputFormatters:  [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6)
                                ],
                                keyboardType: TextInputType.number,
                                controller: oldPassCodeController,
                                cursorColor: MyColor.greenColor,
                                style: MyStyle.tx18RWhite,
                                decoration: MyStyle.textInputDecoration.copyWith(
                                    hintText: "Enter old passcode",
                                    errorStyle: const TextStyle(height: 0,fontSize: 0),
                                    suffixIcon: hideOldCode
                                        ?
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            hideOldCode = false;
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
                                            hideOldCode = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off,
                                          color: MyColor.mainWhiteColor,
                                        )
                                    )
                                )
                            ),
                          ),
                          Visibility(
                              visible: oldCodeError.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0,left: 10),
                                child: Text(
                                  oldCodeError,
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.redColor,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(height: 15),

                          // new passcode
                          TextFormField(
                              readOnly: accountProvider.passwordLoading,
                              controller: newPassCodeController,
                              obscureText: hideNewCode,
                              inputFormatters:[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6)
                              ],
                              validator: (value) {
                                if(value!.isEmpty){
                                  newCodeError = "please enter you passcode";
                                  return "";
                                }else if(value != reNewPassCodeController.text){
                                  newCodeError = "Entered passcode not matched!";
                                  return "";
                                }else{
                                  newCodeError = "";
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                if(value.isEmpty){
                                  newCodeError = "please enter you passcode";
                                }else if(value != reNewPassCodeController.text){
                                  newCodeError = "Entered passcode not matched!";
                                }else{
                                  newCodeError = "";
                                }
                                setState(() {});
                              },
                              keyboardType: TextInputType.number,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText: "Enter new passcode",
                                  errorStyle: const TextStyle(height: 0,fontSize: 0),
                                  suffixIcon: hideNewCode
                                      ?
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          hideNewCode = false;
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
                                          hideNewCode = true;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.visibility_off,
                                        color: MyColor.mainWhiteColor,
                                      )
                                  )
                              )
                          ),
                          Visibility(
                              visible: newCodeError.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0,left: 10),
                                child: Text(
                                  newCodeError,
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.redColor,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(height: 15),

                          //Confirm new passcode
                          TextFormField(
                              readOnly: accountProvider.passwordLoading,
                              onChanged: (value) {
                                if(value.isEmpty){
                                  reNewCodeError = "please enter you passcode";
                                }else if(value != newPassCodeController.text){
                                  reNewCodeError = "Entered passcode not matched!";
                                }else{
                                  reNewCodeError = "";
                                }
                                setState(() {});
                              },
                              validator: (value) {
                                if(value!.isEmpty){
                                  reNewCodeError = "please enter you passcode";
                                  return "";
                                }else if(value != newPassCodeController.text){
                                  reNewCodeError = "Entered passcode not matched!";
                                  return "";
                                }else{
                                  reNewCodeError = "";
                                  return null;
                                }
                              },
                              keyboardType:TextInputType.number,
                              obscureText: hideReNewCode,
                              inputFormatters:[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6)
                              ],
                              controller: reNewPassCodeController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText:"Confirm new passcode",
                                  errorStyle: const TextStyle(height: 0,fontSize: 0),
                                  suffixIcon: hideReNewCode
                                      ?
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          hideReNewCode = false;
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
                                          hideReNewCode = true;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.visibility_off,
                                        color: MyColor.mainWhiteColor,
                                      )
                                  )
                              )
                          ),
                          Visibility(
                              visible: reNewCodeError.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0,left: 10),
                                child: Text(
                                  reNewCodeError,
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.redColor,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                        :
                    // password text widgets
                    Form(
                      key: passwordFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //old passcode
                          Visibility(
                            visible: savePassword.isNotEmpty,
                            child: TextFormField(
                                readOnly: accountProvider.passwordLoading,
                                keyboardType:TextInputType.text,
                                obscureText: hideOldPass,
                                onChanged: (value) {
                                  if(value.isEmpty){
                                    oldPassError = "please enter you passcode";
                                  }else if(value != savePassword){
                                    // print("savePasscode $savePasscode");

                                    oldPassError = "Entered old passcode not matched!";
                                  }else{
                                    oldPassError = "";
                                  }
                                  setState(() {});
                                },
                                controller: oldPassController,
                                cursorColor: MyColor.greenColor,
                                style: MyStyle.tx18RWhite,
                                decoration: MyStyle.textInputDecoration.copyWith(
                                    hintText: "Enter old password",
                                    errorStyle: const TextStyle(height: 0,fontSize: 0),
                                    suffixIcon: hideOldPass
                                        ?
                                    IconButton(
                                        onPressed: (){
                                          setState(() {
                                            hideOldPass = false;
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
                                            hideOldPass = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.visibility_off,
                                          color: MyColor.mainWhiteColor,
                                        )
                                    )
                                )
                             ),
                           ),
                          Visibility(
                              visible: oldPassError.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0,left: 10),
                                child: Text(
                                  oldPassError,
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.redColor,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(height: 15),

                          // new passcode
                          TextFormField(
                            readOnly: accountProvider.passwordLoading,
                            controller: newPassController,
                              obscureText: hideNewPass,
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                if(value.isEmpty){
                                  newPassError = "please enter you passcode";
                                }else if(value != reNewPassController.text){
                                  newPassError = "Entered passcode not matched!";
                                }else{
                                  newPassError = "";
                                }
                                setState(() {});
                              },
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText:"Enter new password",
                                  errorStyle: const TextStyle(height: 0,fontSize: 0),
                                  suffixIcon: hideNewPass
                                      ?
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          hideNewPass = false;
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
                                          hideNewPass = true;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.visibility_off,
                                        color: MyColor.mainWhiteColor,
                                      )
                                  )
                              )
                           ),
                          Visibility(
                              visible: newPassError.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0,left: 10),
                                child: Text(
                                  newPassError,
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.redColor,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(height: 15),

                          //Confirm new passcode
                          TextFormField(
                            readOnly: accountProvider.passwordLoading,
                              keyboardType: TextInputType.text,
                              obscureText: hideReNewPass,
                              onChanged: (value) {
                                if(value.isEmpty){
                                  reNewPassError = "please enter you passcode";
                                }else if(value != newPassController.text){
                                  reNewPassError = "Entered passcode not matched!";
                                }else{
                                  reNewPassError = "";
                                }
                                setState(() {});
                              },
                              controller: reNewPassController,
                              cursorColor: MyColor.greenColor,
                              style: MyStyle.tx18RWhite,
                              decoration: MyStyle.textInputDecoration.copyWith(
                                  hintText: "Confirm new password",
                                  errorStyle: const TextStyle(height: 0,fontSize: 0),
                                  suffixIcon: hideReNewPass
                                      ?
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          hideReNewPass = false;
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
                                          hideReNewPass = true;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.visibility_off,
                                        color: MyColor.mainWhiteColor,
                                      )
                                  )
                              )
                           ),
                          Visibility(
                              visible: reNewPassError.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0,left: 10),
                                child: Text(
                                  reNewPassError,
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.redColor,
                                      fontSize: 14
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),


                   accountProvider.passwordLoading || isLoading
                        ?
                    Helper.dialogCall.showLoader()
                        :
                    Center(
                      child: InkWell(
                        onTap: () {
                          if(pinNotSave){
                            if(newPassCodeKey.currentState!.validate()){
                              changePasswordApi(true,context);
                            }else{
                              Helper.dialogCall.showToast(context, "Minimum 6 digit code");
                            }
                          }else{
                            if(passwordType){
                              if(passcodeFormKey.currentState!.validate()) {
                                if (oldCodeError.isNotEmpty && newCodeError.isNotEmpty && reNewCodeError.isNotEmpty) {
                                  changePasswordApi(true,context);
                                } else {
                                  Helper.dialogCall.showToast(context, "Minimum 6 digit code");
                                }
                              }
                              else{
                              Helper.dialogCall.showToast(context, "Minimum 6 digit code");
                            }
                            }else{
                              if(passwordFormKey.currentState!.validate()){
                                changePasswordApi(true,context);
                              }else{
                                Helper.dialogCall.showToast(context, "Please filed all details first");
                              }
                            }
                          }
                        },
                        child: Container(
                          height: 45,
                          width: 100,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: MyColor.greenColor
                            )
                          ),
                          child: Text(
                            pinNotSave ? "Set ": "Reset",
                            textAlign: TextAlign.center,
                            style: MyStyle.tx28RGreen.copyWith(
                              fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
