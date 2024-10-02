import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:wallet_connect_dart_v2/wallet_connect_dart_v2.dart';


class SessionRequestView extends StatefulWidget {
  final String account1;
  final RequestSessionPropose proposal;
  final void Function(SessionNamespaces,List<String>) onApprove;
  final void Function() onReject;

  const SessionRequestView({
    Key? key,
     required this.account1,
     required this.proposal,
     required this.onApprove,
     required this.onReject,
  }) : super(key: key);

  @override
  State<SessionRequestView> createState() => _SessionRequestViewState();
}

class _SessionRequestViewState extends State<SessionRequestView> {
   late AppMetadata _metadata;
   late List<String> _selectedAccountIds;

   late TokenProvider tokenProvider;

   @override
  void initState() {

    tokenProvider = Provider.of<TokenProvider>(context,listen: false);

    _metadata = widget.proposal.proposer.metadata;
    // print(widget.proposal.requiredNamespaces.entries.first.value.chains);
    //
    // print("Metadata :->>>>>>");
    // print(_metadata.toJson());


    super.initState();
  }

  var chinId = "0";
  @override
  Widget build(BuildContext context) {
    tokenProvider = Provider.of<TokenProvider>(context,listen: true);

    return Container(
      decoration: BoxDecoration(
          color: MyColor.backgroundColor,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                      : Center(
                          child: Text(
                            _metadata.name.substring(0, 1),
                            style:  MyStyle.tx18BWhite.copyWith(
                                fontSize: 22
                            ),
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
                        style:  MyStyle.tx18BWhite.copyWith(
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
          const Divider(height: 1.5, thickness: 1.5),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (_, idx) {
                final item = widget.proposal.requiredNamespaces.entries.elementAt(idx);
                // print(item.value.toJson());
                // print(item.key);
                // print(item.value.chains);
                //
                // print("check ---> ");


                int value = DbNetwork.dbNetwork.networkList.indexWhere((element) {
                  // print(element.chain);
                  return "${element.chain}" == item.value.chains.first.split(":").last && element.isEVM == 1;
                });
                if(value != -1){
                  // print("test val"+value.toString());
                  chinId = item.value.chains.first.split(":").last;
                  // print("test chain id"+chinId);
                }else{
                  // print("check 2 ---> ");
                  Helper.dialogCall.showToast(context,  "Network not implemented!!",);
                  Navigator.pop(context);
                }

                return NamespaceView(
                  type: item.key,
                  accountAddress: widget.account1,
                  namespace: item.value,
                );
              },
              separatorBuilder: (_, __) =>
                  const Divider(height: 1.5, thickness: 1.5),
              itemCount: widget.proposal.requiredNamespaces.entries.length,
            ),
          ),
          const Divider(height: 1.5, thickness: 1.5),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: MyColor.blueColor,
                      ),
                      onPressed: () {
                        final SessionNamespaces params = {};
                        for (final entry
                            in widget.proposal.requiredNamespaces.entries) {
                          final List<String> accounts = [];

                          accounts.add("eip155:$chinId:${widget.account1}");
                          print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$accounts");
                          params[entry.key] = SessionNamespace(
                            accounts: accounts,
                            methods: entry.value.methods,
                            events: entry.value.events,
                          );
                          log('SESSION: ${params[entry.key]!.toJson()}');
                        }
                        // widget.onApprove(params);
                        widget.onApprove(params,widget.proposal.requiredNamespaces.entries.first.value.chains);

                      },
                      child: const Text(
                          'Approve',
                        style: TextStyle(
                          fontFamily: "Lato-Semibold"
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: SizedBox(
                    height: 40.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red.shade300,
                      ),
                      onPressed: widget.onReject,
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                            fontFamily: "Lato-Semibold"
                        ),
                      ),

                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NamespaceView extends StatefulWidget {
  final String type;
  final String accountAddress;
  final ProposalRequiredNamespace namespace;

  const NamespaceView({super.key,
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
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Permissions',
            style:  MyStyle.tx18RWhite.copyWith(
                fontSize: 16
            ),
          ),
          const SizedBox(height: 8.0),
          ...widget.namespace.chains
              .map((chain) => Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
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
                            'Methods',
                            style:  MyStyle.tx18RWhite.copyWith(
                                fontSize: 14
                            ),
                          ),
                        ),
                        Text(
                          widget.namespace.methods.isEmpty
                              ? '-'
                              : widget.namespace.methods.join(', '),
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          child: Text(
                            'Events',
                            style:  MyStyle.tx18RWhite.copyWith(
                                fontSize: 14
                            ),
                          ),
                        ),
                        Text(
                          widget.namespace.events.isEmpty
                              ? '-'
                              : widget.namespace.events.join(', '),
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Selected Account",
              style:  MyStyle.tx18RWhite.copyWith(
                  fontSize: 16
              ),
            ),
          ),

          Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: MyColor.darkGrey01Color,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Text(
                      '${widget.accountAddress.substring(0, 6)}...${widget.accountAddress.substring(widget.accountAddress.length - 6)}',
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 14
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
