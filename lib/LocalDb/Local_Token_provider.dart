import 'dart:io';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBTokenProvider{

  static Database? _database;
  static final DBTokenProvider dbTokenProvider = DBTokenProvider._();

  DBTokenProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'tokenManager.db');

    return await openDatabase(path, version: 3, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE Token('
              'id INTEGER,'
              'token_id INTEGER,'
              'acc_address TEXT,'
              'network_id INTEGER,'
              'market_id INTEGER,'
              'name TEXT,'
              'type TEXT,'
              'address TEXT,'
              'symbol TEXT,'
              'decimals INTEGER,'
              'logo TEXT,'
              'balance TEXT,'
              'network_name TEXT,'
              'price REAL,'
              'percent_change_24h REAL,'
              'accountId TEXT,'
              'explorer_url TEXT'
              ')');
        },
        onUpgrade: (Database db, int version,int newVersion)async{
          if (version < newVersion) {
            db.execute("ALTER TABLE AccountAddress ADD COLUMN isCustom INTEGER;");
          }
    });
  }

  createToken(AccountTokenList newToken) async{
    // print("object newtoken ${newToken.id}");
    final db= await database;
    final res = await db!.insert('Token', newToken.toJson());
    // print("data add here $res");
    return res;
  }

  updateToken(AccountTokenList newToken,tokenId,id) async{
    final db= await database;
    Map<String, dynamic> data = {
      "id": newToken.id,
      "token_id": newToken.token_id,
      "acc_address": newToken.accAddress,
      "network_id": newToken.networkId,
      "market_id": newToken.marketId,
      "name": newToken.name,
      "type": newToken.type,
      "address": newToken.address,
      "symbol": newToken.symbol,
      "price":newToken.price,
      "decimals": newToken.decimals,
      "logo": newToken.logo,
      "network_name": newToken.networkName,
      "explorer_url": newToken.explorer_url,
      "accountId": newToken.accountId,
    };

    final res = await db!.update('Token', data, where: "id = ? AND accountId = ? ",whereArgs: [tokenId,id]);
    getAccountToken(id);
    return res;
  }


  updateTokenByTID(AccountTokenList newToken,tokenId,id) async{
    final db= await database;
    Map<String, dynamic> data = {
      "id": newToken.id,
      "token_id": newToken.token_id,
      "acc_address": newToken.accAddress,
      "network_id": newToken.networkId,
      "market_id": newToken.marketId,
      "name": newToken.name,
      "type": newToken.type,
      "address": newToken.address,
      "symbol": newToken.symbol,
      "price":newToken.price,
      "decimals": newToken.decimals,
      "logo": newToken.logo,
      "network_name": newToken.networkName,
      "explorer_url": newToken.explorer_url,
      "accountId": newToken.accountId,
    };

    final res = await db!.update('Token', data, where: "token_id = ? AND accountId = ? ",whereArgs: [tokenId,id]);
    getAccountToken(id);
    return res;
  }

  getTokenById(acId,id) async {
    // print("object $id");
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Token Where accountId = '$acId' AND market_id='$id'");
    return res.isEmpty ? null :res[0];
  }

  Future<int> deleteAllToken() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM Token');
    return res;
  }

  Future<int> deleteToken(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM Token Where id = $id");
    return res;
  }

  Future<int> deleteAccountToken(String accountId) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM Token Where accountId = '$accountId'");
    return res;
  }

  List<AccountTokenList> tokenList = [];
  getAccountToken(String accountId) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Token Where accountId = '$accountId'");

    List<AccountTokenList> list = res.map((c) {
      return AccountTokenList.fromJson(
          c,
          accountId,
      );
    }).toList();
    tokenList = list;
    tokenList.sort((a, b) {
      var aValue = a.name;
      var bValue = b.name;
      return aValue.compareTo(bValue);
    });

     // print("check this value this ${tokenList.length}");
    return list;
  }

  getSearchToken(String accountId,name) async {

    final db = await database;
    final res = await db!.query(
      'Token',
      where: 'LOWER (name) LIKE ? OR LOWER(symbol) LIKE ?',
      whereArgs: ['$name%','$name%',],
    );
    List<AccountTokenList> list = res.map((c) {
      return AccountTokenList.fromJson(
        c,
        accountId,
      );
    }).toList();
    tokenList = list;
    tokenList.sort((a, b) {
      var aValue = a.name;
      var bValue = b.name;
      return aValue.compareTo(bValue);
    });

    // print("check this value this ${tokenList.length}");
    return list;
  }


  updateTokenPrice(double livePrice,double gainLoss,int id) async {

    // print("$live_price,$gain_loss,$symbol");

    List<AccountTokenList> list;

    final db = await database;
    final res = await db!.rawUpdate("UPDATE Token SET price = $livePrice, percent_change_24h = $gainLoss WHERE market_id = '$id'");

    //getAccountToken(address,btcAddress,solAddress,dotAddress);

    return res;
  }

  updateTokenBalance(String balance,String id) async {

    // print("db balance $balance");
    final db = await database;
    final res = await db!.rawUpdate("UPDATE Token SET balance = $balance WHERE id = '$id'");

    //getAccountToken(address,btcAddress,solAddress,dotAddress);

    return res;
  }

  getTokenUsdPrice (id) async{
    final db = await database;
    final res = await db!.rawQuery("SELECT price FROM Token Where token_id = '$id'");
    return res;
  }

}