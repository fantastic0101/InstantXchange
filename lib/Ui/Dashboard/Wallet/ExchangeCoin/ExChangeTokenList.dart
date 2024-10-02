import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jost_pay_wallet/Provider/ExchangeProvider.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';

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


class ExChangeTokenList extends StatefulWidget {
  final String pageType;
  const ExChangeTokenList({
    super.key,
    required this.pageType
  });

  @override
  State<ExChangeTokenList> createState() => _ExChangeTokenListState();
}

class _ExChangeTokenListState extends State<ExChangeTokenList> {

  TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);

  late ExchangeProvider exchangeProvider;
  var selectedAccountId ="";

  getAcID() async {
    if(exchangeProvider.tempExTokenList.isNotEmpty){
      setState(() {
        exchangeProvider.searchExToList.clear();
        exchangeProvider.searchExToList.addAll(
            exchangeProvider.tempExTokenList
        );
      });
    }

  }


  @override
  void initState() {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: false);
    super.initState();
    getAcID();
  }

  @override
  Widget build(BuildContext context) {
    exchangeProvider = Provider.of<ExchangeProvider>(context,listen: true);

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
        title: Text(
          "Select ${widget.pageType} token",
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          //search filed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: searchController,
              cursorColor: MyColor.greenColor,
              style: MyStyle.tx18RWhite,
              onChanged: (value) {
                _debouncer.run(() async {
                  if(value.isNotEmpty){
                    setState(() {
                      exchangeProvider.searchExToList = exchangeProvider.exTokenList.where((element) {
                        return element.name.toLowerCase().contains(value.toLowerCase());
                      }).toList();
                    });
                  }else{
                    setState(() {
                      exchangeProvider.searchExToList.addAll(exchangeProvider.tempExTokenList);
                    });
                  }
                });
              },
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: MyColor.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: MyColor.boarderColor,
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: MyColor.boarderColor,
                    )
                ),
                hintText: "Search",
                hintStyle:MyStyle.tx22RWhite.copyWith(
                    fontSize: 14,
                    color: MyColor.grey01Color
                ),

              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
              itemCount: exchangeProvider.searchExToList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var list = exchangeProvider.searchExToList[index];
                return InkWell(
                  onTap: () async {
                    if(widget.pageType == "send"){
                      exchangeProvider.changeSendToken(list,context,"");
                    }else{
                      exchangeProvider.changeReceiveToken(list,context);
                    }
                  },
                  child : Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child:
                          SizedBox(
                            height: 25,
                            width: 25,
                            child: SvgPicture.network(
                              list.image,
                              fit: BoxFit.fill,
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
                                style: MyStyle.tx18RWhite.copyWith(
                                  fontSize: 14
                                ),
                              ),
                              Text(
                                "Symbol: ${list.ticker}",
                                style:MyStyle.tx18RWhite.copyWith(
                                    fontSize: 12,
                                    color: MyColor.grey01Color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
