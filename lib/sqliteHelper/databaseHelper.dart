import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteHelper {

//  SQLiteHelper();
  final _lock = new Lock();

  SQLiteHelper._internal();
  static final SQLiteHelper instance = SQLiteHelper._internal();

  static Database _db;


  /// db version: 1-ees ehelsen
  Future<Database> getDb() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        if (_db == null) {
          _db = await openDatabase(
//              path,
              join(await getDatabasesPath(), 'main.db'),
              version: 6,
              onCreate: _onCreate,
              onUpgrade: _onUpgrade
          );
        }
      });
    }
    return _db;
  }
  void _onCreate(Database db, int version) {
    print('onCreate called, ver: $version');
    initScript.forEach((script)=>{
      db.execute(script)
    });
    _onUpgrade(db, 1, version);
  }
  // UPGRADE DATABASE TABLES
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    print('old ver: $oldVersion newVer: $newVersion');
      for(int i=oldVersion; i<newVersion; i++){
        migrationScripts[i].forEach((sql) => {
          db.execute(sql)
        });
      }
//    if(newVersion == 3){
//      db.execute("CREATE TABLE cats(id INTEGER PRIMARY KEY, name TEXT, age INTEGER);");
//    }
  }
  static const initScript = [
    "CREATE TABLE events("
        "id INTEGER PRIMARY KEY, "
        "event_id INTEGER, "
        "name TEXT, "
        "open_time INTEGER, "
        "close_time INTEGER, "
        "general_info TEXT, "
        "location_desc TEXT );",
    "CREATE TABLE speakers("
        "id INTEGER PRIMARY KEY, "
        "event_id INTEGER, "
        "speaker_id INTEGER, "
        "name TEXT, "
        "description TEXT, "
        "career TEXT, "
        "position TEXT, "
        "is_featured INTEGER );",
    "CREATE TABLE participants("
        "id INTEGER PRIMARY KEY, "
        "event_id INTEGER, "
        "participant_id INTEGER, "
        "name TEXT, "
        "description TEXT, "
        "meta TEXT, "
        "participant_type TEXT );",
    "CREATE TABLE programs("
        "id INTEGER PRIMARY KEY, "
        "event_id INTEGER, "
        "program_id INTEGER, "
        "title TEXT, "
        "topic TEXT, "
        "open_time INTEGER, "
        "close_time INTEGER, "
        "description TEXT, "
        "program_type TEXT, "
        "room_id INTEGER );",
    "CREATE TABLE rooms("
        "id INTEGER PRIMARY KEY, "
        "room_id INTEGER, "
        "event_id INTEGER, "
        "name TEXT, "
        "location TEXT, "
        "number TEXT );",
    "CREATE TABLE invoices("
        "id INTEGER PRIMARY KEY, "
        "event_id INTEGER, "
        "invoice_id TEXT, "
        "amount INTEGER, "
        "is_paid INTEGER );",
    "CREATE TABLE images("
        "id INTEGER PRIMARY KEY, "
        "related_type TEXT, "
        "related_id INTEGER, "
        "field TEXT, "
        "img_path TEXT );",
    "CREATE TABLE notifications("
        "id INTEGER PRIMARY KEY, "
        "message TEXT, "
        "is_read INTEGER, "
        "type INTEGER );",
    "CREATE TABLE speaker_program("
        "id INTEGER PRIMARY KEY, "
        "speaker_id INTEGER, "
        "program_id INTEGER, "
        "event_id INTEGER, "
        "role TEXT );"
  ];
  static const v2_scripts = [
    "CREATE TABLE my_program("
        "id INTEGER PRIMARY KEY, "
        "event_id INTEGER, "
        "program_id INTEGER );"
  ];
  static const v3_scripts = [
    "CREATE TABLE dummy("
        "id INTEGER PRIMARY KEY, "
        "test TEXT );"
  ];
  static const v4_scripts = [
    "CREATE TABLE missing("
        "id INTEGER PRIMARY KEY, "
        "first_id INTEGER, "
        "missing_count INTEGER, "
        "last_event_id INTEGER );"
    "ALTER TABLE invoices ADD COLUMN invoice_number TEXT;"
  ];
  static const v5_scripts = [
    "ALTER TABLE notifications ADD COLUMN title TEXT;"
  ];
  static const v6_scripts = [
    "ALTER TABLE notifications ADD COLUMN date INTEGER;"
  ];
  static const v7_scripts = [
    "ALTER TABLE events ADD COLUMN hash TEXT;"
    "ALTER TABLE speakers ADD COLUMN hash TEXT;"
    "ALTER TABLE programs ADD COLUMN hash TEXT;"
    "ALTER TABLE rooms ADD COLUMN hash TEXT;"
    "ALTER TABLE participants ADD COLUMN hash TEXT;"
  ];

  static const migrationScripts = [
    initScript,
    v2_scripts,
    v3_scripts,
    v4_scripts,
    v5_scripts,
    v6_scripts,
    v7_scripts,
  ];

  Future<int> getRowCount(String tableName) async {
    Database db = await SQLiteHelper.instance.getDb();
    return Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $tableName"));
  }

  ///Deprecated
  Future<int> getLastEventId(int rowCount) async {
    Database db = await SQLiteHelper.instance.getDb();
    return Sqflite.firstIntValue(await db.rawQuery("SELECT event_id from events where id = $rowCount"));
  }

}

