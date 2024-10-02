
import 'package:flutter/material.dart';
import 'package:jost_pay_wallet/LocalDb/Local_Network_Provider.dart';
import 'package:jost_pay_wallet/Provider/BuySellProvider.dart';
import 'package:jost_pay_wallet/Provider/DashboardProvider.dart';
import 'package:jost_pay_wallet/Ui/Dashboard/Sell/SellHistory.dart';
import 'package:jost_pay_wallet/Values/Helper/helper.dart';
import 'package:jost_pay_wallet/Values/MyColor.dart';
import 'package:jost_pay_wallet/Values/MyStyle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SellValidationPage.dart';

class SellScreen extends StatefulWidget {

  const SellScreen({
    super.key,
  });

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {

  TextEditingController priceController = TextEditingController();
  TextEditingController bankNoController = TextEditingController();
  TextEditingController acNameController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? selectedBank,selectedAccountId = "",networkFees,sellBank;
  bool isLoading = false;
  var usdError = "",emailError = "";

  var selectedCoin;

  late BuySellProvider buySellProvider;
  late DashboardProvider dashboardProvider;

  sellValidateOrder(context)async{

    SharedPreferences sharedPre = await SharedPreferences.getInstance();
    selectedAccountId = sharedPre.getString('accountId') ?? "";
    var email = sharedPre.getString("email")??"";
    setState(() {
      emailController.text = email;
    });
    await DbNetwork.dbNetwork.getNetwork();

    var params = {
      "action":"validate_sell_order",
      "email":emailController.text.isEmpty ? "a@gmail.com" : emailController.text.trim(),
      // "token":"",
      "token":buySellProvider.loginModel== null ? "" : buySellProvider.loginModel!.accessToken,
      "item_code":selectedCoin == null ? "" : selectedCoin['symbol'],
      "amount":priceController.text.trim(),
      "bank":sellBank ?? "",
      "account_no":bankNoController.text.trim(),
      "account_name":acNameController.text.trim(),
      "phone":phoneNoController.text,
      "auth":"p1~\$*)Ze(@"
    };

    // print("object ${jsonEncode(params)}");

    await buySellProvider.validateSellOrder(params,selectedAccountId,context,"");

    setState(() {
      emailController.text = email;
    });

    // print(buySellProvider.getSellValidation);

    if(buySellProvider.getSellValidation != null){

     var value =  await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellValidationPage(
              params: params,
              coinName: selectedCoin['name'],
              pageName: "",
              sendData: null,
            ),
          )
      );

     // print("object value --> ${value}");
     if(value != null) {
       setState(() {
         priceController.text = "";
         phoneNoController.clear();
         bankNoController.clear();
         acNameController.clear();
         selectedCoin = null;
         sellBank = null;
       });
     }
    }

  }

  @override
  void initState() {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: false);
    dashboardProvider = Provider.of<DashboardProvider>(context,listen: false);
    buySellProvider.accessToken = "";
    buySellProvider.sellBankList = [];
    buySellProvider.sellRateList = [];
    super.initState();
    Future.delayed(Duration.zero,(){
      sellValidateOrder(context);
    });


  }

  @override
  Widget build(BuildContext context) {
    buySellProvider = Provider.of<BuySellProvider>(context,listen: true);
    dashboardProvider = Provider.of<DashboardProvider>(context,listen: true);

    // print(selectedCoin);
    return buySellProvider.sellValidOrder
        ?
    Helper.dialogCall.showLoader()
        :
    Column(
      children: [

        Row(
          children: [
            const Expanded(child: SizedBox()),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellHistory(),
                      )
                  );
                },
                icon: const Icon(
                  Icons.history,
                  color: MyColor.mainWhiteColor,
                )
            )
          ],
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // coin drop down
                DropdownButtonFormField<dynamic>(
                  // value: selectedCoin,
                  decoration: MyStyle.textInputDecoration.copyWith(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: MyColor.greenColor,
                  ),
                  hint: Text(
                    "Select coin",
                    style:MyStyle.tx22RWhite.copyWith(
                        fontSize: 18,
                        color: MyColor.whiteColor.withOpacity(0.7)
                    ),
                  ),
                  dropdownColor: MyColor.backgroundColor,
                  isExpanded: true,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                  items: buySellProvider.sellRateList.where((element) => element['name'] == "Perfectmoney").toList().map((dynamic tokenData) {
                    // print("dropDown value $tokenData");
                    return DropdownMenuItem(
                        value: tokenData,
                        child: Text(
                          tokenData['name'],
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        )
                    );
                  }).toList(),
                  onChanged: (dynamic value) async {
                    setState(() {
                      networkFees = null;
                      selectedCoin = null;
                      selectedCoin = value;
                      //print(selectedCoin['name']);
                      //print(value['name']);
                      priceController.clear();
                    });


                  },
                ),
                const SizedBox(height: 20),

                // Withdraw amount
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: priceController,
                  cursorColor: MyColor.greenColor,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                  onChanged: (value){
                    if(value.isNotEmpty) {
                      if (double.parse(value) <
                          selectedCoin['minSellAmount']) {
                        usdError =
                        "Min. ${selectedCoin['minSellAmount']}";
                      } else {
                        usdError = "";
                      }
                    }
                    setState(() {});
                  },
                  decoration: MyStyle.textInputDecoration.copyWith(
                      hintText: "Sell amount",
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                      suffixIcon: SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            "USD",
                            style: MyStyle.tx18BWhite.copyWith(
                                fontSize: 16
                            ),
                          ),
                        ),
                      )
                  ),
                ),
                Visibility(
                    visible: usdError.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0,left: 10),
                      child: Text(
                        usdError,
                        style: MyStyle.tx18BWhite.copyWith(
                            color: MyColor.redColor,
                            fontSize: 14
                        ),
                      ),
                    )
                ),
                const SizedBox(height: 20),

                // Bank Account No.
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: bankNoController,
                  cursorColor: MyColor.greenColor,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: MyStyle.textInputDecoration.copyWith(
                    hintText: "Bank Account No.",
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                  ),

                ),
                const SizedBox(height: 20),

                // Account Name
                TextFormField(
                  controller: acNameController,
                  cursorColor: MyColor.greenColor,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: MyStyle.textInputDecoration.copyWith(
                    hintText: "Account Name",
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  ),
                ),
                const SizedBox(height: 20),

                // bank DropDown
                DropdownButtonFormField<String>(
                  value: sellBank,
                  isExpanded: true,
                  decoration: MyStyle.textInputDecoration.copyWith(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: MyColor.greenColor,
                  ),
                  hint: Text(
                    "Select Bank",
                    style:MyStyle.tx22RWhite.copyWith(
                        fontSize: 18,
                        color: MyColor.whiteColor.withOpacity(0.7)
                    ),
                  ),
                  dropdownColor: MyColor.backgroundColor,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),

                  items: buySellProvider.sellBankList.map((String category) {

                    return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: MyStyle.tx18RWhite.copyWith(
                              fontSize: 16
                          ),
                        )
                    );
                  }).toList(),
                  onChanged: (String? value) async {
                    setState(() {
                      sellBank = value;
                    });
                  },
                ),
                const SizedBox(height: 20),


                // Your Phone No
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: phoneNoController,
                  cursorColor: MyColor.greenColor,
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: MyStyle.textInputDecoration.copyWith(
                    hintText: "Your Phone No",
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                  ),

                ),
                const SizedBox(height: 20),

                // Your Email Address
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  cursorColor: MyColor.greenColor,
                  onChanged: (value) {
                    RegExp checkMail =  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                    if(!checkMail.hasMatch(value)){
                      emailError = "Please enter valid email id.";
                    }else{
                      emailError = "";
                    }
                    setState(() {});
                  },
                  style: MyStyle.tx18RWhite.copyWith(
                      fontSize: 16
                  ),
                  decoration: MyStyle.textInputDecoration.copyWith(
                    hintText: "Your Email Address",
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),

                  ),

                ),
                Visibility(
                    visible: emailError.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12.0,left: 10),
                      child: Text(
                        emailError,
                        style: MyStyle.tx18BWhite.copyWith(
                            color: MyColor.redColor,
                            fontSize: 14
                        ),
                      ),
                    )
                ),
                const SizedBox(height: 40),

                // Proceed button

                buySellProvider.sellValidOrder
                    ?
                Helper.dialogCall.showLoader()
                    :
                selectedCoin == null || priceController.text.isEmpty
                    || sellBank == null || emailError.isNotEmpty
                    // || double.parse(selectedCoin['amount']) < double.parse(priceController.text)
                    || phoneNoController.text.isEmpty
                    || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                    ?
                InkWell(
                  onTap: () {
                    if(double.parse(selectedCoin['amount']) < double.parse(priceController.text)){
                      Helper.dialogCall.showToast(context, "Insufficient balance");
                    }else{
                      Helper.dialogCall.showToast(context, "Please provider all details");
                    }
                    setState(() {});
                  },
                  child : Container(
                    alignment: Alignment.center,
                    height: 45,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration:
                    selectedCoin == null || priceController.text.isEmpty || sellBank == null
                        ||  phoneNoController.text.isEmpty ||emailError.isNotEmpty
                        // || double.parse(selectedCoin['amount']) < double.parse(priceController.text)
                        || acNameController.text.isEmpty || bankNoController.text.isEmpty || emailController.text.isEmpty
                        ?
                    MyStyle.invalidDecoration
                        :
                    MyStyle.buttonDecoration,

                    child: Text(
                        "Continue",
                        style:  MyStyle.tx18BWhite.copyWith(
                            color:  selectedCoin == null || priceController.text.isEmpty || sellBank == null
                                || phoneNoController.text.isEmpty
                                // || double.parse(selectedCoin['amount']) < double.parse(priceController.text)
                                || acNameController.text.isEmpty || bankNoController.text.isEmpty
                                || emailController.text.isEmpty
                                ?
                            MyColor.mainWhiteColor.withOpacity(0.4)
                                :
                            MyColor.mainWhiteColor
                        )
                    ),
                  ),
                )
                    :
                InkWell(
                  onTap: () {
                    sellValidateOrder(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 45,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: MyStyle.buttonDecoration,
                    child: const Text(
                      "Proceed",
                      style: MyStyle.tx18BWhite,
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ],
    );
  }
}
