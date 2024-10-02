
class SearchTokenModel {
  int id;
  int marketId;
  int networkId;
  String networkName;
  String networkLogo;
  String name;
  String type;
  String address;
  String symbol;
  int decimals;
  String logo;

  SearchTokenModel({
    required this.id,
    required this.marketId,
    required this.networkId,
    required this.networkName,
    required this.networkLogo,
    required this.name,
    required this.type,
    required this.address,
    required this.symbol,
    required this.decimals,
    required this.logo,
  });

  factory SearchTokenModel.fromJson(Map<String, dynamic> json) => SearchTokenModel(
    id: json["id"],
    marketId: json["market_id"],
    networkId: json["network_id"],
    networkName: json["network_name"],
    networkLogo: json["network_logo"],
    name: json["name"],
    type: json["type"],
    address: json["address"],
    symbol: json["symbol"],
    decimals: json["decimals"],
    logo: json["logo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "market_id": marketId,
    "network_id": networkId,
    "network_name": networkName,
    "network_logo": networkLogo,
    "name": name,
    "type": type,
    "address": address,
    "symbol": symbol,
    "decimals": decimals,
    "logo": logo,
  };
}
