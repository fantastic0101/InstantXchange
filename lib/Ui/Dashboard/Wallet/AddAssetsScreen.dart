import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Account_address.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Token_provider.dart';
import 'package:jost_pay_wallet/Provider/Token_Provider.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Debouncer {
  final int milliseconds;
  late VoidCallback action;
  Timer? timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

// ignore: must_be_immutable
class AddAssetsScreen extends StatefulWidget {
  String selectedAccountId;
  AddAssetsScreen({
    super.key,
    required this.selectedAccountId
  });

  @override
  State<AddAssetsScreen> createState() => _AddAssetsScreenState();
}

class _AddAssetsScreenState extends State<AddAssetsScreen> {

  TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  List toggleList = [];
  bool isLoading = true;

  var selectedAccountId = "",selectedAccountName = "";

  late TokenProvider tokenProvider;


  getSearchToken() async {

    setState(() {
      isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    selectedAccountId = sharedPreferences.getString('accountId') ?? "";
    selectedAccountName = sharedPreferences.getString('accountName') ?? "";
    await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);

    for(int i=0; i< DbAccountAddress.dbAccountAddress.allAccountAddress.length; i ++){

      if(DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicKeyName == "address"){
        selectedAccountAddress = DbAccountAddress.dbAccountAddress.allAccountAddress[i].publicAddress;
      }
    }

    var data = {
      "search_term": "",
    };
    await tokenProvider.getSearchToken(data,'/getTokens');

    setState(() {
      isLoading = false;
    });
  }


  String selectedTokenType='',token_normal_id = "",
      tokenId = "",tokenAddress="",tokan_name = "",token_symbol = "",tokan_decimals = "",network_id ="",selectedAccountAddress = "";

  addCustomToken(index,val) async {

    Helper.dialogCall.showAlertDialog(context);

    var data = {
      "network_id": network_id,
      "tokenAddress": tokenAddress,
      "type":selectedTokenType,
      "name":tokan_name,
      "symbol":token_symbol,
      "decimals":tokan_decimals,
      "address":  selectedAccountAddress,
    };
    //print("add token data //print ");
    // print("${json.encode(data)}");
    await tokenProvider.addCustomToken(data,'/addToken',selectedAccountId);
    if(tokenProvider.isTokenAdded == false){

      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Token already added to this account");

      setState(() {
        // isLoading = false;

        network_id = "";
        tokenAddress = "";
        selectedTokenType = "";
        token_symbol = "";
        tokan_name = "";
        tokan_decimals = "";

      });
      Navigator.pop(context);

    }
    else{

      setState(() {
        tokenProvider.selectTokenBool[index]["isSelected"] = val;
      });

      network_id = "";
      selectedTokenType = "";
      token_symbol = "";
      tokan_name = "";
      tokan_decimals = "";

      // DBTokenProvider.dbTokenProvider.deleteAccountToken(selectedAccountId);

      await DbAccountAddress.dbAccountAddress.getAccountAddress(selectedAccountId);

      var data = {};

      for (int j = 0; j < DbAccountAddress.dbAccountAddress.allAccountAddress.length; j++) {
        data[DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicKeyName] = DbAccountAddress.dbAccountAddress.allAccountAddress[j].publicAddress;
      }


      await tokenProvider.getAccountToken(data, '/getAccountTokens', selectedAccountId);

      await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);

      Navigator.pop(context,"Refresh");
      Navigator.pop(context,"Refresh");


    }
  }


