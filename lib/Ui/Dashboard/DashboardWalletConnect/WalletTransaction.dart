import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:web3dart/web3dart.dart';
import '../Settings/WalletConnect/walletv2_models/ethereum/wc_ethereum_transaction.dart';


class WalletTransaction extends StatefulWidget {

  final int id;
  final Web3Client web3client;
  final int chainId;
  final SessionStruct session;
  final WCEthereumTransaction ethereumTransaction;
  final String title;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final gasPrice;

  const WalletTransaction({
    Key? key,
    required this.id,
    required this.chainId,
    required this.session,
    required this.ethereumTransaction,
    required this.title,
    required this.web3client,
    required this.onConfirm,
    required this.onReject,
    required this.gasPrice,
  }):super(key: key);

  @override
  State<WalletTransaction> createState() => _WalletTransactionState();

}

class _WalletTransactionState extends State<WalletTransaction> {

  late TokenProvider tokenProvider;

  @override
  void initState() {
    tokenProvider = Provider.of<TokenProvider>(context,listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tokenProvider = Provider.of<TokenProvider>(context,listen: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
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
          "Transactions",
        ),
      ),
      body: Padding(
        // key: navigatorKey,
        padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
        child: Column(

          children: [

            if (widget.session.peer.metadata.icons.isNotEmpty)
              Container(
                height: 100.0,
                width: 100.0,
                padding: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200)
                ),
                child: Image.network(
                  widget.session.peer.metadata.icons.first,
                  fit: BoxFit.cover,
                ),
              ),
            Text(
              widget.session.peer.metadata.name,
              style:  MyStyle.tx18RWhite.copyWith(
                  fontSize: 20
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                  widget.title,
                  style: MyStyle.tx18RWhite
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipient',
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${widget.ethereumTransaction.to}',
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Transaction Fee",
                      style:  MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.ethereumTransaction.gasPrice == null
                          ?
                      "${(BigInt.from(double.parse("${int.parse(widget.ethereumTransaction.gas??"0")}") *  double.parse("${widget.gasPrice.getInWei}")) / BigInt.from(10).pow(18)).toStringAsFixed(5)} ${DbNetwork.dbNetwork.networkList.where((element) => "${element.chain}" == "${widget.chainId}").first.symbol}"
                          :
                      "${(BigInt.parse("${int.parse(widget.ethereumTransaction.gas??"0")}") *  BigInt.parse(widget.ethereumTransaction.gasPrice??"0") / BigInt.from(10).pow(18)).toStringAsFixed(5)} ${DbNetwork.dbNetwork.networkList.where((element) => "${element.chain}" == "${widget.chainId}").first.symbol}",
                      style:  MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Transaction amount',
                      style:  MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.ethereumTransaction.gasPrice == null
                          ?
                      '${(BigInt.parse(widget.ethereumTransaction.value!) /  BigInt.from(10).pow(18)).toStringAsFixed(5)} ${DbNetwork.dbNetwork.networkList.where((element) => "${element.chain}" == "${widget.chainId}").first.symbol}'
                          :
                      '${(BigInt.parse(widget.ethereumTransaction.value!) /  BigInt.from(10).pow(18)).toStringAsFixed(5)} ${DbNetwork.dbNetwork.networkList.where((element) => "${element.chain}" == "${widget.chainId}").first.symbol}',
                      style:  MyStyle.tx18RWhite.copyWith(
                          fontSize: 16
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Theme(
                  data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      iconColor: MyColor.whiteColor,
                      collapsedIconColor: MyColor.whiteColor,
                      title: Text(
                        "Data",
                        style:  MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                      children: [
                        Text(
                          widget.ethereumTransaction.data ?? "",
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onConfirm,
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: MyColor.greenColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)
                        ),
                      ),
                      child: Text(
                       "CONFIRM",
                        style:  MyStyle.tx18BWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: InkWell(
                    onTap: widget.onReject,
                    child: Container(
                      alignment: Alignment.center,
                      height: 45,
                      decoration: BoxDecoration(
                        color: MyColor.blueColor.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Text(
                          'REJECT',
                        style:  MyStyle.tx18BWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
