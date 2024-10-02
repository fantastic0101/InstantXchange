import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SecureScreen.dart';

class CreatePassword extends StatefulWidget {
  final bool isNew;
  const CreatePassword({super.key,required this.isNew});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {

  late AccountProvider accountProvider;
  late TokenProvider tokenProvider;

  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController rePassController = TextEditingController();

  bool showPassword = true,showRePassword = true;
  final formKey = GlobalKey<FormState>();

  String deviceId = "",phraseLength = "12";
  bool isLoading = false;
  bool fingerBool = false;

  importAccount() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;


    var data = {
      "name": nameController.text.isEmpty ? "Main Wallet" : nameController.text,
      "device_id": deviceId,
      "type": "new",
      "password": widget.isNew ? "" : passController.text,
      "words":12,
      "mnemonic": ""
    };

    // print(jsonEncode(data));

    await accountProvider.addAccount(data, widget.isNew ? '/createWallet' : '/initCreateWallet');
    if (accountProvider.isSuccess == true) {

      if(!widget.isNew) {
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('isLogin', 'false');
        sharedPreferences.setInt('account', 1);
        sharedPreferences.setString('password', passController.text);
        sharedPreferences.setBool('fingerOn',fingerBool);
      }
      var body = accountProvider.accountData;
      String seedPhase = body/*['accounts']*/[0]['mnemonic'];

      List seedPharse = seedPhase.trim().split(" ");

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SecureScreen(
            seedPhrase: seedPharse,
            isNew: widget.isNew,
          ),
        ),
      );
    } else {

      setState(() {
        isLoading = false;
      });

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Account Create Error");
    }
  }


  @override
  void initState() {
    accountProvider = Provider.of<AccountProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    accountProvider = Provider.of<AccountProvider>(context, listen: true);
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    //rule garment lens cat engine observe weasel minimum furnace shoot light tube
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
              if(nameController.text.isNotEmpty) {
                importAccount();
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: nameController.text.isEmpty
                  ?
              MyStyle.invalidDecoration
                  :
              MyStyle.buttonDecoration,
              child: Text(
                  "Continue",
                  style: MyStyle.tx18BWhite.copyWith(
                      color: nameController.text.isEmpty
                          ?
                      MyColor.mainWhiteColor.withOpacity(0.4)
                          :
                      MyColor.mainWhiteColor
                  )
              ),
            ),
          )
              :
          InkWell(
            onTap: () {
              if(formKey.currentState!.validate()) {
                importAccount();
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration:  passController.text.isEmpty || rePassController.text.isEmpty
                  ?
              MyStyle.invalidDecoration
                  :
              MyStyle.buttonDecoration,
              child: Text(
                  "Continue",
                  style: MyStyle.tx18BWhite.copyWith(
                      color:  passController.text.isEmpty || rePassController.text.isEmpty
                          ?
                      MyColor.mainWhiteColor.withOpacity(0.4)
                          :
                      MyColor.mainWhiteColor
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
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Create your password",
                  style:MyStyle.tx22RWhite,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                Text(
                  "Lock your wallet on this device",
                  style:MyStyle.tx22RWhite.copyWith(
                      fontSize: 18,
                      color: MyColor.grey01Color
                  ),
                  textAlign: TextAlign.center,
                ),


                const SizedBox(height: 22),

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
                const SizedBox(height: 10),

                Visibility(
                  visible: !widget.isNew,
                  child: TextFormField(
                    controller: passController,
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
                const SizedBox(height: 10),


                Visibility(
                  visible: !widget.isNew,
                  child: TextFormField(
                    controller: rePassController,
                    obscureText: showRePassword,
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter confirm password.";
                      }else if(value != passController.text){
                        return "Confirm password is not matched.";
                      }else{
                        return null;
                      }
                    },
                    decoration: MyStyle.textInputDecoration.copyWith(
                        hintText: "Confirm Passwords",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15
                        ),
                        suffixIcon: showRePassword
                            ?
                        IconButton(
                            onPressed: (){
                              setState(() {
                                showRePassword = false;
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
                                showRePassword = true;
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
                SizedBox(height: widget.isNew ? 0 : 10),

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

              ],
            ),
          ),
        ),
      ),
    );
  }
}
