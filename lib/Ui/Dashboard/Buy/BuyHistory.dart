import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyHistory extends StatefulWidget {
  const BuyHistory({super.key});

  @override
  State<BuyHistory> createState() => _BuyHistoryState();
}

class _BuyHistoryState extends State<BuyHistory> {

  late BuySellProvider buySellProvider;

  String startData = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String endData = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String statusType = "Pending";

  showMyCalender(dateType) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), //get today's date
        firstDate:DateTime(2000), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime.now(),

    );

    if(pickedDate != null ){
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed

      setState(() {
        if(dateType == "start") {
          startData = formattedDate;
        }else{
          endData = formattedDate;
        }
        buySellProvider.buyHistoryList.clear();
      });

      getHistory();
    }
  }

  int pageCount = 1;
  getHistory() async {

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    var email = sharedPre.getString("email");

    var params = {
      "action":"get_transactions",
      "email":email,
      "token":buySellProvider.loginModel!.accessToken,
      // "p":"$pageCount",
      "status":statusType,
      "start_date":startData,
      "end_date":endData,
      "auth":"p1~\$*)Ze(@",
    };

    //print(params);
    await buySellProvider.buyHistory(params);
  }


  @override
  void initState() {
    super.initState();
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    buySellProvider.buyHistoryList.clear();
    Future.delayed(Duration.zero,(){
      getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
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
          "Buy History",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: statusType,
              isExpanded: true,
              decoration: MyStyle.textInputDecoration.copyWith(
                contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_sharp,
                color: MyColor.greenColor,
              ),
              hint: Text(
                "Select Bank",
                style:MyStyle.tx22RWhite.copyWith(
                    fontSize: 18,
                    color: MyColor.whiteColor.withOpacity(0.7)
                ),
              ),
              dropdownColor: MyColor.backgroundColor,
              style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 16
              ),

              items: ["Pending","Cancelled","Completed"].map((String category) {
                return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                    )
                );
              }).toList(),
              onChanged: (String? value) async {
                setState(() {
                  buySellProvider.buyHistoryList.clear();
                  statusType = value!;
                });

                getHistory();

              },
            ),
            const SizedBox(height: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // start data
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showMyCalender("start");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: MyColor.darkGrey01Color,
                        border: Border.all(
                          color: MyColor.boarderColor,
                        )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: MyColor.whiteColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              startData,
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "To",
                    style: MyStyle.tx18RWhite,
                  ),
                ),

                // end data
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showMyCalender("end");
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: MyColor.darkGrey01Color,
                          border: Border.all(
                            color: MyColor.boarderColor,
                          )
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: MyColor.whiteColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              endData,
                              textAlign: TextAlign.center,
                              style: MyStyle.tx18RWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: buySellProvider.buyHistoryLoading
                  ?
              Helper.dialogCall.showLoader()
                  :
              buySellProvider.buyHistoryList.isEmpty
                  ?
              Center(
                child: Text(
                  "No Transaction Yet.",
                  style: MyStyle.tx18RWhite.copyWith(
                      color: MyColor.grey01Color
                  ),
                ),
              )
                  :
              ListView.builder(
                shrinkWrap: true,
                itemCount: buySellProvider.buyHistoryList.length,
                itemBuilder: (context, index) {
                  var list = buySellProvider.buyHistoryList[index];
                  var value = list.details.amount.split(" ");
                  var amount = ApiHandler.calculateLength3(value[0]);
                  var type = value[1];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: MyColor.darkGrey01Color,
                      border: Border.all(
                        color: MyColor.boarderColor,
                      )
                    ),
                    child: Column(
                      children: [


                        Row(
                          children: [
                            Text(
                              "status:",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                            const SizedBox(width: 5),
                            Text(
                              list.status,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                            const Spacer(),

                            Text(
                              "Type: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                            const SizedBox(width: 5),
                            Text(
                              list.details.transactionType,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // invoice and status
                        InkWell(
                          onTap: () {
                            FlutterClipboard.copy(list.invoiceNo).then((value) {
                              Helper.dialogCall.showToast(context, "Invoice No Copied");
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                "Invoice no: ",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  list.invoiceNo,
                                  style: MyStyle.tx18RWhite.copyWith(
                                      fontSize: 16
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.copy,
                                size: 20,
                                color: MyColor.whiteColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        Visibility(
                          visible: list.details.payin_Address != "",
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                FlutterClipboard.copy(list.details.payin_Address).then((value) {
                                  Helper.dialogCall.showToast(context, "Invoice No Copied");
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Payin Address: ",
                                    style: MyStyle.tx18RWhite.copyWith(
                                        fontSize: 16
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      list.details.payin_Address,
                                      style: MyStyle.tx18RWhite.copyWith(
                                          fontSize: 16
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: MyColor.whiteColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // date
                        Row(
                          children: [
                            Text(
                              "date: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),

                            const SizedBox(width: 5),
                            Text(
                              list.date,
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // buy Currency name
                        Row(
                          children: [
                            Text(
                              "Token name:",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                list.details.currency,
                                textAlign: TextAlign.start,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Amount:
                        Row(
                          children: [
                            Text(
                              "Amount: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                "$amount $type",
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),// Amo
                        const SizedBox(height: 8),

                        //Account
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Receive Ac: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),
                            ),
                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                list.details.currencyAccount,
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}
