import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage SQLite database for offline menu and orders.
class LocalDbService {
  static const String _dbName = 'restaurant_offline.db';
  static const int _dbVersion = 1;

  static Database? _database;

  /// Initializes and returns the SQLite Database instance.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Create Menu Table
        await db.execute('''
          CREATE TABLE menu (
            id INTEGER PRIMARY KEY,
            nom TEXT,
            description TEXT,
            prix REAL,
            typeElement TEXT,
            imageUrl TEXT,
            tempsPreparationMinutes INTEGER,
            calories INTEGER,
            estServiChaud INTEGER,
            volumeLitre REAL,
            contientAlcool INTEGER,
            fullJson TEXT
          )
        ''');

        // Create Orders Table
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY,
            clientId INTEGER,
            date TEXT,
            status TEXT,
            fullJson TEXT
          )
        ''');
      },
    );
  }

  // ─────────────────────────────────────────────────
  //  MENU METHODS
  // ─────────────────────────────────────────────────

  /// Caches a list of menu items (from API) into SQLite (or SharedPreferences on Web).
  static Future<void> cacheMenu(List<Map<String, dynamic>> menuItems) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('web_menu_cache', jsonEncode(menuItems));
      return;
    }

    final db = await database;
    final batch = db.batch();

    // Clear old cache
    batch.delete('menu');

    for (var item in menuItems) {
      batch.insert(
        'menu',
        {
          'id': item['id'],
          'nom': item['nom'],
          'description': item['description'],
          'prix': item['prix'],
          'typeElement': item['typeElement'] ?? item['type_element'],
          'imageUrl': item['imageUrl'],
          'tempsPreparationMinutes': item['tempsPreparationMinutes'],
          'calories': item['calories'],
          'estServiChaud': item['estServiChaud'] == true ? 1 : 0,
          'volumeLitre': item['volumeLitre'],
          'contientAlcool': item['contientAlcool'] == true ? 1 : 0,
          'fullJson': jsonEncode(item),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves the cached menu from SQLite (or SharedPreferences on Web).
  static Future<List<Map<String, dynamic>>> getCachedMenu() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('web_menu_cache');
      if (str != null) {
        final List<dynamic> decoded = jsonDecode(str);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('menu');
    
    return maps.map((map) {
      final jsonStr = map['fullJson'] as String;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }).toList();
  }

  // ─────────────────────────────────────────────────
  //  ORDERS METHODS
  // ─────────────────────────────────────────────────

  /// Caches a list of orders (from API) into SQLite for a specific client.
  static Future<void> cacheOrders(int clientId, List<Map<String, dynamic>> orders) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('web_orders_cache_$clientId', jsonEncode(orders));
      return;
    }

    final db = await database;
    final batch = db.batch();

    // Clear old cache for this client
    batch.delete('orders', where: 'clientId = ?', whereArgs: [clientId]);

    for (var order in orders) {
      batch.insert(
        'orders',
        {
          'id': order['id'],
          'clientId': clientId,
          'date': order['date'],
          'status': order['status'],
          'fullJson': jsonEncode(order),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retrieves the cached orders for a specific client.
  static Future<List<Map<String, dynamic>>> getCachedOrders(int clientId) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('web_orders_cache_$clientId');
      if (str != null) {
        final List<dynamic> decoded = jsonDecode(str);
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) {
      final jsonStr = map['fullJson'] as String;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }).toList();
  }
}
