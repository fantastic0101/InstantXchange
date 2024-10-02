import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

import 'BuyHistory.dart';

class BuySuccessful extends StatefulWidget {
  final String invoice;
  const BuySuccessful({
    super.key,
    required this.invoice
  });

  @override
  State<BuySuccessful> createState() => _BuySuccessfulState();
}

class _BuySuccessfulState extends State<BuySuccessful> {
  @override
  Widget build(BuildContext context) {
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
          "Order Confirmation",
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Text(
              "Thank you for your purchase. Admin is checking on your "
                  "order ${widget.invoice} and will process as soon as we receive"
                  " your payment.",
              style: MyStyle.tx18RWhite.copyWith(
                  fontSize: 15,
                  color: MyColor.whiteColor
              ),
            ),
            const SizedBox(height: 30),

            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BuyHistory(),
                  )
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15,0,15,15),
                alignment: Alignment.center,
                height: 45,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: MyStyle.buttonDecoration,
                child: Text(
                  "View transaction history",
                  style: MyStyle.tx18BWhite.copyWith(
                      color: MyColor.mainWhiteColor
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
