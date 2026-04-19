import 'package:sqflite/sqflite.dart';
import 'package:dnd_app/models/player.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('players.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 7) {
      // Adding the missing 'gender' column
      await db.execute(
        'ALTER TABLE players ADD COLUMN gender TEXT NOT NULL DEFAULT "male"',
      );
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        race TEXT NOT NULL,
        playerClass TEXT NOT NULL,
        level INTEGER NOT NULL,
        xp INTEGER NOT NULL,
        gold INTEGER NOT NULL,
        pointsleft INTEGER NOT NULL,
        availablePoints INTEGER NOT NULL,
        health INTEGER NOT NULL,
        maxHealth INTEGER NOT NULL,
        mana INTEGER NOT NULL,
        maxMana INTEGER NOT NULL,
        proficiencyBonus INTEGER NOT NULL,
        armorClass INTEGER NOT NULL,
        strength INTEGER NOT NULL,
        dexterity INTEGER NOT NULL,
        constitution INTEGER NOT NULL,
        intelligence INTEGER NOT NULL,
        wisdom INTEGER NOT NULL,
        charisma INTEGER NOT NULL,
        subclass TEXT NOT NULL,
        subclassDescription TEXT NOT NULL,
        weapon TEXT NOT NULL,
        gender TEXT NOT NULL,
        spells TEXT NOT NULL,
        inventoryWeapons TEXT NOT NULL,
        knownSpells TEXT NOT NULL
      )
    ''');
  }

  Future<Player> create(Player player) async {
    final db = await instance.database;
    await db.insert(
      'players',
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return player;
  }

  Future<Player> readPlayer(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'players',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Player.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Player>> readAllPlayers() async {
    final db = await instance.database;
    final result = await db.query('players');

    return result.map((json) => Player.fromMap(json)).toList();
  }

  Future<int> update(Player player) async {
    final db = await instance.database;

    return db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;

    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('players');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
