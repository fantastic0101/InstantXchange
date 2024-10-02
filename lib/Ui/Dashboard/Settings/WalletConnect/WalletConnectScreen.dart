import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Walletv2_provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/DashboardScreen.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Settings/WalletConnect/signTransactions2.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Wallet/SendToken/QrScannerPage.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:jost_pay_wallet/Values/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_connect_dart_v2/sign/sign-client/session/models.dart';
import 'package:wallet_connect_dart_v2/utils/error.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> with WidgetsBindingObserver{

  late TokenProvider tokenProvider;

  String selectedAccountAddress = "",selectedAccountPrivateAddress = "",
      selectedAccountId = "", selectedAccountName = "";

  bool _initializing = false,is_loaded = false;

  @override
  void initState() {
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    super.initState();
    Utils.pageType1 = "walletConnect";


    _initializing = true;
    WidgetsBinding.instance.addObserver(this);
    selectedAccount();

  }


  ValueNotifier <List<SessionStruct>?>? sessions = ValueNotifier([]);
  deleteWalletDB() async {

    await DBWalletConnectV2.dbWalletConnectV2.getAllSignT();
    List deleteList = [];
    for(var topic in sessions!.value!){
      for(var dbTopic in DBWalletConnectV2.dbWalletConnectV2.signTListAll){
        if(dbTopic['publicKey'] != topic.topic){
          deleteList.add(dbTopic['publicKey']);
        }
      }
    }
    await DBWalletConnectV2.dbWalletConnectV2.deleteSignTByKey(deleteList);

  }

  _qrScanHandler(String value) {
    if (Uri.tryParse(value) != null) {
      signClient!.pair(value);
    }
  }

  @override
  void dispose() {
    setState(() {
      Utils.pageType1 = "";
    });
    super.dispose();
  }



  selectedAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      selectedAccountId = sharedPreferences.getString('accountId') ?? "";
      selectedAccountName = sharedPreferences.getString('accountName') ?? "";
      selectedAccountAddress =
          sharedPreferences.getString('accountAddress') ?? "";
      selectedAccountPrivateAddress =
          sharedPreferences.getString('accountPrivateAddress') ?? "";
      //print("$selectedAccountName");
    });


    Future.delayed(const Duration(seconds: 1),(){
      setState(() {
        _initializing = false;
      });
    });

  }

  getAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    selectedAccountId =  sharedPreferences.getString('accountId')??"";
    await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId,"2");

    setState((){
      selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
      selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.selectAccountPrivateAddress;
    });
  }
  
  @override
  Widget build(BuildContext context) {

    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        sessions!.value = signClient?.session.getAll();
      });

      if (sessions!.value!.isEmpty) {
        DBWalletConnectV2.dbWalletConnectV2.deleteAllSign();
      }

    });

    if (Utils.wcUrlVal != "") {
      if (Utils.wcUrlVal
          .split('?')
          .last
          .substring(0, 9) != "requestId") {
        signClient!.pair(Utils.wcUrlVal);
      }
      Utils.wcUrlVal = "";
    }

    
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
          "WalletConnect",
        ),
        actions: [
          InkWell(
              onTap: () async {
                final value = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrScannerPage()));
                if (value != null) {
                  setState(() {
                    var a = value.toString().split("@");

                    if (a[1][0] == "1") {
                      Helper.dialogCall.showToast(context, "Qr is not compatible with wallet connect v2 please use wallet connect v1 qr");
                    } else {
                      _qrScanHandler(value);
                    }
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Image.asset(
                  "assets/images/dashboard/scan.png",
                  width: 25,
                  height: 25,
                  color:  MyColor.whiteColor,
                ),
              )),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: sessions!,
        builder: (context, List<SessionStruct>? value, child) {
          return _initializing
              ?
          const Center(
            child: CircularProgressIndicator(
                color: Colors.greenAccent
            )
          )
              :
          Container(
            child: value!.isEmpty
                ?
            Center(
              child: Text(
                'No sessions found',
                style:  MyStyle.tx18RWhite.copyWith(
                    fontSize: 16
                ),
              )
            )
                :
            ListView.separated(
              itemBuilder: (_, idx) {
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  tileColor:MyColor.darkGrey01Color,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              signTransactions2(publicKey: value[idx].topic),
                        )
                    );
                  },
                  trailing: SizedBox(
                    height: 50,
                    width: 50,
                    child: InkWell(
                      onTap: () async {
                        String topic = value[idx].topic;
                        await signClient!.disconnect(topic: topic).then((
                            value) async {
                          signClient!.pairing.delete(topic,
                              getSdkError(SdkErrorKey.USER_DISCONNECTED))
                              .then((value) async {
                            // print("Pairing deleted");
                            setState(() {
                              sessions!.value = signClient?.session.getAll();
                              deleteWalletDB();
                            });
                          });
                        });
                      },
                      child: const Icon(
                        Icons.exit_to_app_rounded,
                        color:MyColor.whiteColor 
                      ),
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 6, top: 4),
                    child: Text(
                      value[idx].peer.metadata.name,
                      style:  MyStyle.tx18RWhite.copyWith(
                          fontSize: 14
                      ),
                    ),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      value[idx].peer.metadata.url,
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
              itemCount: value.length,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
          );
        },
      )
    );
  }
}
