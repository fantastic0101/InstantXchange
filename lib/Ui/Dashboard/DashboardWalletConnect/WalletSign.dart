import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Walletv2_provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../Settings/WalletConnect/walletv2_models/ethereum/wc_ethereum_sign_message.dart';


class WalletSign extends StatefulWidget {
  final int id;
  final String topic;
  final String selectedAccountPrivateAddress;
  final SessionStruct session;
  final SignClient signClient;
  final WCEthereumSignMessage message;

  const WalletSign({
    Key? key,
    required this.id,
    required this.topic,
    required this.session,
    required this.signClient,
    required this.selectedAccountPrivateAddress,
    required this.message,
  }):super(key: key);

  @override
  State<WalletSign> createState() => _WalletSignState();
}

class _WalletSignState extends State<WalletSign> {


  createSignT(String value,String type,session) async {
    String date = DateFormat('MMM dd, hh:mm a').format(DateTime.now());
    await DBWalletConnectV2.dbWalletConnectV2.createSignt(
        date,
        value,
        type,
        "$session"
    );
  }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return  Scaffold(
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
          "Wallet connect Sign",
          //"Add Token",
         
        ),
      ),
      body:  Container(
        width: width,
        height: height,
        color: MyColor.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  if (widget.session.peer.metadata.icons.isNotEmpty)
                    Container(
                      height: 100.0,
                      width: 100.0,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.network(widget.session.peer.metadata.icons.first),
                    ),
                  Text(
                    widget.session.peer.metadata.name,
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 20
                    ),
                  ),
                ],
              ),

              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Sign Message',
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
              ),
              Theme(
                data:
                Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ExpansionTile(
                    iconColor: MyColor.whiteColor,
                    collapsedIconColor: MyColor.whiteColor,
                    expandedAlignment: Alignment.topLeft,
                    tilePadding: EdgeInsets.zero,
                    title:  Text(
                      'Message',
                      style:  MyStyle.tx18RWhite.copyWith(
                          fontSize: 14
                      ),
                    ),
                    children: [
                      Text(
                        widget.message.data,
                        style:  MyStyle.tx18RWhite.copyWith(
                            fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        try {
                          final privateKey = widget
                              .selectedAccountPrivateAddress;
                          final creds = EthPrivateKey.fromHex(privateKey);
                          String signedDataHex;
                          if (widget.message.type ==
                              WCSignType.TYPED_MESSAGE_V1) {
                            signedDataHex = EthSigUtil.signTypedData(
                              privateKey: privateKey,
                              jsonData: widget.message.data,
                              version: TypedDataVersion.V1,
                            );
                          }
                          else if (widget.message.type == WCSignType
                              .TYPED_MESSAGE_V3) {
                            signedDataHex = EthSigUtil.signTypedData(
                              privateKey: privateKey,
                              jsonData: widget.message.data,
                              version: TypedDataVersion.V3,
                            );
                          } else if (widget.message.type ==
                              WCSignType.TYPED_MESSAGE_V4) {
                            signedDataHex = EthSigUtil.signTypedData(
                              privateKey: privateKey,
                              jsonData: widget.message.data,
                              version: TypedDataVersion.V4,
                            );
                          } else {
                            final encodedMessage = hexToBytes(
                                widget.message.data);
                            final signedData =
                            creds.signPersonalMessageToUint8List(
                                encodedMessage);
                            signedDataHex =
                                bytesToHex(signedData, include0x: true);
                          }
                          // debugPrint('SIGNED $signedDataHex');
                          widget.signClient.respond(
                            SessionRespondParams(
                              topic: widget.topic,
                              response: JsonRpcResult<String>(
                                id: widget.id,
                                result: signedDataHex,
                              ),
                            ),
                          ).then((value) {
                            createSignT(signedDataHex, "Approved",
                                widget.session.topic);
                            Navigator.pop(context);
                          });
                        }catch(e){
                          // ignore: use_build_context_synchronously
                          Helper.dialogCall.showToast(context, "Some Thing wrong please reconnect your wallet!");
                        }
                      },
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: MyColor.greenColor,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)
                          ),
                        ),
                        child: Text(
                          "SIGN",
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

                      onTap: () {
                        widget.signClient.respond(
                            SessionRespondParams(
                              topic: widget.session.topic,
                              response: JsonRpcError(id: widget.id),
                            )
                        ).then((value) {
                          createSignT(widget.session.topic,"Rejected",widget.session.topic);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                          alignment: Alignment.center,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: MyColor.redColor,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
      ),
    );

  }
}
