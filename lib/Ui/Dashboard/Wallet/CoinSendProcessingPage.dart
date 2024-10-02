import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/CoinDetailScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';

class CoinSendProcessingPage extends StatefulWidget {
  String selectedAccountAddress,tokenId,tokenNetworkId,tokenAddress,tokenName,token_transection_Id,
      tokenSymbol,tokenBalance,tokenImage,tokenType,tokenMarketId,
      tokenDecimal,explorerUrl,accAddress;
  double tokenUsdPrice,tokenUpDown,tokenFullPrice;

  CoinSendProcessingPage({
    super.key,
    required this.selectedAccountAddress,
    required this.tokenId,
    required this.token_transection_Id,
    required this.tokenNetworkId,
    required this.tokenAddress,
    required this.tokenName,
    required this.tokenImage,
    required this.tokenDecimal,
    required this.tokenType,
    required this.tokenSymbol,
    required this.tokenBalance,
    required this.tokenUsdPrice,
    required this.tokenUpDown,
    required this.tokenFullPrice,
    required this.tokenMarketId,
    required this.explorerUrl,
    required this.accAddress,
  });

  @override
  State<CoinSendProcessingPage> createState() => _CoinSendProcessingPageState();
}

class _CoinSendProcessingPageState extends State<CoinSendProcessingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.clear,
              size: 30,
              color: MyColor.whiteColor,
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MyColor.mainWhiteColor,
          ),
          child: Image.asset(
            "assets/images/send_complete.jpg",
            height: 90,
            width: 90,
          )
        ),
        const SizedBox(height: 20),

        Text(
          "Processing…",
          style: MyStyle.tx18BWhite.copyWith(
            color: MyColor.whiteColor
          ),
        ),
        const SizedBox(height: 20),

        Text(
          "Transaction in progress! Blockchain validation is underway."
              "This may take a few minutes.",
          textAlign: TextAlign.center,
          style: MyStyle.tx18RWhite.copyWith(
            color: MyColor.dotBoarderColor,
            fontSize: 15
          ),
        ),
        const SizedBox(height: 20),


        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoinDetailScreen(
                    accAddress: widget.accAddress,
                    selectedAccountAddress: widget.selectedAccountAddress,
                    tokenDecimal: widget.tokenDecimal,
                    tokenId: widget.tokenId,
                    tokenNetworkId: widget.tokenNetworkId,
                    tokenAddress: widget.tokenAddress,
                    tokenName: widget.tokenName,
                    tokenSymbol: widget.tokenSymbol,
                    tokenBalance: widget.tokenBalance,
                    tokenMarketId: widget.tokenMarketId,
                    tokenType: widget.tokenType,
                    tokenImage: widget.tokenImage,
                    tokenUsdPrice: widget.tokenUsdPrice,
                    tokenFullPrice:widget.tokenFullPrice,
                    tokenUpDown: widget.tokenUpDown,
                    token_transection_Id: widget.token_transection_Id,
                    explorerUrl: widget.explorerUrl,
                  ),
                )
            );
          },
          child: Container(
            alignment: Alignment.center,
            height: 45,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: MyStyle.buttonDecoration,
            child: const Text(
              "Transaction details",
              style: MyStyle.tx18BWhite,
            ),
          ),
        ),
        const SizedBox(height: 20),

      ],
    );
  }
}
