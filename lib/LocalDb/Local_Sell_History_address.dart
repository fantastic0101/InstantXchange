import 'dart:io';
import 'package:jost_pay_wallet/Models/SellHistoryModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbSellHistory{

  static Database? _database;
  static final DbSellHistory dbSellHistory = DbSellHistory._();

  DbSellHistory._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'sellHistory.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE SellHistory('
              'amount_payable_ngn INTEGER,'
              'invoice TEXT,'
              'order_status TEXT,'
              'tokenName TEXT,'
              'invoice_no TEXT,'
              'invoice_url TEXT,'
              'time INTEGER,'
              'type TEXT,'
              'payin_address TEXT,'
              'payin_amount TEXT,'
              'payout_amount TEXT,'
              'payout_address TEXT,'
              'payin_url TEXT,'
              'bank TEXT,'
              'accountNo TEXT,'
              'accountName TEXT,'
              'accountId TEXT'
              ')');
        },
    );
  }

  createSellHistory(SellHistoryModel newToken) async{
    final db= await database;
    final res = await db!.insert('SellHistory', newToken.toJson());
    return res;
  }

  updateSellHistory(SellHistoryModel newToken,invoice,id) async{
    final db= await database;

    final res = await db!.update('SellHistory', newToken.toJson(), where: "invoice = ? AND accountId = ? ",whereArgs: [invoice,id]);
    getSellHistory(id);
    return res;
  }

    updateStatus(SellHistoryModel newToken,id) async{
    final db= await database;
    Map<String, dynamic> data = {
      "invoice": newToken.invoiceNo,
      "order_status": newToken.orderStatus,
      "invoice_no": newToken.invoiceNo,
      "invoice_url": newToken.invoiceUrl,
      "payin_amount": newToken.payinAmount,
      "payout_amount": newToken.payoutAmount,
      "payin_address": newToken.payin_address,
      "accountId":newToken.accountId,
      "payout_address": newToken.payoutAddress,
      "payin_url": newToken.payinUrl,
      "tokenName": newToken.tokenName,
    };

    //print(jsonEncode(data));

    final res = await db!.update('SellHistory', data, where: "invoice = ? AND accountId = ? ",whereArgs: [newToken.invoiceNo,id]);

    getSellHistory(id);
    return res;
  }

  List<SellHistoryModel> sellHistoryList = [];
  getSellHistory(String accountId) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM SellHistory Where accountId = '$accountId' ORDER BY time DESC");

    List<SellHistoryModel> list = res.map((c) {
      return SellHistoryModel.fromJson(
        c,
        accountId,
        c['tokenName'],
        c["accountName"],
        c['accountNo'],
        c['bank']
      );
    }).toList();
    sellHistoryList = list;
    return list;
  }


  SellHistoryModel? getTrxStatusData;
  getTrxStatus(String accountId,String invoiceNo) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM SellHistory Where accountId = '$accountId' AND invoice = '$invoiceNo'");

    if(res.isNotEmpty) {
      getTrxStatusData = SellHistoryModel.fromJson(
          res[0],
          accountId,
          res[0]['tokenName'],
          res[0]["accountName"],
          res[0]['accountNo'],
          res[0]['bank']
      );
    }
    return getTrxStatusData;
  }

  Future<int> deleteAllSellHistory() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM SellHistory');
    return res;
  }

  Future<int> deleteSellHistory(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM SellHistory Where id = $id");
    return res;
  }

}