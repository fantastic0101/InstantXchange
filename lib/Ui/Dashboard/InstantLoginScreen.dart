import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class InstantLoginScreen extends StatefulWidget {
  const InstantLoginScreen({super.key});

  @override
  State<InstantLoginScreen> createState() => _InstantLoginScreenState();
}

class _InstantLoginScreenState extends State<InstantLoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailCodeController = TextEditingController();

  late BuySellProvider buySellProvider;
  
  getVerificationCode(context)async{
    var params = {
      "action":"login",
      "email":emailController.text.trim(),
      "password":passController.text.trim(),
      "mail_verification_code":"send",
      "auth":"p1~\$*)Ze(@"
    };
    await buySellProvider.getLoginOTPApi(params, context);
  }


  loginApi(context)async{
    var params = {
      "action":"login",
      "email":emailController.text.trim(),
      "password":passController.text.trim(),
      "mail_verification_code":emailCodeController.text.trim(),
      "auth":"p1~\$*)Ze(@"
    };
    await buySellProvider.getLogIn(params, context,emailController.text.trim());

  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    super.initState();
  }


  final formKey  = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    final dashProvider = Provider.of<DashboardProvider>(context);
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // instantExchangers images
              Center(
                child: Image.asset(
                  "assets/images/dashboard/instantExchangers.png",
                  width: width * 0.4,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 35),

              // title for purchase
              Text(
                "Purchase Perfect Money, Bitcoin, Tron, USDT, and more using "
                    "Naira bank transfers. Powered by InstantExchangers.",
                textAlign: TextAlign.center,
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 15
                ),
              ),
              const SizedBox(height: 45),

              // SignIn text
              Text(
                "SignIn",
                textAlign: TextAlign.center,
                style: MyStyle.tx18RWhite.copyWith(
                    fontSize: 25
                ),
              ),
              const SizedBox(height: 20),

              // email filed
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                cursorColor: MyColor.greenColor,
                style: MyStyle.tx18RWhite,
                validator: (value) {
                  RegExp regExp =
                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if(value!.isEmpty){
                    return "Please enter your email.";
                  }else if(!regExp.hasMatch(value)){
                    return "Please enter valid email id.";
                  }else{
                    return null;
                  }
                },
                decoration: MyStyle.textInputDecoration2.copyWith(
                    hintText: "Email address",
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15)
                ),
              ),
              const SizedBox(height: 20),

              //password filed
              TextFormField(
                controller: passController,
                obscureText:dashProvider.showPassword,
                cursorColor: MyColor.greenColor,
                style: MyStyle.tx18RWhite,
                validator: (value) {
                  if(value!.isEmpty){
                    return "Please enter your password.";
                  }else{
                    return null;
                  }
                },
                decoration: MyStyle.textInputDecoration2.copyWith(
                    hintText: "Passwords",
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                    suffixIcon: dashProvider.showPassword
                        ?
                    IconButton(
                        onPressed: (){
                          dashProvider.changeBuyShowPassword(false);
                        },
                        icon: const Icon(
                          Icons.visibility,
                          color: MyColor.mainWhiteColor,
                        )
                    )
                        :
                    IconButton(
                        onPressed: (){
                          dashProvider.changeBuyShowPassword(true);
                        },
                        icon: const Icon(
                          Icons.visibility_off,
                          color: MyColor.mainWhiteColor,
                        )
                    )
                ),
              ),
              const SizedBox(height: 20),

              Visibility(
                visible: buySellProvider.showOtpText,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: TextFormField(
                    controller: emailCodeController,
                    cursorColor: MyColor.greenColor,
                    style: MyStyle.tx18RWhite,
                    validator: (value) {
                      if(value!.isEmpty){
                        return "Please enter your Verification code.";
                      }else{
                        return null;
                      }
                    },
                    decoration: MyStyle.textInputDecoration2.copyWith(
                        hintText: "Verification code",
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15)
                    ),
                  ),
                ),
              ),

              // login button
              buySellProvider.getOtpBool || buySellProvider.isLoginLoader
                  ?
              Helper.dialogCall.showLoader()
                  :
              InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if(!buySellProvider.showOtpText) {
                    getVerificationCode(context);
                  }else{
                    loginApi(context);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 45,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: MyStyle.buttonDecoration,
                  child: Text(
                    buySellProvider.loginButtonText,
                    style: MyStyle.tx18BWhite,
                  ),
                ),
              ),


              const SizedBox(height: 25),

              //Forget Your Password?
              InkWell(
                onTap: () {
                  launchUrl(
                    Uri.parse("https://instantexchangers.net/recover/personal"),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Text(
                  "Forget Your Password?",
                  textAlign: TextAlign.center,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
              ),
              const SizedBox(height: 8),

              //Register!
              InkWell(
                onTap: () {
                  launchUrl(
                    Uri.parse("https://instantexchangers.net/register"),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child : Text(
                  "Register!",
                  textAlign: TextAlign.center,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