  // Delete Token Flow
  deleteToken(String tokenId) async {
    Helper.dialogCall.showAlertDialog(context);

    await DBTokenProvider.dbTokenProvider.getAccountToken(selectedAccountId);
    var index = DBTokenProvider.dbTokenProvider.tokenList.indexWhere((element) =>"${element.token_id}" == tokenId);

    if(index != -1){
      // ignore: use_build_context_synchronously
      var data = {
        "token_id": DBTokenProvider.dbTokenProvider.tokenList[index].id,
      };

      // print(data);
      await tokenProvider.deleteToken(data,'/deleteAccountToken');

      // ignore: use_build_context_synchronously
      Navigator.pop(context,"refresh");
      // ignore: use_build_context_synchronously
      Navigator.pop(context,"refresh");
      await DBTokenProvider.dbTokenProvider.deleteToken(DBTokenProvider.dbTokenProvider.tokenList[index].id.toString());
      DBTokenProvider.dbTokenProvider.tokenList.removeAt(index);

    }else{
      // ignore: use_build_context_synchronously
      Helper.dialogCall.showToast(context, "Coin not added in wallet coin list");
      Navigator.pop(context,"refresh");
    }


  }

  @override
  void initState() {
    super.initState();
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    Future.delayed(Duration.zero,(){
      getSearchToken();
    });
  }


  @override
  Widget build(BuildContext context) {
    tokenProvider = Provider.of<TokenProvider>(context, listen: true);

    return  Padding(
      padding: const EdgeInsets.fromLTRB(20,22,20,10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // dos icon
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColor.lightGreyColor
            ),
          ),
          const SizedBox(height: 25),

          // add assets text
          Text(
            "Add Asset",
            style: MyStyle.tx28RGreen.copyWith(
              color: MyColor.mainWhiteColor,
              fontFamily: "NimbusSanLBol",
              fontSize: 22
            ),
          ),
          const SizedBox(height: 25),

          //search filed
          TextFormField(
            controller: searchController,
            cursorColor: MyColor.greenColor,
            style: MyStyle.tx18RWhite,
            onChanged: (value) {
              _debouncer.run(() async {

              });
            },
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: MyColor.darkGrey01Color,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: MyColor.darkGrey01Color,
                )
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: MyColor.darkGrey01Color,
                  )
              ),
              hintText: "Search",
              hintStyle:MyStyle.tx22RWhite.copyWith(
                  fontSize: 14,
                  color: MyColor.grey01Color
              ),

            ),
          ),
          const SizedBox(height: 25),

          // coin list
          Expanded(
            child : isLoading
                ?
            const Center(
                child: CircularProgressIndicator(
                  color: MyColor.greenColor,
                )
            )
                :
            ListView.builder(
              itemCount: tokenProvider.searchTokenList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {

                var list = tokenProvider.searchTokenList[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          height: 35,
                          width: 35,
                          fit: BoxFit.fill,
                          imageUrl: list.logo,
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
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list.name,
                              style: MyStyle.tx18RWhite,
                            ),
                            Visibility(
                              visible: list.type.isNotEmpty,
                              child: Text(
                                "type: ${list.type}",
                                style:MyStyle.tx18RWhite.copyWith(
                                    fontSize: 13,
                                    color: MyColor.grey01Color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      FlutterSwitch(
                        width: 50.0,
                        height: 24.0,
                        toggleSize: 15.0,
                        valueFontSize: 0.0,
                        borderRadius: 30.0,
                        inactiveColor: MyColor.boarderColor,
                        activeColor: MyColor.greenColor,
                        value: tokenProvider.selectTokenBool[index]["isSelected"],
                        showOnOff: false,
                        onToggle: (val) async{
                          if(val){
                            await DbAccountAddress.dbAccountAddress.getPublicKey(selectedAccountId, list.networkId);

                            setState(() {
                              selectedAccountAddress = DbAccountAddress.dbAccountAddress.selectAccountPublicAddress;
                              tokenProvider.isSearch = false;
                              network_id = "${list.networkId}";
                              token_normal_id = "${list.id}";
                              tokenId = "${list.marketId}";
                              tokan_name = list.name;
                              tokenAddress = list.address;
                              selectedTokenType = list.type;
                              token_symbol = list.symbol;
                              tokan_decimals = "${list.decimals}";
                            });

                            addCustomToken(index,val);
                          }else{
                            deleteToken("${list.id}");
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
