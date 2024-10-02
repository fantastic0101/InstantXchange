
class WCEthereumTransaction {
  String? from;
  String? to;
  String? nonce;
  String? gasPrice;
  String? maxFeePerGas;
  String? maxPriorityFeePerGas;
  String? gas;
  String? gasLimit;
  String? value;
  String? data;

  WCEthereumTransaction({
    this.from,
    this.to,
    this.nonce,
    this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.gas,
    this.gasLimit,
    this.value,
    this.data,
  });


  factory WCEthereumTransaction.fromJson(Map<String, dynamic> json) => WCEthereumTransaction(
    from: json["from"],
    to: json["to"],
    nonce: json["nonce"],
    gasPrice: json["gasPrice"],
    maxFeePerGas: json["maxFeePerGas"],
    maxPriorityFeePerGas: json["maxPriorityFeePerGas"],
    gas: json["gas"],
    gasLimit: json["gasLimit"],
    value: json["value"]??"0",
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "from": from,
    "to": to,
    "nonce": nonce,
    "gasPrice": gasPrice,
    "maxFeePerGas": maxFeePerGas,
    "maxPriorityFeePerGas": maxPriorityFeePerGas,
    "gas": gas,
    "gasLimit": gasLimit,
    "value": value,
    "data": data,
  };
}
