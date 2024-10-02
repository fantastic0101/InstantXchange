import 'dart:ui';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import '../../../../Values/MyStyle.dart';

// ignore: must_be_immutable
class WalletInfoScreen extends StatefulWidget {

  String  accountId,name;
  List? seedPhare;

  WalletInfoScreen({
    super.key,
    required this.accountId,
    required this.seedPhare,
    required this.name,
  });

  @override
  State<WalletInfoScreen> createState() => _WalletInfoScreenState();
}

class _WalletInfoScreenState extends State<WalletInfoScreen> {

  bool showPhrase = false;
  TextEditingController nameController = TextEditingController();

  Future<void> secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    super.initState();
    secureScreen();
    getAllACKey();
  }

  getAllACKey()async {
    DbAccountAddress.dbAccountAddress.getAccountAddress(widget.accountId);
    nameController.text = widget.name;
    setState(() {});
    // isListSelected = List.filled(DbAccountAddress.dbAccountAddress.allAccountAddress.length, false);
  }

  @override
  void dispose(){
    super.dispose();
    secureScreenOff();
  }

  Future<void> secureScreenOff() async {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }


  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
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
          "Wallets",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        child: Column(
          children: [

            const SizedBox(height: 10),

            // name text filed
            TextFormField(
              controller: nameController,
              readOnly: true,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: MyColor.darkGrey01Color,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: MyColor.boarderColor,
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: MyColor.boarderColor,
                    )
                ),
              ),
            ),
            SizedBox(height: height * 0.09),

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
                    itemCount: widget.seedPhare!.length,
                    itemBuilder: (context, index) {
                      var list =widget.seedPhare![index];
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
                FlutterClipboard.copy(widget.seedPhare!.join(" ")).then((value) {
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
          ],
        ),
      ),
    );
  }
}
