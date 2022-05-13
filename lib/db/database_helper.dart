import 'package:sqflite/sqflite.dart';
import 'package:startblock/model/history.dart';
import 'package:path/path.dart';
import 'package:startblock/constant/constants.dart';

class HistoryDatabase{
  static final HistoryDatabase instance = HistoryDatabase._init();
  // Field for our db
  static Database? _database;
  HistoryDatabase._init();

  // Open a connection
  Future<Database> get database async{
    if(_database != null) return _database!;

    _database = await  _initDB(Constants.DATABASE_NAME);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version:1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async{
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textTypeNotNull = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE $tableHistory ( 
  ${HistoryFields.id} $idType, 
  ${HistoryFields.dateTime} $textTypeNotNull,
  ${HistoryFields.name} $textTypeNotNull,
  ${HistoryFields.rightData} $textTypeNotNull,
  ${HistoryFields.leftData} $textTypeNotNull,
  ${HistoryFields.timestamps} $textTypeNotNull,
  ${HistoryFields.marzullo} $realType,
  ${HistoryFields.imuData} $textTypeNull,
  ${HistoryFields.imuTimestamps} $textTypeNull,
  ${HistoryFields.movesenseArriveTime} $textTypeNull,
  ${HistoryFields.marzulloCreationTime} $realType,
  ${HistoryFields.lastServerTime} $realType,
  ${HistoryFields.startSampleTime} $realType,
  ${HistoryFields.stopSampleTime} $realType,
  ${HistoryFields.listTimestampArrivalTime} $textTypeNotNull
  )
''');
  }

  Future<History> create(History hist)async{
    final db = await instance.database;
    final id = await db.insert(tableHistory, hist.toJson());
    return hist.copy(id: id);
  }

  Future<History> read(int id) async{
    final db = await instance.database;
    final maps = await db.query(
      tableHistory,
      columns: HistoryFields.values,
      where: '${HistoryFields.id} = ?',
      whereArgs: [id],
    );

    if(maps.isNotEmpty) {
      return History.fromJson(maps.first);
    } else{
      throw Exception('ID $id not found');
    }

  }

  Future<List<History>> readAllHistory() async{
    final db = await instance.database;

    const orderBy = '${HistoryFields.dateTime} ASC';

    final result = await db.query(tableHistory, orderBy: orderBy);

    return result.map((json) => History.fromJson(json)).toList();
  }

  Future<int> update(History hist) async{
    final db = await instance.database;
    return db.update(
      tableHistory,
      hist.toJson(),
      where: '${HistoryFields.id} = ?',
      whereArgs: [hist.id],

    );
  }

  Future<int> delete(int id) async{
    final db = await instance.database;
    return await db.delete(
      tableHistory,
      where: '${HistoryFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }

}
