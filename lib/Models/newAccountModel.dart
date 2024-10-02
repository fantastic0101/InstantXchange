import 'dart:convert';

List<NewAccountList> productFromJson(String str) =>
    List<NewAccountList>.from(json.decode(str).map((x) => NewAccountList.fromJson(x)));

class NewAccountList {
  NewAccountList({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.mnemonic,
  });

  String id;
  String deviceId;
  String name;
  String mnemonic;

  factory NewAccountList.fromJson(Map<String, dynamic> json) => NewAccountList(
    id: "${json["id"]}",
    deviceId: json["device_id"],
    name: json["name"],
    mnemonic: json["mnemonic"],
  );

}
