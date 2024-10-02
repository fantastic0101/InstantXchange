import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/ApiHandlers/ApiHandle.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Ex_Transaction_address.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'ExchangeTransactionStatus.dart';

class ExchangeHistory extends StatefulWidget {
  const ExchangeHistory({super.key});

  @override
  State<ExchangeHistory> createState() => _ExchangeHistoryState();
}

class _ExchangeHistoryState extends State<ExchangeHistory> {

  late ExchangeProvider exchangeProvider;
  bool isLoading = true;

  getExTransactionList() async {
    setState(() {
      isLoading = true;
    });

    await DbExTransaction.dbExTransaction.getExTransaction();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    super.initState();
    getExTransactionList();
  }

  @override
  Widget build(BuildContext context) {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);

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
          "History",
        ),
      ),
      body:isLoading
          ?
      Helper.dialogCall.showLoader()
          :
      DbExTransaction.dbExTransaction.exTransactionList.isEmpty
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
        itemCount:  DbExTransaction.dbExTransaction.exTransactionList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12,15,12,0),
        itemBuilder: (context, index) {
          var list =  DbExTransaction.dbExTransaction.exTransactionList[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ExchangeTransactionStatus(
                            statusId: list.id,
                          )
                  )
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColor.darkGrey01Color
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "${list.fromCurrency}: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),

                            ),
                            Text(
                              ApiHandler.calculateLength3("${list.expectedSendAmount}"),
                              style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16,
                              ),

                            ),


                            const SizedBox(width: 10),
                            Text(
                              "To",
                              style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 15,
                                color: MyColor.grey01Color,
                              ),

                            ),
                            const SizedBox(width: 10),

                            Text(
                              "${list.toCurrency}: ",
                              style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 16
                              ),

                            ),
                            Text(
                              ApiHandler.calculateLength3("${list.expectedReceiveAmount}"),
                              style: MyStyle.tx18RWhite.copyWith(
                                fontSize: 16,
                              ),

                            ),

                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "DATE: ${DateFormat("dd MMM yyyy").format(list.createdAt)}",
                          style: MyStyle.tx18RWhite.copyWith(
                            color: MyColor.grey01Color,
                            fontSize: 12
                          ),
                        ),
                        const SizedBox(width: 10),

                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_right,
                    color: MyColor.mainWhiteColor,
                  )
                ],
              ),
            ),
          );
        },
      )

    );
  }
}
