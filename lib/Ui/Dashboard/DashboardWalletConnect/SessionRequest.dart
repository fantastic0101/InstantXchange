import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:wallet_connect_dart_v2/core/models/app_metadata.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/jsonrpc/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/proposal/models.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';

class SessionRequest extends StatefulWidget {

  final String account1;
  final RequestSessionPropose proposal;
  final void Function(SessionNamespaces,List<String>) onApprove;
  final void Function() onReject;

  const SessionRequest({
    Key? key,
    required this.account1,
    required this.proposal,
    required this.onApprove,
    required this.onReject,
  }): super(key: key);

  @override
  State<SessionRequest> createState() => _SessionRequestState();
}

class _SessionRequestState extends State<SessionRequest> {
  late AppMetadata _metadata;
  late List<String> _selectedAccountIds;
  late TokenProvider tokenProvider;


  void checkNetwork()async {

    await DbNetwork.dbNetwork.getNetwork();
    final item = widget.proposal.requiredNamespaces.entries.elementAt(0);

    int value = DbNetwork.dbNetwork.networkList.indexWhere((element) {
      // print(element.chain);
      return "${element.chain}" == item.value.chains.first
          .split(":").last && element.isEVM == 1 && element.swapEnable == 1;
    });

    if (value != -1) {
      chinId = item.value.chains.first
          .split(":")
          .last;
    } else {
      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Network not implemented!!");
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }


  @override
  void initState() {
    tokenProvider = Provider.of<TokenProvider>(context,listen: false);
    _metadata = widget.proposal.proposer.metadata;
    super.initState();
    checkNetwork();
  }

  var chinId = "0";

  @override
  Widget build(BuildContext context) {

    tokenProvider = Provider.of<TokenProvider>(context,listen: true);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

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
          "Sign Authentication",
          //"Add Token",
        ),
      ),
      body: SizedBox(
        width: width,
        height: height,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      height: 50.0,
                      width: 50.0,
                      padding: const EdgeInsets.only(bottom: 8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                        image: _metadata.icons.isNotEmpty
                            ? DecorationImage(
                            image: NetworkImage(_metadata.icons.first))
                            : null,
                      ),
                      child: _metadata.icons.isNotEmpty
                          ? null
                          :
                      Center(
                        child: Text(
                          _metadata.name.substring(0, 1),
                          style:  MyStyle.tx18RWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metadata.name,
                            style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                            ),
                            maxLines: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              _metadata.url,
                              maxLines: 1,
                              style:  MyStyle.tx18RWhite.copyWith(
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: DbNetwork.dbNetwork.networkList.where((element) => element.isEVM == 1 && element.swapEnable == 1).toList().length,
                  itemBuilder: (context, index) {
                    var data = DbNetwork.dbNetwork.networkList.where((element) => element.isEVM == 1 && element.swapEnable == 1).toList()[index];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(20,0,20,10),
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: MyColor.boarderColor
                          )
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: CachedNetworkImage(
                              imageUrl:data.logo,
                              width: 35,
                              height:35,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(color: MyColor.greenColor),
                              ),
                              errorWidget: (context, url, error) =>
                                  Container(
                                    height: 35,
                                    width: 35,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: MyColor.whiteColor,
                                    ),
                                    child: Image.asset(
                                      "assets/images/bitcoin.png",
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.name,
                                    style:  MyStyle.tx18RWhite.copyWith(
                                        fontSize: 16
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  Text(
                                    "${widget.account1.substring(0,6)}....${widget.account1.substring(widget.account1.length-6,widget.account1.length)}",
                                    style:  MyStyle.tx18RWhite.copyWith(
                                        fontSize: 12
                                    ),
                                  ),
                                ],
                              )
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: MyColor.greenColor,
                        ),
                        onPressed: () {
                          final SessionNamespaces params = {};

                          // final List<String> accounts = [];
                          //


                          for (final entry in widget.proposal.requiredNamespaces.entries) {
                            final List<String> accounts = [];
                            List<NetworkList> evmList = DbNetwork.dbNetwork.networkList.where((element) {
                              return element.isEVM == 1 && element.swapEnable == 1;
                            }).toList();

                            for(int i=0;i<evmList.length; i++){
                              accounts.add("eip155:${evmList[i].chain}:${widget.account1}");
                            }

                            // accounts.add("eip155:$chinId:${widget.account1}");

                            // print("check this -----> ${accounts.toString()}");
                            // print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"+accounts.toString());
                            params[entry.key] = SessionNamespace(
                              accounts: accounts,
                              methods: entry.value.methods,
                              events: entry.value.events,
                            );
                            // log('SESSION: ${params[entry.key]!.toJson()}');
                          }
                          // widget.onApprove(params);
                          widget.onApprove(params,widget.proposal.requiredNamespaces.entries.first.value.chains);
                        },
                        child: Text(
                          'Approve',
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: MyColor.redColor,
                        ),
                        onPressed: widget.onReject,
                        child: Text(
                          "Reject",
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),

                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

class NamespaceView extends StatefulWidget {
  final String type;
  final String accountAddress;
  final ProposalRequiredNamespace namespace;

  const NamespaceView({
    super.key,
    required this.type,
    required this.accountAddress,
    required this.namespace,
  });

  @override
  State<NamespaceView> createState() => _NamespaceViewState();
}

class _NamespaceViewState extends State<NamespaceView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
               "Review Permissions",
              style:  MyStyle.tx18RWhite.copyWith(
                  fontSize: 16
              ),
            ),
          ),
           SizedBox(height: 8.0,
              width: MediaQuery.of(context).size.width
          ),
          ...widget.namespace.chains
              .map((chain) => Container(
            margin: const EdgeInsets.only(bottom: 8.0,left: 20),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color:  MyColor.darkGrey01Color,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chain,
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text(
                    "Methods",
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
                Text(
                  widget.namespace.methods.isEmpty
                      ? '-'
                      :
                  widget.namespace.methods.join(', '),
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text(
                    "Events",
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 16
                    ),
                  ),
                ),
                Text(
                  widget.namespace.events.isEmpty
                      ? '-'
                      : widget.namespace.events.join(', '),
                  style:  MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                ),
              ],
            ),
          )).toList(),


        ],
      ),
    );
  }
}
