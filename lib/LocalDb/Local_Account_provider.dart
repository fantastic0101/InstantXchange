import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Models/newAccountModel.dart';

class DBAccountProvider {

  static Database? _database;
  static final DBAccountProvider dbAccountProvider = DBAccountProvider._();

  DBAccountProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'accountManager.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE Account('
              'id INTEGER,'
              'device_id TEXT,'
              'name TEXT,'
              'mnemonic TEXT'
              ')');
        });
  }

  //List<AccountList> accountList = [];
  List<NewAccountList> newAccountList = [];
  getAllAccount() async {

    newAccountList.clear();

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Account");


    List<NewAccountList> list = res.map<NewAccountList>((json) => NewAccountList.fromJson(json)).toList();
    newAccountList.addAll(list);


    //print("New Account :" + newAccountList.length.toString());

  }

  createAccount(String id,String deviceId,String name,String mnemonic) async{
    final db= await database;
    final res = await db!.rawInsert('INSERT INTO Account(id, device_id, name, mnemonic) VALUES("$id", "$deviceId", "$name", "$mnemonic")');
    return res;
  }


  Future<int> deleteAllAccount() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM Account');
    return res;
  }

  Future<int> deleteAccount(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM Account Where id = '$id'");
    return res;
  }




}
