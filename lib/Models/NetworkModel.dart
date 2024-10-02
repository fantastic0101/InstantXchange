import 'dart:convert';

NetworkModel networkModelFromJson(String str) => NetworkModel.fromJson(json.decode(str));

String networkModelToJson(NetworkModel data) => json.encode(data.toJson());

class NetworkModel {
  NetworkModel({
    required this.status,
    required this.data,
  });

  bool status;
  List<NetworkList> data;

  factory NetworkModel.fromJson(Map<String, dynamic> json) => NetworkModel(
    status: json["status"],
    data: List<NetworkList>.from(json["data"].map((x,int isCustom) => NetworkList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class NetworkList {
  NetworkList({
    required this.id,
    required this.name,
    required this.symbol,
    required this.weth,
    required this.logo,
    required this.url,
    required this.chain,
    required this.note,
    required this.tokenType,
    required this.explorerUrl,
    required this.publicKeyName,
    required this.privateKeyName,
    required this.tokenEnable,
    required this.swapEnable,
    required this.isTxfees,
    required this.isEVM,
  });

  int id;
  String name;
  String symbol;
  String weth;
  String logo;
  String url;
  int chain;
  String tokenType;
  String explorerUrl;
  String publicKeyName;
  String privateKeyName;
  int tokenEnable;
  int swapEnable;
  int isTxfees;
  int isEVM;
  String note;

  factory NetworkList.fromJson(Map<String, dynamic> json) => NetworkList(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    weth: json["weth"],
    logo: json["logo"],
    url: json["url"],
    chain: json["chain"],
    tokenType: json["tokenType"],
    explorerUrl: json["explorer_url"],
    publicKeyName: json["publicKeyName"],
    privateKeyName: json["privateKeyName"],
    tokenEnable: json["tokenEnable"],
    swapEnable: json["swapEnable"],
    isTxfees: json["isTxfees"],
    isEVM: json["isEVM"],
    note: json["note"]??"",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "weth": weth,
    "logo": logo,
    "url": url,
    "chain": chain,
    "note": note,
    "tokenType": tokenType,
    "explorer_url": explorerUrl,
    "publicKeyName": publicKeyName,
    "privateKeyName": privateKeyName,
    "tokenEnable": tokenEnable,
    "swapEnable": swapEnable,
    "isTxfees": isTxfees,
    "isEVM": isEVM,
  };
}
