import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

/// Sqflite implementation of MovieRepository.
/// Liskov Substitution: can be swapped for DriftMovieRepository, IsarMovieRepository, etc.
class SqfliteMovieRepository implements MovieRepository {
  static const _tableName = 'moviesWatched';
  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getApplicationDocumentsDirectory();
    return openDatabase(
      join(dbPath.path, 'movies.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_tableName(
            createdOn TEXT PRIMARY KEY,
            name TEXT,
            director TEXT,
            genre TEXT DEFAULT '',
            imageUrl TEXT,
            updatedOn TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE $_tableName ADD COLUMN genre TEXT DEFAULT ''");
        }
      },
      version: 2,
    );
  }

  @override
  Future<List<Movie>> getAll() async {
    final db = await database;
    final maps = await db.query(_tableName);
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  @override
  Future<List<Movie>> findByName(String name) async {
    final db = await database;
    final maps =
        await db.query(_tableName, where: 'name = ?', whereArgs: [name]);
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  @override
  Future<void> save(Movie movie) async {
    final db = await database;
    await db.insert(_tableName, movie.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> delete(String movieName) async {
    final db = await database;
    await db.delete(_tableName, where: 'name = ?', whereArgs: [movieName]);
  }

  @override
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
