class SellHistoryModel {
  int amountPayableNgn;
  String invoice;
  String orderStatus;
  String invoiceNo;
  String invoiceUrl;
  int time;
  String type;
  String payinAmount;
  String payoutAmount;
  String payoutAddress;
  String accountId;
  String payin_address;
  String payinUrl;
  String tokenName;
  String bank;
  String accountNo;
  String accountName;

  SellHistoryModel({
    required this.amountPayableNgn,
    required this.invoice,
    required this.orderStatus,
    required this.invoiceNo,
    required this.invoiceUrl,
    required this.time,
    required this.type,
    required this.payinAmount,
    required this.payoutAmount,
    required this.payoutAddress,
    required this.accountId,
    required this.payin_address,
    required this.payinUrl,
    required this.tokenName,
    required this.bank,
    required this.accountNo,
    required this.accountName,
  });

  factory SellHistoryModel.fromJson(Map<String, dynamic> json,acId,name,bankName,acNo,acName) {
    // print("model id $acName");
    return SellHistoryModel(
      amountPayableNgn: json["amount_payable_ngn"]??0,
      invoice: json["invoice"]??"",
      orderStatus: json["order_status"]??"",
      invoiceNo: json["invoice_no"]??"",
      invoiceUrl: json["invoice_url"]??"",
      time: int.parse("${json["time"]}"),
      type: json["type"]??"",
      payinAmount: json["payin_amount"]??"",
      payoutAmount: json["payout_amount"]??"",
      payin_address: json["payin_address"]??"",
      accountId: acId,
      payoutAddress:json["payout_address"]??"",
      payinUrl: json["payin_url"]??"",
      tokenName: name??"",
      accountName: acName,
      accountNo: acNo,
      bank: bankName
    );
  }

  Map<String, dynamic> toJson() => {
    "amount_payable_ngn": amountPayableNgn,
    "invoice": invoice,
    "order_status": orderStatus,
    "invoice_no": invoiceNo,
    "invoice_url": invoiceUrl,
    "time": time,
    "type": type,
    "payin_amount": payinAmount,
    "payout_amount": payoutAmount,
    "payout_address": payoutAddress,
    "payin_address": payin_address,
    "payin_url": payinUrl,
    "accountId": accountId,
    "tokenName": tokenName,
    "accountNo": accountNo,
    "bank": bank,
    "accountName": accountName,
  };
}
