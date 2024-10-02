import 'dart:convert';

List<ExchangeTokenModel> exchangeTokenModelFromJson(String str) => List<ExchangeTokenModel>.from(json.decode(str).map((x) => ExchangeTokenModel.fromJson(x)));

String exchangeTokenModelToJson(List<ExchangeTokenModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExchangeTokenModel {
  String ticker;
  String name;
  String image;


  ExchangeTokenModel({
    required this.ticker,
    required this.name,
    required this.image,

  });

  factory ExchangeTokenModel.fromJson(Map<String, dynamic> json) => ExchangeTokenModel(
    ticker: json["ticker"],
    name: json["name"],
    image: json["image"],

  );

  Map<String, dynamic> toJson() => {
    "ticker": ticker,
    "name": name,
    "image": image,
  };
}
