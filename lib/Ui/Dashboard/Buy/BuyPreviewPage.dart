import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Models/LoginModel.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyPreviewPage extends StatefulWidget {
  final String itemCode,amount,receivingAddress,bank,memo,networkFess;
  final RatesInfo? selectedCoin;

  const BuyPreviewPage({
    super.key,
    required this.itemCode,
    required this.selectedCoin,
    required this.amount,
    required this.receivingAddress,
    required this.bank,
    required this.memo,
    required this.networkFess,
  });

  @override
  State<BuyPreviewPage> createState() => _BuyPreviewPageState();
}

class _BuyPreviewPageState extends State<BuyPreviewPage> {

  late BuySellProvider buySellProvider;
  bool acceptTerms = false;

  validateBuy() async {

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var email = sharedPre.getString("email");

    var params = {
      "action":"validate_buy_order",
      "email": email,
      "token":buySellProvider.loginModel!.accessToken,
      "item_code":widget.itemCode,
      "amount":widget.amount,
      "receiving_account":widget.receivingAddress,
      "bank":widget.bank,
      "auth":"p1~\$*)Ze(@",
    };

    await buySellProvider.validateBuyOrder(params);

  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    super.initState();
    Future.delayed(Duration.zero,(){
      validateBuy();
    });
  }

  placeBuyOrder(context)async{
    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var email = sharedPre.getString("email");

    String feeType = "${widget.selectedCoin!.networkFees.indexOf(widget.networkFess)+1}";
    var params = {
      "action":"place_buy_order",
      "email":email,
      "token":buySellProvider.loginModel!.accessToken,
      "item_code":widget.itemCode,
      "amount":widget.amount,
      "receiving_account":widget.receivingAddress,
      "bank":widget.bank,
      "memo":widget.memo,
      "network_fee_type":feeType,
      "auth":"p1~\$*)Ze(@",
    };
    // print(jsonEncode(params));
    await buySellProvider.placeBuyOrder(params,context);
  }


  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;


    return Scaffold(
      bottomNavigationBar: Visibility(
        visible: !buySellProvider.isValidBuyLoading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  acceptTerms = !acceptTerms;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                          color: acceptTerms ? MyColor.greenColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              width: 1.5,
                              color: acceptTerms ?  MyColor.greenColor : MyColor.whiteColor.withOpacity(0.4)
                          )
                      ),
                      child: acceptTerms ? const Center(child: Icon(Icons.check,size: 18,color: Colors.white,)) : const SizedBox(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child:RichText(
                          text:  TextSpan(
                              children: [
                                TextSpan(
                                  text: "Accept ",
                                  style: MyStyle.tx18BWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                                TextSpan(
                                  text: "Terms",
                                  style: MyStyle.tx18BWhite.copyWith(
                                      color: MyColor.greenColor,
                                      fontSize: 16
                                  ),
                                )
                              ]
                          ),
                        )
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            buySellProvider.orderLoading
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
            InkWell(
              onTap: () {
                if(acceptTerms) {
                  placeBuyOrder(context);
                }else{
                  Helper.dialogCall.showToast(context, "Accept all term and condition.");
                }
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15,0,15,15),
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: acceptTerms
                    ?
                MyStyle.buttonDecoration
                    :
                MyStyle.invalidDecoration,

                child: Text(
                  "Place Order",
                  style:  MyStyle.tx18BWhite.copyWith(
                      color: acceptTerms
                          ?
                      MyColor.mainWhiteColor
                          :
                      MyColor.mainWhiteColor.withOpacity(0.4)
                  ),
                ),
              ),
            ),
          ],
        ),
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
          "Preview Page",
        ),

      ),
      body: buySellProvider.isValidBuyLoading
          ?
      Helper.dialogCall.showLoader()
          :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child: Text(
                          "Type: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                          "Buy",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Currency/Service: ",
                          style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                          widget.selectedCoin!.name,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Amount ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                        "${widget.amount} USD",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "You Pay ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${(double.parse("${widget.selectedCoin!.buyPrice}") * double.parse(widget.amount) + 7.5 /100 * (5*double.parse(widget.amount)) + 50)} NGN",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height:buySellProvider.receiveValue.isNotEmpty ? 15 : 0),


                  Visibility(
                    visible: buySellProvider.receiveValue.isNotEmpty,
                    child: Row(
                      children: [
                        SizedBox(
                          width: width*0.4,
                          child:  Text(
                            "You Receive",
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16
                            ),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            buySellProvider.receiveValue,
                            style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "VAT",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          "${7.5 /100 * (5*double.parse(widget.amount))} NGN",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                      ),

                      Expanded(
                        child: Text(
                          "(including 7.5% VAT)",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 12
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Stamp Duty: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                        "50 NGN",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child: Text(
                          "Currency Account: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                            widget.receivingAddress,
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Payment Method: ",
                          style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                          "Bank",
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      SizedBox(
                        width: width*0.4,
                        child:  Text(
                          "Bank Name: ",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ),

                      Text(
                        widget.bank,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Note: Kindly make sure all information's are correct. InstantExchangers will NOT be responsible for any loss if you input a wrong account details.",
              style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 12,
                  color: MyColor.dotBoarderColor,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
