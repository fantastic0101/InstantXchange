import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellStatusPage.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class WithdrawSuccessful extends StatefulWidget {
  final String invoice,tokenName;
  const WithdrawSuccessful({
    super.key,
    required this.invoice,
    required this.tokenName
  });

  @override
  State<WithdrawSuccessful> createState() => _WithdrawSuccessfulState();
}

class _WithdrawSuccessfulState extends State<WithdrawSuccessful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Spacer(flex: 2),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: MyColor.grey01Color
                  )
                ),
                child: const Icon(
                  Icons.check,
                  color: MyColor.greenColor
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.2),

              const Text(
                "WITHDRAWAL SUCCESSFUL",
                style: MyStyle.tx18BWhite,
              ),
              const SizedBox(height: 20),

              Text(
                "Admin is already notified of your sell order, we will process "
                    "payment to your bank shortly",
                textAlign: TextAlign.center,
                style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 14
                ),
              ),
              const SizedBox(height: 20),

              const Spacer(flex: 2),

              Text(
                "Invoice No :${widget.invoice}",
                style: MyStyle.tx18BWhite.copyWith(
                  fontSize: 17
                ),
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SellStatusPage(
                              invoiceNo: widget.invoice,
                              tokenName: widget.tokenName,
                              pageName: "",
                            ),
                      )
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: MyColor.greenColor
                  ),
                  child: const Center(
                    child: Text(
                        "View History",
                        style: MyStyle.tx18RWhite
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}
