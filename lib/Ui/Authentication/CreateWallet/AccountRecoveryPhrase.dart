import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'VerifyRecoveryPhrase.dart';
import 'package:clipboard/clipboard.dart';

// ignore: must_be_immutable
class AccountRecoveryPhrase extends StatefulWidget {
  List seedPhrase;
  final bool isNew;

  AccountRecoveryPhrase({
    super.key,
    required this.seedPhrase,
    required this.isNew
  });

  @override
  State<AccountRecoveryPhrase> createState() => _AccountRecoveryPhraseState();
}

class _AccountRecoveryPhraseState extends State<AccountRecoveryPhrase> {

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }


  @override
  void initState() {
    super.initState();
    secureScreen();
  }

  @override
  void dispose(){
    super.dispose();
    secureScreenOff();
  }

  Future<void> secureScreenOff() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }


  bool showPhrase = false;
  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {

              var seedPhase = widget.seedPhrase;

              var random =  Random();
              List randomFive = [];
              for(int i=0;randomFive.length < 3 ;i++){

                int index = random.nextInt(seedPhase.length);
                String element = seedPhase[index];

                var test = {
                  "id": index+1,
                  "name": element
                };

                //print(test);

                int a = randomFive.indexWhere((element) => element['id'] == test['id']);
                //  print("Index = $a");

                if(a != -1){

                  //print(randomFive.toString());

                }
                else{
                  randomFive.add(test);
                }
              }

              //print(randomFive);

              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerifyRecoveryPhrase(
                        seedPhrase: widget.seedPhrase,
                        selectedParse: randomFive,
                        isNew:widget.isNew,
                      )
                  )
              );

            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              margin: const EdgeInsets.only(left: 12,right: 12,bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: MyStyle.buttonDecoration,
              child:  const Text(
                "Continue",
                style: MyStyle.tx18BWhite
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
        title: const Text(
          "Account Recovery Phrase",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 15),

                // subTitle
                // Text(
                //   "Select each word in the order it was presented to you",
                //   textAlign: TextAlign.center,
                //   style:MyStyle.tx22RWhite.copyWith(
                //       fontSize: 18,
                //       color: MyColor.grey01Color
                //   ),
                // ),
                const SizedBox(height: 22),

                //  Grid View Phrase
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: MyColor.darkGreyColor,
                  ),
                  child: Stack(
                    children: [
                      AlignedGridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.seedPhrase.length,
                        itemBuilder: (context, index) {
                          var list = widget.seedPhrase[index];
                          return Container(
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColor.backgroundColor
                            ),
                            child: Text(
                              "${index+1} $list",
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite,
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible: !showPhrase,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              showPhrase = !showPhrase;
                            });
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                  width: width,
                                  height: 260,
                                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: MyColor.mainWhiteColor.withOpacity(0.001)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.visibility_off,
                                        color: MyColor.mainWhiteColor,
                                        size: 35,
                                      ),
                                      const SizedBox(height: 20),

                                      Text(
                                        'Tap to reveal you seed \nphrase',
                                        textAlign: TextAlign.center,
                                        style: MyStyle.tx28BYellow.copyWith(
                                            color: MyColor.mainWhiteColor,
                                            fontSize: 21
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Text(
                                        'Make sure no one is watching your screen',
                                        textAlign: TextAlign.center,
                                        style: MyStyle.tx22RWhite.copyWith(
                                            fontSize: 15
                                        ),
                                      ),

                                      const SizedBox(height: 25),

                                    ],
                                  ),
                                ),
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // copy button
                InkWell(
                  onTap: () {
                    FlutterClipboard.copy(widget.seedPhrase.join(" ")).then((value) {
                      Helper.dialogCall.showToast(context, "Copied");
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: MyColor.darkGreyColor,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copy,
                          color: MyColor.mainWhiteColor,
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Copy",
                          style: MyStyle.tx18RWhite,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // do not shared
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                  decoration: BoxDecoration(
                    color: MyColor.orange01Color,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "DO NOT ",
                                    style:MyStyle.tx28BYellow.copyWith(
                                      fontSize: 18,
                                      color: MyColor.whiteColor
                                    )
                                ),
                                const TextSpan(
                                    text: "share your recovery.",
                                    style:MyStyle.tx18RWhite
                                ),
                              ]
                          )
                      ),
                      const SizedBox(height: 6),

                      Text(
                        "If someone has your recovery phrase,"
                            "they will have full control of  your wallet.",
                        style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 17.5
                        ),
                      )
                    ],
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
