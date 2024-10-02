import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBWalletConnectV2{

  static Database?_database;
  static final DBWalletConnectV2 dbWalletConnectV2 = DBWalletConnectV2._();

  DBWalletConnectV2._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'walletConnect2.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE walletConnect('
              'date TEXT,'
              'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
              'text TEXT,'
              'publicKey TEXT,'
              'type TEXT'
              ')');
        });
  }

  List SignTList = [];
  getSignTByPublicKey(String publicKey) async {

    // print(publicKey);
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM walletConnect where publicKey = '$publicKey'");
    // print(res);
    SignTList = res;

  }

  List signTListAll = [];
  getAllSignT() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM walletConnect");
    // print(res);
    signTListAll = res;
  }

  deleteSignTByKey(List publicKey) async {
    final db = await database;
    final res = await db!.delete('walletConnect', where: 'publicKey IN (${publicKey.join(',')})');
    return res;
  }

  List signTListPublicKey = [];
  getAllSignTByKey(String publicKey) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM walletConnect where publicKey = '$publicKey'");
    signTListPublicKey = res;

  }

  Future<int> deleteAllSign() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM walletConnect');
    return res;
  }

  createSignt(String date,String text,String type,String publicKey) async{
    final db= await database;
    final res = await db!.rawInsert('INSERT INTO walletConnect(date, text, type,publicKey) VALUES("$date", "$text", "$type", "$publicKey")');
    // print("create wallet $res");
    return res;
  }


  Future<int?> deleteAllWallet() async {
    final db = await database;
    final res = await db?.rawDelete('DELETE FROM walletConnect');
    return res;
  }

}