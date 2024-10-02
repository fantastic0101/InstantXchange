class ExTransactionModel {
  String status;
  String payinAddress;
  String payoutAddress;
  String fromCurrency;
  String toCurrency;
  DateTime validUntil;
  String id;
  DateTime updatedAt;
  double expectedSendAmount;
  double expectedReceiveAmount;
  DateTime createdAt;
  String isPartner;
  String payinExtraId;
  String payinExtraIdName;

  ExTransactionModel({
    required this.status,
    required this.payinAddress,
    required this.payoutAddress,
    required this.fromCurrency,
    required this.toCurrency,
    required this.validUntil,
    required this.id,
    required this.updatedAt,
    required this.expectedSendAmount,
    required this.expectedReceiveAmount,
    required this.createdAt,
    required this.isPartner,
    required this.payinExtraId,
    required this.payinExtraIdName,
  });

  factory ExTransactionModel.fromJson(Map<String, dynamic> json,) => ExTransactionModel(
    status: json["status"],
    payinAddress: json["payinAddress"],
    payoutAddress: json["payoutAddress"],
    fromCurrency: json["fromCurrency"],
    toCurrency: json["toCurrency"],
    validUntil: DateTime.parse(json["validUntil"]),
    id: json["id"],
    updatedAt: DateTime.parse(json["updatedAt"]),
    expectedSendAmount: json["expectedSendAmount"] == null ? json['amountSend']?.toDouble() : json["expectedSendAmount"]?.toDouble(),
    expectedReceiveAmount: json["expectedReceiveAmount"]?.toDouble(),
    createdAt: DateTime.parse(json["createdAt"]),
    isPartner: json["isPartner"].toString(),
    payinExtraId: json["payinExtraId"]??"",
    payinExtraIdName: json["payinExtraIdName"]??"",
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "payinAddress": payinAddress,
    "payoutAddress": payoutAddress,
    "fromCurrency": fromCurrency,
    "toCurrency": toCurrency,
    "validUntil": validUntil.toIso8601String(),
    "id": id,
    "updatedAt": updatedAt.toIso8601String(),
    "expectedSendAmount": expectedSendAmount,
    "expectedReceiveAmount": expectedReceiveAmount,
    "createdAt": createdAt.toIso8601String(),
    "isPartner": isPartner.toString(),
    "payinExtraIdName": payinExtraIdName,
    "payinExtraId": payinExtraId,
  };
}
