import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'AccountRecoveryPhrase.dart';

// ignore: must_be_immutable
class SecureScreen extends StatefulWidget {

  List seedPhrase;
  final bool isNew;
  SecureScreen({super.key,required this.seedPhrase,required this.isNew});

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {

  bool term = false;

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          "Secure your wallet",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 15),

              Text(
                "In the next step you will see an account recovery phrase. This phrase is the only "
                    "way you can recover access to your account if your phone is lost or stolen",
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 18,
                    color: MyColor.grey01Color
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 25),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: term,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    checkColor: MyColor.mainWhiteColor,
                    activeColor: MyColor.greenColor,
                    side: const BorderSide(
                        color: MyColor.whiteColor,
                        width: 1
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)
                    ),
                    onChanged: (value) {
                      // print(value);
                      setState(() {
                        term = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      "I understand that if I lose my recovery phrase,I will not be able to access my account.",
                      style:MyStyle.tx22RWhite.copyWith(
                          fontSize: 14,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              InkWell(
                onTap: () {
                  if(term) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountRecoveryPhrase(
                              isNew: widget.isNew,
                              seedPhrase: widget.seedPhrase
                          ),
                        )
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 45,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration:term ? MyStyle.buttonDecoration : MyStyle.invalidDecoration,
                  child:  Text(
                    "Get Started",
                    style: MyStyle.tx18BWhite.copyWith(
                      color: term ? MyColor.mainWhiteColor : MyColor.mainWhiteColor.withOpacity(0.4)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}
