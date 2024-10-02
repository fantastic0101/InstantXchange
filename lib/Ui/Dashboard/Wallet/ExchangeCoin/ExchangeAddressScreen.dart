import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';

class ExchangeAddressScreen extends StatefulWidget {
  final String sendAmount;
  const ExchangeAddressScreen({
    super.key,
    required this.sendAmount
  });

  @override
  State<ExchangeAddressScreen> createState() => _ExchangeAddressScreenState();
}

class _ExchangeAddressScreenState extends State<ExchangeAddressScreen> {

  TextEditingController addressController = TextEditingController();

  late ExchangeProvider exchangeProvider;

  var selectedAccountId = "";


  createExchange()async {

    var data = {
      "from": exchangeProvider.sendCoin.ticker.toLowerCase().trim(),
      "to": exchangeProvider.receiveCoin.ticker.toLowerCase().trim(),
      "amount": widget.sendAmount.trim(),
      "address": addressController.text.trim()
    };

    // print(json.encode(data));

    await exchangeProvider.createExchange(
        "/v1/transactions/fixed-rate/${Utils.apiKey}",
        data,context
    );

  }



  addressVerification(context) async {
    var params = {
      "currency":exchangeProvider.receiveCoin.ticker.toLowerCase().trim(),
      "address":addressController.text.trim()
    };
    await exchangeProvider.addressVerification("/v2/validate/address",params,context);
  }


  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    exchangeProvider.isAddressVerify = false;
    exchangeProvider.createExSuccess = false;
    exchangeProvider.statusLoading = false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);

    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          !exchangeProvider.isAddressVerify
              ?
          exchangeProvider.verifyAddressLoading
              ?
          SizedBox(
            height: 50,
            child: Helper.dialogCall.showLoader(),
          )
              :
          InkWell(
            onTap: () {
              if(addressController.text.isNotEmpty) {
                addressVerification(context);
              }else{
                Helper.dialogCall.showToast(context, "Please enter receive address");
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: addressController.text.isEmpty ? MyStyle.invalidDecoration : MyStyle.buttonDecoration,
              child:Text(
                "Verify address",
                style: MyStyle.tx18BWhite.copyWith(
                  color:  addressController.text.isEmpty ? MyColor.mainWhiteColor.withOpacity(0.4) : MyColor.mainWhiteColor,
                ),
              ),
            ),
          )
              :
          exchangeProvider.createExLoading
              ?
          SizedBox(
            height: 50,
            child: Helper.dialogCall.showLoader(),
          )
              :
          InkWell(
            onTap: () {
              if(exchangeProvider.isAddressVerify){
                createExchange();
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 45,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: addressController.text.isEmpty ? MyStyle.invalidDecoration : MyStyle.buttonDecoration,
              child:Text(
                "Start Exchange",
                style: MyStyle.tx18BWhite.copyWith(
                  color:  addressController.text.isEmpty ? MyColor.mainWhiteColor.withOpacity(0.4) : MyColor.mainWhiteColor,
                ),
              ),
            ),
          ),

          SizedBox(height: Platform.isIOS ? 10 : 5),

        ],
      ),

      appBar: AppBar(
        backgroundColor: MyColor.darkGreyColor,
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
          "Enter ${exchangeProvider.receiveCoin.ticker} address",
        ),

      ),

      body: SizedBox(
        height: height,
        width: width,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.17,
              width: width,
              child: Stack(
                children: [

                  // background color container
                  Container(
                    color: MyColor.darkGreyColor,
                    height: height * 0.12,
                    width: width,
                  ),

                  // text filed
                  Positioned(
                    bottom: 0,
                    left: 15,
                    right: 15,
                    child: TextFormField(
                        controller: addressController,
                        cursorColor: MyColor.greenColor,
                        style: MyStyle.tx18RWhite,
                        onChanged: (value) {
                          setState(() {
                            exchangeProvider.createExSuccess = false;
                            exchangeProvider.isAddressVerify = false;
                          });
                        },
                        decoration: InputDecoration(
                            filled: true,
                            hintText: "Add ${exchangeProvider.receiveCoin.ticker} Address",
                            fillColor: MyColor.blackColor,
                            border: InputBorder.none,
                            hintStyle:MyStyle.tx22RWhite.copyWith(
                                fontSize: 18,
                                color: MyColor.whiteColor.withOpacity(0.7)
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 20),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: MyColor.blackColor,
                                )
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: MyColor.blackColor,
                                )
                            ),
                            suffixIcon: InkWell(
                              onTap: (){
                                FlutterClipboard.paste().then((value){
                                  setState(() {
                                    exchangeProvider.isAddressVerify = false;
                                    addressController.text = value;
                                    FocusScope.of(context).unfocus();
                                  });

                                  addressVerification(context);
                                });
                              },
                              child: SizedBox(
                                width: 80,
                                child: Center(
                                  child: Text(
                                    "Paste",
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 16,
                                        color: MyColor.greenColor
                                    ),
                                  ),
                                ),
                              ),
                            )

                        )
                    ),
                  ),

                  // // add wallet text and icon
                  // Positioned(
                  //   bottom: 75,
                  //   left: 0,
                  //   right: 0,
                  //   child: Column(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.all(10),
                  //         decoration: const BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: MyColor.greenColor
                  //         ),
                  //         child: Image.asset(
                  //           "assets/images/dashboard/wallet.png",
                  //           height: 20,
                  //           width: 20,
                  //           color: MyColor.whiteColor,
                  //           fit: BoxFit.contain,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         "Add Wallet",
                  //         style: MyStyle.tx18RWhite.copyWith(
                  //             color: MyColor.greenColor,
                  //           fontSize: 12
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // )

                ],
              ),
            )
          ],
        ),
      ),

    );
  }

}

