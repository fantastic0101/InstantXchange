import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Walletv2_provider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import '../../../../Values/MyStyle.dart';

class signTransactions2 extends StatefulWidget {
  final String publicKey;

  const signTransactions2( {Key? key,required this.publicKey}) : super(key: key);

  @override
  _signTransactions2State createState() => _signTransactions2State();
}

class _signTransactions2State extends State<signTransactions2> with WidgetsBindingObserver{

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    isLoading = true;
    getSignT();
  }

  getSignT() {
    Future.delayed(const Duration(seconds: 1),() async {
      await DBWalletConnectV2.dbWalletConnectV2.getSignTByPublicKey(widget.publicKey);
      setState(() {
        isLoading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        DBWalletConnectV2.dbWalletConnectV2.getSignTByPublicKey(widget.publicKey);
      });
    });


    return Scaffold(
      appBar: AppBar(
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
          "Sign Translation",
        ),
      ),

      body: isLoading
          ?
      const Center(
        child: CircularProgressIndicator(
            color: MyColor.greenColor
        )
      )
          :
      DBWalletConnectV2.dbWalletConnectV2.SignTList.isEmpty
          ?
      Center(
        child: Text(
          "No Signed transactions.",
          style:  MyStyle.tx18RWhite.copyWith(
              fontSize: 16
          ),
        ),
      )
          :
      ListView.builder(
          shrinkWrap: true,
          reverse: true,
          itemCount: DBWalletConnectV2.dbWalletConnectV2.SignTList.length,
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemBuilder: (context, index) {

            return Container(
              margin: const EdgeInsets.only(bottom: 15),

              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: MyColor.darkGrey01Color,
                  borderRadius: BorderRadius.circular(8.0)
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Expanded(
                        child: Text("${DBWalletConnectV2.dbWalletConnectV2.SignTList[index]['date']}",
                          style:  MyStyle.tx18RWhite.copyWith(
                              fontSize: 14
                          ),
                        ),
                      ),

                      Text(
                        "${DBWalletConnectV2.dbWalletConnectV2.SignTList[index]['type']}",
                        style:  MyStyle.tx18RWhite.copyWith(
                            fontSize: 14
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "${DBWalletConnectV2.dbWalletConnectV2.SignTList[index]['text']}",
                    style:  MyStyle.tx18RWhite.copyWith(
                        fontSize: 14
                    ),
                  ),
                ],
              ),
            );
          }
      ),

    );
  }

}
