import 'dart:convert';

MarketCapCoinModel MarketCapCoinModelFromJson(String str) => MarketCapCoinModel.fromJson(json.decode(str));

String MarketCapCoinModelToJson(MarketCapCoinModel data) => json.encode(data.toJson());

class MarketCapCoinModel {
  Map<String, Datum> data;

  MarketCapCoinModel({
    required this.data,
  });

  factory MarketCapCoinModel.fromJson(Map<String, dynamic> json) => MarketCapCoinModel(
    data: Map.from(json["data"]).map((k, v) => MapEntry<String, Datum>(k, Datum.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class Datum {
  int id;
  String name;
  String symbol;
  String slug;
  int numMarketPairs;
  DateTime dateAdded;
  int maxSupply;
  double circulatingSupply;
  double totalSupply;
  int isActive;
  bool infiniteSupply;
  Platform platform;
  int cmcRank;
  int isFiat;
  int selfReportedCirculatingSupply;
  double selfReportedMarketCap;
  dynamic tvlRatio;
  DateTime lastUpdated;
  Quote quote;

  Datum({
    required this.id,
    required this.name,
    required this.symbol,
    required this.slug,
    required this.numMarketPairs,
    required this.dateAdded,
    required this.maxSupply,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.isActive,
    required this.infiniteSupply,
    required this.platform,
    required this.cmcRank,
    required this.isFiat,
    required this.selfReportedCirculatingSupply,
    required this.selfReportedMarketCap,
    required this.tvlRatio,
    required this.lastUpdated,
    required this.quote,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    slug: json["slug"],
    numMarketPairs: json["num_market_pairs"],
    dateAdded: DateTime.parse(json["date_added"]),
    maxSupply: json["max_supply"],
    circulatingSupply: json["circulating_supply"]?.toDouble(),
    totalSupply: json["total_supply"]?.toDouble(),
    isActive: json["is_active"],
    infiniteSupply: json["infinite_supply"],
    platform: Platform.fromJson(json["platform"]),
    cmcRank: json["cmc_rank"],
    isFiat: json["is_fiat"],
    selfReportedCirculatingSupply: json["self_reported_circulating_supply"],
    selfReportedMarketCap: json["self_reported_market_cap"]?.toDouble(),
    tvlRatio: json["tvl_ratio"],
    lastUpdated: DateTime.parse(json["last_updated"]),
    quote: Quote.fromJson(json["quote"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "slug": slug,
    "num_market_pairs": numMarketPairs,
    "date_added": dateAdded.toIso8601String(),
    "max_supply": maxSupply,
    "circulating_supply": circulatingSupply,
    "total_supply": totalSupply,
    "is_active": isActive,
    "infinite_supply": infiniteSupply,
    "platform": platform.toJson(),
    "cmc_rank": cmcRank,
    "is_fiat": isFiat,
    "self_reported_circulating_supply": selfReportedCirculatingSupply,
    "self_reported_market_cap": selfReportedMarketCap,
    "tvl_ratio": tvlRatio,
    "last_updated": lastUpdated.toIso8601String(),
    "quote": quote.toJson(),
  };
}

class Platform {
  int id;
  String name;
  String symbol;
  String slug;
  String tokenAddress;

  Platform({
    required this.id,
    required this.name,
    required this.symbol,
    required this.slug,
    required this.tokenAddress,
  });

  factory Platform.fromJson(Map<String, dynamic> json) => Platform(
    id: json["id"],
    name: json["name"],
    symbol: json["symbol"],
    slug: json["slug"],
    tokenAddress: json["token_address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "symbol": symbol,
    "slug": slug,
    "token_address": tokenAddress,
  };
}

class Quote {
  Usd usd;

  Quote({
    required this.usd,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    usd: Usd.fromJson(json["USD"]),
  );

  Map<String, dynamic> toJson() => {
    "USD": usd.toJson(),
  };
}

class Usd {
  double price;
  double volume24H;
  double volumeChange24H;
  double percentChange1H;
  double percentChange24H;

  Usd({
    required this.price,
    required this.volume24H,
    required this.volumeChange24H,
    required this.percentChange1H,
    required this.percentChange24H,
  });

  factory Usd.fromJson(Map<String, dynamic> json) => Usd(
    price: json["price"]?.toDouble(),
    volume24H: json["volume_24h"]?.toDouble(),
    volumeChange24H: json["volume_change_24h"]?.toDouble(),
    percentChange1H: json["percent_change_1h"]?.toDouble(),
    percentChange24H: json["percent_change_24h"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "volume_24h": volume24H,
    "volume_change_24h": volumeChange24H,
    "percent_change_1h": percentChange1H,
    "percent_change_24h": percentChange24H,

  };
}


