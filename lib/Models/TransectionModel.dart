// To parse this JSON data, do
//
//     final transectionList = transectionListFromJson(jsonString);

import 'dart:convert';

List<TransectionList> transectionListFromJson(String str) => List<TransectionList>.from(json.decode(str).map((x) => TransectionList.fromJson(x)));

String transectionListToJson(List<TransectionList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransectionList {
  TransectionList({
    required this.transactionHash,
    required this.timeStamp,
    required this.from,
    required this.to,
    required this.value,
    required this.gas,
    required this.gasPrice,
    required this.gasUsed,
    required this.networkFees,
    required this.nonce,
    required this.txType,
    required this.status,
    required this.explorerUrl,
  });

  String transactionHash;
  String timeStamp;
  String from;
  String to;
  double value;
  String gas;
  String gasPrice;
  String gasUsed;
  String networkFees;
  String nonce;
  String txType;
  String status;
  String explorerUrl;

  factory TransectionList.fromJson(Map<String, dynamic> json) => TransectionList(
    transactionHash: json["transactionHash"],
    timeStamp: json["timeStamp"]??"",
    from: json["from"],
    to: json["to"],
    value: json["value"].toDouble(),
    gas: json["gas"],
    gasPrice: json["gasPrice"],
    gasUsed: json["gasUsed"] ?? "",
    networkFees: json["network_fees"],
    nonce: json["nonce"] ?? "",
    txType: json["txType"],
    status: json["status"],
    explorerUrl: json["explorer_url"],
  );

  Map<String, dynamic> toJson() => {
    "transactionHash": transactionHash,
    "timeStamp": timeStamp,
    "from": from,
    "to": to,
    "value": value,
    "gas": gas,
    "gasPrice": gasPrice,
    "gasUsed": gasUsed,
    "network_fees": networkFees,
    "nonce": nonce,
    "txType": txType,
    "status": status,
    "explorer_url": explorerUrl,
  };
}
