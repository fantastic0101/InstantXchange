import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Ui/Authentication/CreateWallet/CreatePassword.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'ImportWallet/ImportWalletScreen.dart';

class WelcomeScreen extends StatefulWidget {
  bool isNew;
  WelcomeScreen({super.key, required this.isNew});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Size imageSize = const Size(45, 45);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Visibility(
              visible: widget.isNew,
              child: Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    height: 25,
                    width: 25,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: MyColor.mainWhiteColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            Spacer(),

            // app logo
            Image.asset(
              "assets/images/logo.png",
              height: 40,
              width: width * 0.4,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),

            // welcome text
            const Text(
              "Welcome!",
              style: MyStyle.tx22RWhite,
            ),
            const SizedBox(height: 30),

            // title text
            Text(
              "Trade and convert cryptocurrency to Naira securely and privately",
              style: MyStyle.tx22RWhite.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // crypto icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/bitcoin.png",
                  height: imageSize.height,
                  width: imageSize.width,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Image.asset(
                  "assets/images/bnb.png",
                  height: imageSize.height,
                  width: imageSize.width,
                  color: MyColor.yellowColor,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    color: MyColor.mainWhiteColor,
                    child: Image.asset(
                      "assets/images/coins.png",
                      height: imageSize.height,
                      width: imageSize.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    color: MyColor.mainWhiteColor,
                    child: Image.asset(
                      "assets/images/litecoin.png",
                      height: imageSize.height,
                      width: imageSize.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    color: MyColor.mainWhiteColor,
                    child: Image.asset(
                      "assets/images/tron.png",
                      height: imageSize.height,
                      width: imageSize.width,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // And many more coins....
            Text(
              "And many more coins....",
              style: MyStyle.tx22RWhite
                  .copyWith(fontSize: 13, color: MyColor.orangeColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            // create wallet
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreatePassword(isNew: widget.isNew),
                    ));
              },
              child: Container(
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: MyStyle.buttonDecoration,
                child: const Text(
                  "Create a new wallet",
                  style: MyStyle.tx18RWhite,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // i've got a recovery phrase
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImportWalletScreen(isNew: widget.isNew),
                    ));
              },
              child: const Text(
                "I've got a recovery phrase",
                style: MyStyle.tx18RWhite,
              ),
            ),
            SizedBox(height: height * 0.15),
            Spacer(),
          ],
        ),
      )),
    );
  }
}
