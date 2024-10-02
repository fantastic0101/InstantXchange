class LoginModel {
  String accountExists;
  String accountVerified;
  String success;
  String accessToken;
  String info;
  List<RatesInfo> ratesInfo;
  List<String> banks;
  List<String> sellBanks;

  LoginModel({
    required this.accountExists,
    required this.accountVerified,
    required this.success,
    required this.accessToken,
    required this.info,
    required this.ratesInfo,
    required this.banks,
    required this.sellBanks,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json,List<RatesInfo> rateList) => LoginModel(
    accountExists: json["account_exists"],
    accountVerified: json["account_verified"],
    success: json["success"],
    accessToken: json["access_token"],
    info: json["info"],
    ratesInfo: rateList,
    banks: json["banks"] == null ? [] : List<String>.from(json["banks"].map((x) => x)),
    sellBanks: json["sell_banks"] == null ? [] : List<String>.from(json["sell_banks"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "account_exists": accountExists,
    "account_verified": accountVerified,
    "success": success,
    "access_token": accessToken,
    "info": info,
    "rates_info": ratesInfo,
    "banks": banks,
    "sell_banks":sellBanks
  };

}

class RatesInfo {
  String name;
  int buyPrice;
  int sellPrice;
  int minBuyAmount;
  int minSellAmount;
  int lowBuy;
  int lowBuyPrice;
  List<String> networkFees;
  String memoLabel;
  String itemCode;

  RatesInfo({
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    required this.minBuyAmount,
    required this.minSellAmount,
    required this.lowBuy,
    required this.lowBuyPrice,
    required this.networkFees,
    required this.memoLabel,
    required this.itemCode,
  });

  factory RatesInfo.fromJson(Map<String, dynamic> json,item_code) => RatesInfo(
    name: json["name"],
    buyPrice: json["buy_price"],
    sellPrice: json["sell_price"],
    minBuyAmount: json["min_buy_amount"],
    minSellAmount: json["min_sell_amount"],
    lowBuy: json["low_buy"],
    lowBuyPrice: json["low_buy_price"],
    networkFees: List<String>.from(json["network_fees"].map((x) => x)),
    memoLabel: json["memo_label"],
    itemCode: item_code,
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "buy_price": buyPrice,
    "sell_price": sellPrice,
    "min_buy_amount": minBuyAmount,
    "min_sell_amount": minSellAmount,
    "low_buy": lowBuy,
    "low_buy_price": lowBuyPrice,
    "network_fees": List<dynamic>.from(networkFees.map((x) => x)),
    "memo_label": memoLabel,
    "itemCode":itemCode
  };
}


