import 'dart:io';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class DbNetwork{

  static Database? _database;
  static final DbNetwork dbNetwork = DbNetwork._();

  DbNetwork._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'network_DB.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE Network('
            'id INTEGER PRIMARY KEY UNIQUE,'
            'name TEXT,'
            'symbol TEXT,'
            'weth TEXT,'
            'logo TEXT,'
            'url TEXT,'
            'chain INTEGER,'
            'note TEXT,'
            'tokenType TEXT,'
            'explorer_url TEXT,'
            'publicKeyName TEXT,'
            'privateKeyName TEXT,'
            'tokenEnable INTEGER,'
            'swapEnable INTEGER,'
            'isTxfees INTEGER,'
            'isEVM INTEGER'
            ')');
      },
    );
  }

  createNetwork(NetworkList networkLists) async{
    final db= await database;
    final res = await db!.insert("Network",networkLists.toJson());
    return res;
  }

  updateNetwork(NetworkList networkLists,id) async{
    final db= await database;
      final res = await db!.update("Network",networkLists.toJson(),where: "id = ? ",whereArgs: [id]);
      return res;
  }

  List<NetworkList> networkList = [];
  getNetwork() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Network");

    List<NetworkList> list = res.map((c) {
      return NetworkList.fromJson(c);
    }).toList();
    networkList = list;
  }


}