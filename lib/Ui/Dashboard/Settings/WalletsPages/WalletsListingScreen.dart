import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_provider.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Models/newAccountModel.dart';
import 'package:jost_pay_wallet/Provider/Account_Provider.dart';
import 'package:jost_pay_wallet/Ui/Authentication/WelcomeScreen.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'WalletInfoPage.dart';

class WalletsListingScreen extends StatefulWidget {
  const WalletsListingScreen({super.key});

  @override
  State<WalletsListingScreen> createState() => _WalletsListingScreenState();
}

class _WalletsListingScreenState extends State<WalletsListingScreen> {

  String selectedAccountId = "";
  late AccountProvider accountProvider;

  getAllAccount()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    await DBAccountProvider.dbAccountProvider.getAllAccount();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    accountProvider = Provider.of<AccountProvider>(context, listen: false);

    getAllAccount();
  }

  setDefaultWallet(NewAccountList data) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    for(int i=0; i< DbAccountAddress.dbAccountAddress.allAccountAddress.length; i ++){
      if(DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicKeyName == "address"){
        if(mounted) {
          setState(() {
            String selectedAccountAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicAddress;
            String selectedAccountPrivateAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].privateAddress;
            sharedPreferences.setString('accountAddress', selectedAccountAddress);
            sharedPreferences.setString('accountPrivateAddress', selectedAccountPrivateAddress);
          });
        }
      }
    }
    setState(() {
       sharedPreferences.setString('accountId',data.id);
       sharedPreferences.setString('accountName',data.name);
       sharedPreferences.setDouble('myBalance',0);
       selectedAccountId = data.id;

    });
  }

  deleteAlert(String selectedAccountId,int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:  MyColor.backgroundColor,
        title: Text(
          "Are you sure?",
            style: MyStyle.tx18BWhite.copyWith(
                fontSize: 16
            )
        ),
        content:Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber,size: 17,color: MyColor.yellowColor,),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                "You want to delete this account?",
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 14
                  )
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "No",
              style: MyStyle.tx18RWhite.copyWith(
                 fontSize: 14
              )
            ),
          ),
          TextButton(
            onPressed: () {

              setState((){
                isLoading = true;
              });

              Navigator.pop(context);
              deleteAccount(selectedAccountId,index);

            },
            /*Navigator.of(context).pop(true)*/
            child: Text(
              "Yes",
              style: MyStyle.tx18RWhite.copyWith(
                fontSize: 14
              )
            ),
          ),
        ],
      ),
    );
  }

  late String deviceId;
  bool isLoading = false;
  deleteAccount(String selectedAccountId,int index) async {

    setState((){
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    deviceId = sharedPreferences.getString('deviceId')!;

    var data = {
      "id":selectedAccountId,
      "device_id":deviceId,
    };

    await accountProvider.deleteAccount(data,'/deleteAccount');

    if(accountProvider.isdeleted == true){
      deleteLocal(selectedAccountId,index);
    }

  }

  deleteLocal(String acId,int index) async {

    await DBTokenProvider.dbTokenProvider.deleteAccountToken(acId);
    await DBAccountProvider.dbAccountProvider.deleteAccount(acId);

    DBAccountProvider.dbAccountProvider.newAccountList.removeAt(index);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString('accountId', DBAccountProvider.dbAccountProvider.newAccountList[0].id);
    sharedPreferences.setString('accountName', DBAccountProvider.dbAccountProvider.newAccountList[0].name);
    setState((){
    selectedAccountId = DBAccountProvider.dbAccountProvider.newAccountList[0].id;
      isLoading = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    accountProvider = Provider.of<AccountProvider>(context, listen: true);

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
          "Wallets",
          // style:MyStyle.tx22RWhite.copyWith(fontSize: 22),
          // textAlign: TextAlign.center,
        ),
        actions: [
          InkWell(
            onTap: () async{
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                      isNew: true,
                    ),
                  )
              );
              getAllAccount();

            },
            child: Image.asset(
              "assets/images/dashboard/add.png",
              height: 25,
              width: 25,
              fit: BoxFit.contain,
              color: MyColor.mainWhiteColor,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView.builder(
        itemCount: DBAccountProvider.dbAccountProvider.newAccountList.length,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(15,20,15,10),
        itemBuilder: (context, index) {

          var list = DBAccountProvider.dbAccountProvider.newAccountList[index];

          return InkWell(
            onTap: () {

              var seedPhase = DBAccountProvider.dbAccountProvider.newAccountList[index].mnemonic;
              List seedPhaseList = [];
              if(seedPhase != ""){
                seedPhaseList = seedPhase.trim().split(" ");
              }

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalletInfoScreen(
                      accountId: DBAccountProvider.dbAccountProvider.newAccountList[index].id,
                      seedPhare: seedPhaseList,
                      name: DBAccountProvider.dbAccountProvider.newAccountList[index].name,
                    ),
                  )
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: MyColor.darkGreyColor
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    padding:const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedAccountId == list.id ? MyColor.greenColor : MyColor.greyColor,
                    ),
                    child: Image.asset(
                      "assets/images/dashboard/wallet.png",
                      fit: BoxFit.contain,
                      color: selectedAccountId == list.id ? MyColor.mainWhiteColor : MyColor.blackColor,
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style:MyStyle.tx18RWhite.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Multi-chain Wallet",
                          style:MyStyle.tx18RWhite.copyWith(
                              fontSize: 12,
                              color: MyColor.grey01Color
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  const SizedBox(width: 10),

                  Visibility(
                    visible:   DBAccountProvider.dbAccountProvider.newAccountList.length > 1,
                    child: PopupMenuButton(
                      color: MyColor.boarderColor,
                      icon: const Icon(
                        Icons.more_vert,
                        color: MyColor.mainWhiteColor,
                      ),
                      offset: const Offset(0,40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)
                      ),
                      onSelected: (value) {
                        if(value =="select"){
                          if(selectedAccountId != list.id ){
                            setDefaultWallet(list);
                          }
                        }else{
                          deleteAlert(list.id,index);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: "select",
                          child: Row(
                            children: [

                              Icon(
                                selectedAccountId == list.id ? Icons.radio_button_checked : Icons.radio_button_off,
                                color:selectedAccountId == list.id ? MyColor.greenColor : MyColor.greyColor,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                selectedAccountId == list.id ?
                                'Default Wallet'
                                    :
                                'Set Default Wallet',
                                style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 15
                                ),
                              ),
                            ],
                          ),
                        ),

                        PopupMenuItem(
                          value: "delete",
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.delete,
                                color: MyColor.mainWhiteColor,
                              ),

                              const SizedBox(width: 8),
                              Text(
                                'Delete Wallet',
                                style: MyStyle.tx18RWhite.copyWith(
                                    fontSize: 15
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
