import 'dart:convert';

List<AccountAddress> productFromJson(String str) =>
    List<AccountAddress>.from(json.decode(str).map((x) => AccountAddress.fromJson(x)));

class AccountAddress {
  AccountAddress({
    required this.accountId,
    required this.publicAddress,
    required this.privateAddress,
    required this.publicKeyName,
    required this.privateKeyName,
    required this.networkId,
    required this.networkName
  });

  String accountId;
  String publicAddress;
  String privateAddress;
  String publicKeyName;
  String privateKeyName;
  String networkId;
  String networkName;

  factory AccountAddress.fromJson(Map<String, dynamic> json) => AccountAddress(
    accountId: json["accountId"],
    publicAddress: json["publicAddress"],
    privateAddress: json["privateAddress"],
    publicKeyName: json["publicKeyName"],
    privateKeyName: json["privateKeyName"],
    networkId: json["networkId"],
    networkName: json["networkName"],
  );

}
