class BuySellHistoryModel {
  String invoiceNo;
  String status;
  String date;
  Details details;

  BuySellHistoryModel({
    required this.invoiceNo,
    required this.status,
    required this.date,
    required this.details,
  });

  factory BuySellHistoryModel.fromJson(Map<String, dynamic> json) => BuySellHistoryModel(
    invoiceNo: json["invoice_no"],
    status: json["status"],
    date: json["date"],
    details: Details.fromJson(json["details"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "status": status,
    "date": date,
    "details": details.toJson(),
  };
}

class Details {
  String transactionType;
  String currency;
  String amount;
  String amountRaw;
  String paymentChannel;
  String amountPayable;
  String vat;
  String currencyAccount;
  String bank;
  String networkFee;
  String amountRawFull;
  String tetherUsdtTrc20AccountTp1SpeHyDpCzQvmaMui98Ka83YgBdSoGb3;
  String exchangeCurrency;
  String customerEmail;
  String apiExpiry;
  String adminCommentTesting;
  String adminCommentTest;
  String accountNo;
  String accountName;
  String usdttrc20PayinAddress;
  String apiLink;
  String adminCommentTrue;
  String newBalance;
  String payin_Address;

  Details({
    required this.transactionType,
    required this.currency,
    required this.amount,
    required this.amountRaw,
    required this.paymentChannel,
    required this.amountPayable,
    required this.vat,
    required this.currencyAccount,
    required this.bank,
    required this.networkFee,
    required this.amountRawFull,
    required this.tetherUsdtTrc20AccountTp1SpeHyDpCzQvmaMui98Ka83YgBdSoGb3,
    required this.exchangeCurrency,
    required this.customerEmail,
    required this.apiExpiry,
    required this.adminCommentTesting,
    required this.adminCommentTest,
    required this.accountNo,
    required this.accountName,
    required this.usdttrc20PayinAddress,
    required this.apiLink,
    required this.adminCommentTrue,
    required this.newBalance,
    required this.payin_Address,
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
    transactionType: json["Transaction_Type"]??"",
    currency: json["Currency"]??"",
    amount: json["Amount"]??"",
    amountRaw: json["Amount_Raw"]??"",
    paymentChannel: json["Payment_Channel"]??"",
    amountPayable: json["Amount_Payable"]??"",
    vat: json["VAT"]??"",
    currencyAccount: json["Currency_Account"]??"",
    bank: json["Bank"]??"",
    networkFee: json["Network_Fee"]??"",
    amountRawFull: json["Amount_Raw_Full"]??"",
    tetherUsdtTrc20AccountTp1SpeHyDpCzQvmaMui98Ka83YgBdSoGb3: json["Tether_USDT_-_TRC20__Account_:_TP1SpeHyDPCzQVMAMui98KA83ygBDSoGb3"]??"",
    exchangeCurrency: json["Exchange_Currency"]??"",
    customerEmail: json["Customer_Email"]??"",
    apiExpiry: json["API_Expiry"]??"",
    adminCommentTesting: json["Admin_Comment_:_testing"]??"",
    adminCommentTest: json["Admin_Comment_:_test"]??"",
    accountNo: json["Account_No"]??"",
    accountName: json["Account_Name"]??"",
    usdttrc20PayinAddress: json["USDTTRC20_Payin_Address"]??"",
    apiLink: json["API_Link"]??"",
    adminCommentTrue: json["Admin_Comment_:_true"]??"",
    newBalance: json["New_Balance"]??"",
    payin_Address: json["${json['Amount_Raw_Full'].toString().split(" ").last}_Payin_Address"]??"",
  );
  }

  Map<String, dynamic> toJson() => {
    "Transaction_Type": transactionType,
    "Currency": currency,
    "Amount": amount,
    "Amount_Raw": amountRaw,
    "Payment_Channel": paymentChannel,
    "Amount_Payable": amountPayable,
    "VAT": vat,
    "Currency_Account": currencyAccount,
    "Bank": bank,
    "Network_Fee": networkFee,
    "Amount_Raw_Full": amountRawFull,
    "Tether_USDT_-_TRC20__Account_:_TP1SpeHyDPCzQVMAMui98KA83ygBDSoGb3": tetherUsdtTrc20AccountTp1SpeHyDpCzQvmaMui98Ka83YgBdSoGb3,
    "Exchange_Currency": exchangeCurrency,
    "Customer_Email": customerEmail,
    "API_Expiry": apiExpiry,
    "Admin_Comment_:_testing": adminCommentTesting,
    "Admin_Comment_:_test": adminCommentTest,
    "Account_No": accountNo,
    "Account_Name": accountName,
    "USDTTRC20_Payin_Address": usdttrc20PayinAddress,
    "API_Link": apiLink,
    "Admin_Comment_:_true": adminCommentTrue,
    "New_Balance": newBalance,
    "payin_Address": payin_Address,
  };
}



