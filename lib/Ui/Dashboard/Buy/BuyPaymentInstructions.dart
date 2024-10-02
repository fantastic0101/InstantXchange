import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Buy/BuySuccessful.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: must_be_immutable
class BuyPaymentInstructions extends StatefulWidget {
  var buyResponse;

  BuyPaymentInstructions({
    super.key,
    required this.buyResponse
  });

  @override
  State<BuyPaymentInstructions> createState() => _BuyPaymentInstructionsState();
}

class _BuyPaymentInstructionsState extends State<BuyPaymentInstructions> {

  late BuySellProvider buySellProvider;

  notifyOrder(invoice)async{

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var email = sharedPre.getString("email");

    var params = {
      "action":"notify_payment_made",
      "email":email,
      "invoice":invoice,
      "auth":"p1~\$*)Ze(@"
    };

    // ignore: use_build_context_synchronously
    await buySellProvider.notifyOrder(
        params,
        context,
        "sell"
    );

    if(buySellProvider.placeNotifyOrder) {

      // ignore: use_build_context_synchronously
      Navigator.pop(context,"refresh");
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BuySuccessful(
                  invoice: invoice,
                ),
          )
      );

    }
  }

  @override
  void initState() {
    super.initState();
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);

  }

  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);

    return Scaffold(
      appBar: AppBar(
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
          "Payment Instructions",
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) {
                var listItem = widget.buyResponse.toString().substring(1,widget.buyResponse.toString().length-1).split("\n");
                var listNote = [];
                var data  = {
                  "info": "Take NOTE ${listItem[0].split(',').last.split(":").last}",
                  "notice":"${listItem[1]},${listItem[2]},${listItem[3]}",
                  "invoice":listItem[5],
                  "bankInfo":listItem[6],
                  "bankInfo1":listItem[7],
                  "bankName":listItem[9],
                  "bankNo":listItem[10],
                  "webConnect":listItem[11].split(",").first,
                };

                // print(listItem);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['info']!,
                        style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: MyColor.colorsBack1,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['notice']!.split(",")[0].trim(),
                              style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 14
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['notice']!.split(",")[1].trim(),
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 14
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['notice']!.split(",")[2].trim(),
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 14
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      Text(
                        data['invoice']!,
                        style: MyStyle.tx18RWhite.copyWith(
                            fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "• ${data['bankInfo']}",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),


                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "• ${data['bankInfo1']}",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),


                      // bank name
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Bank",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                        decoration: BoxDecoration(
                            color: MyColor.colorsBack1,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          data['bankName']!,
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 13
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Account No
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Account No",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      InkWell(
                        onTap: () {
                          FlutterClipboard.copy(data['bankNo']!).then((value) {
                            Helper.dialogCall.showToast(context, "Account no Copied");
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                          decoration: BoxDecoration(
                              color: MyColor.colorsBack1,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['bankNo']!,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 13
                                  ),
                                ),
                              ),

                              const Icon(
                                Icons.copy,
                                size: 19,
                                color: MyColor.whiteColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      //Account Name
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Account Name",
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                        decoration: BoxDecoration(
                            color: MyColor.colorsBack1,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          data['webConnect']!,
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 13
                          ),
                        ),
                      ),

                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            buySellProvider.notifyLoading
                ?
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Helper.dialogCall.showLoader(),
            )
                :
            InkWell(
              onTap: () {
                var value = widget.buyResponse.toString().substring(1,widget.buyResponse.toString().length-1).split("Invoice no :").last.trim();
                var invoice = value.split(" ").first.split("\n").first.trim();
                notifyOrder(invoice);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15,0,15,15),
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: MyStyle.buttonDecoration,
                child: Text(
                  "I have paid",
                  style: MyStyle.tx18BWhite.copyWith(
                      color: MyColor.mainWhiteColor
                  ),
                ),
              ),
            ),

            Text(
              "Tap this button once you make payment",
              style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 15,
                  color: MyColor.whiteColor
              ),
            )
          ],
        ),
      )
    );
  }
}
