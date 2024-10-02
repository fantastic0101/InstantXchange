class AccountTokenList {
  AccountTokenList({
    required this.id,
    required this.token_id,
    required this.accAddress,
    required this.networkId,
    required this.marketId,
    required this.name,
    required this.type,
    required this.address,
    required this.symbol,
    required this.decimals,
    required this.logo,
    required this.balance,
    required this.networkName,
    required this.price,
    required this.percentChange24H,
    required this.accountId,
    required this.explorer_url,
  });

  int id;
  int token_id;
  String accAddress;
  int networkId;
  int marketId;
  String name;
  String type;
  String address;
  String symbol;
  int decimals;
  String logo;
  String balance;
  String networkName;
  double price;
  double percentChange24H;
  String accountId;
  String explorer_url;

  factory AccountTokenList.fromJson(Map<String, dynamic> json,String accountId) => AccountTokenList(
    id: json["id"],
    token_id: json["token_id"],
    accAddress: json["acc_address"],
    networkId: json["network_id"],
    marketId: json["market_id"],
    name: json["name"],
    type: json["type"],
    address: json["address"],
    symbol: json["symbol"],
    decimals: json["decimals"],
    logo: json["logo"],
    balance: json["balance"],
    networkName: json["network_name"],
    price: json["price"] == null ? 0.0 : json["price"].toDouble(),
    percentChange24H: json["percent_change_24h"] == null ? 0.0 : json["percent_change_24h"].toDouble(),
    accountId : accountId,
    explorer_url: json["explorer_url"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "token_id": token_id,
    "acc_address": accAddress,
    "network_id": networkId,
    "market_id": marketId,
    "explorer_url": explorer_url,
    "name": name,
    "type": type,
    "address": address,
    "symbol": symbol,
    "decimals": decimals,
    "logo": logo,
    "balance": balance,
    "network_name": networkName,
    "price": price,
    "percent_change_24h": percentChange24H,
    "accountId": accountId,
  };
}
