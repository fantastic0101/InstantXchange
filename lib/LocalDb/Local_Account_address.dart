import 'dart:io';
import 'package:jost_pay_wallet/Models/AccountAddress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbAccountAddress{

  static Database? _database;
  static final DbAccountAddress dbAccountAddress = DbAccountAddress._();

  DbAccountAddress._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'accountAddress.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE AccountAddress('
              'accountId TEXT,'
              'publicAddress TEXT,'
              'privateAddress TEXT,'
              'publicKeyName TEXT,'
              'privateKeyName TEXT,'
              'networkId TEXT,'
              'networkName TEXT'
              ')');
        },
        // onUpgrade: (Database db, int version,int newVersion)async{
        //   if (version < newVersion) {
        //     db.execute("ALTER TABLE AccountAddress ADD COLUMN newCol TEXT;");
        //   }
        // }
    );
  }

  Future<int?> deleteAllAccountAddress() async {
    final db = await database;
    final res = await db?.rawDelete('DELETE FROM AccountAddress');
    return res;
  }

  Future<int?> deleteAccountAddress(id) async {
    final db = await database;
    final res = await db?.rawDelete("DELETE FROM AccountAddress Where accountId = '$id'");
    return res;
  }

  createAccountAddress(accountId,publicAddress,privateAddress,publicKeyName,privateKeyName,networkId,networkName) async{
    final db= await database;
    final res = await db?.rawInsert('INSERT INTO AccountAddress(accountId, publicAddress, privateAddress, publicKeyName, privateKeyName, networkId, networkName) VALUES("$accountId", "$publicAddress", "$privateAddress", "$publicKeyName", "$privateKeyName", "$networkId", "$networkName")');
    return res;
  }

  List<AccountAddress> allAccountAddress = [];
  getAccountAddress(accountId) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM AccountAddress Where accountId = '$accountId'");

    List<AccountAddress> list = res.map((c) => AccountAddress.fromJson(c)).toList();
    allAccountAddress = list;

  }

  String selectAccountPublicAddress = "",selectAccountPrivateAddress = "";
  getPublicKey(accountId,networkId) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT publicAddress,privateAddress FROM AccountAddress Where accountId = '$accountId' AND networkId = '$networkId'");

    if(res.isNotEmpty) {
      selectAccountPublicAddress = "${res[0]["publicAddress"]}";
      selectAccountPrivateAddress = "${res[0]["privateAddress"]}";
    }
  }

  String selectPrivateAdd = "";
  getDataByAddress(String address,String networkId) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT privateAddress FROM AccountAddress Where LOWER(publicAddress) = '${address.toLowerCase()}' AND networkId = '$networkId'");
    if(res.isNotEmpty) {
      selectPrivateAdd = "${res[0]["privateAddress"]}";
    }
  }

}