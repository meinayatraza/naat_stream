import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// DATABASE HELPER
/// Singleton class to manage SQLite database
/// Creates and manages all tables
/// ═══════════════════════════════════════════════════════════════

class DatabaseHelper {
  // Singleton pattern - only one instance of database
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // ───────────────────────────────────────────────────────────────
  // GET DATABASE: Returns existing or creates new database
  // ───────────────────────────────────────────────────────────────

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // ───────────────────────────────────────────────────────────────
  // INITIALIZE DATABASE: Create database file
  // ───────────────────────────────────────────────────────────────

  Future<Database> _initDB() async {
    // Get the default database location
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    // Open the database
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CREATE DATABASE: Create all tables
  // ───────────────────────────────────────────────────────────────

  Future<void> _createDB(Database db, int version) async {
    // Execute all table creation in a transaction
    await db.transaction((txn) async {
      // 1. BOOKS TABLE
      await txn.execute('''
        CREATE TABLE books (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          is_user_created INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      // 2. BOOK TRANSLATIONS TABLE
      await txn.execute('''
        CREATE TABLE book_translations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          book_id INTEGER NOT NULL,
          language_code TEXT NOT NULL CHECK(language_code IN ('ur', 'en', 'bn', 'hi')),
          book_title TEXT,
          poet_name TEXT,
          poet_intro TEXT,
          FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
          UNIQUE(book_id, language_code)
        )
      ''');

      // 3. POEMS TABLE
      await txn.execute('''
        CREATE TABLE poems (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          book_id INTEGER NOT NULL,
          sort_order INTEGER DEFAULT 0,
          first_letter_urdu TEXT NOT NULL,
          last_letter_urdu TEXT NOT NULL,
          audio_url TEXT,
          video_url TEXT,
          is_audio_downloaded INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for poems (for faster sorting)
      await txn.execute('''
        CREATE INDEX idx_poems_book ON poems(book_id)
      ''');

      await txn.execute('''
        CREATE INDEX idx_poems_first_letter ON poems(book_id, first_letter_urdu)
      ''');

      await txn.execute('''
        CREATE INDEX idx_poems_last_letter ON poems(book_id, last_letter_urdu)
      ''');

      // 4. VERSES TABLE
      await txn.execute('''
        CREATE TABLE verses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          poem_id INTEGER NOT NULL,
          verse_order INTEGER NOT NULL,
          FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE
        )
      ''');

      // Create index for verses
      await txn.execute('''
        CREATE INDEX idx_verses_poem ON verses(poem_id, verse_order)
      ''');

      // 5. VERSE CONTENT TABLE
      await txn.execute('''
        CREATE TABLE verse_content (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          language_code TEXT NOT NULL CHECK(language_code IN ('ur', 'en', 'bn', 'hi')),
          verse_text TEXT NOT NULL,
          translation TEXT,
          explanation TEXT,
          FOREIGN KEY (verse_id) REFERENCES verses(id) ON DELETE CASCADE,
          UNIQUE(verse_id, language_code)
        )
      ''');

      // Create indexes for verse content (for search)
      await txn.execute('''
        CREATE INDEX idx_verse_content_lang ON verse_content(verse_id, language_code)
      ''');

      await txn.execute('''
        CREATE INDEX idx_verse_content_search ON verse_content(verse_text)
      ''');

      // 6. FAVORITES TABLE
      await txn.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          item_type TEXT NOT NULL CHECK(item_type IN ('poem', 'verse')),
          item_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE(user_id, item_type, item_id)
        )
      ''');

      // Create index for favorites
      await txn.execute('''
        CREATE INDEX idx_favorites_user ON favorites(user_id, item_type)
      ''');

      // 7. BOOKMARKS TABLE
      await txn.execute('''
        CREATE TABLE bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT,
          poem_id INTEGER NOT NULL,
          verse_id INTEGER NOT NULL,
          bookmark_order INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE,
          FOREIGN KEY (verse_id) REFERENCES verses(id) ON DELETE CASCADE,
          UNIQUE(user_id, poem_id, verse_id)
        )
      ''');

      // Create index for bookmarks
      await txn.execute('''
        CREATE INDEX idx_bookmarks_user_poem ON bookmarks(user_id, poem_id)
      ''');

      // 8. USERS TABLE
      await txn.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          display_name TEXT,
          created_at TEXT NOT NULL,
          last_sync_at TEXT
        )
      ''');

      // 9. APP SETTINGS TABLE
      await txn.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');

      // Insert default settings
      await txn.insert('app_settings', {
        'key': AppConstants.settingKeyLanguage,
        'value': AppConstants.defaultLanguage,
      });

      await txn.insert('app_settings', {
        'key': AppConstants.settingKeyFontSize,
        'value': AppConstants.defaultFontSize.toString(),
      });
    });

    print('✅ Database created successfully with all tables');
  }

  // ───────────────────────────────────────────────────────────────
  // UPGRADE DATABASE: Handle database version changes
  // ───────────────────────────────────────────────────────────────

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE books ADD COLUMN new_field TEXT');
    // }
    print('Database upgraded from v$oldVersion to v$newVersion');
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Update local user_id to NULL (on sign out)
  // ───────────────────────────────────────────────────────────────

  Future<void> resetUserIdToNull() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'favorites',
        {'user_id': null},
        where: 'user_id IS NOT NULL',
      );

      await txn.update(
        'bookmarks',
        {'user_id': null},
        where: 'user_id IS NOT NULL',
      );
    });
    print('✅ User data reset to local-only');
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Update local data with user_id (on sign in)
  // ───────────────────────────────────────────────────────────────

  Future<void> updateLocalDataToUser(String userId) async {
    final db = await database;
    await db.transaction((txn) async {
      // Update favorites
      await txn.update(
        'favorites',
        {'user_id': userId},
        where: 'user_id IS NULL',
      );

      // Update bookmarks
      await txn.update(
        'bookmarks',
        {'user_id': userId},
        where: 'user_id IS NULL',
      );
    });
    print('✅ Local data linked to user: $userId');
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get setting value
  // ───────────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Set setting value
  // ───────────────────────────────────────────────────────────────

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Clear all data (for testing or reset)
  // ───────────────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('favorites');
      await txn.delete('bookmarks');
      await txn.delete('verse_content');
      await txn.delete('verses');
      await txn.delete('poems');
      await txn.delete('book_translations');
      await txn.delete('books');
      await txn.delete('users');
    });
    print('✅ All data cleared');
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Close database
  // ───────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is Singleton pattern?
   - Only ONE instance of DatabaseHelper exists
   - Access it via: DatabaseHelper.instance
   - Prevents multiple database connections
   
   Example:
   // ❌ Wrong: new DatabaseHelper() - constructor is private
   // ✅ Correct: DatabaseHelper.instance

2. WHY use transactions?
   - All table creations happen together
   - If one fails, all rollback (atomic operation)
   - Database stays consistent
   
   Example:
   await db.transaction((txn) async {
     await txn.execute('CREATE TABLE...');
     await txn.execute('CREATE TABLE...');
   }); // Either all succeed or all fail

3. WHAT are indexes?
   - Speed up database queries
   - Like book index - find things faster
   
   Example:
   Without index: Search through all 10,000 poems
   With index: Jump directly to poems starting with 'م'

4. WHY CHECK constraints?
   - Ensure data validity at database level
   - Example: language_code can only be 'ur','en','bn','hi'
   - Prevents invalid data
   
   Example:
   // This will fail:
   insert('verse_content', {'language_code': 'fr'});
   // Error: CHECK constraint failed

5. WHAT is ON DELETE CASCADE?
   - When book deleted, all its poems auto-delete
   - When poem deleted, all its verses auto-delete
   - Maintains referential integrity
   
   Example:
   Delete book id=1
   → All poems with book_id=1 auto-delete
   → All verses of those poems auto-delete
   → All verse_content of those verses auto-delete

6. HOW to use this in code?
   
   // Initialize database (done in main.dart)
   await DatabaseHelper.instance.database;
   
   // Get database for queries
   final db = await DatabaseHelper.instance.database;
   
   // Insert data
   await db.insert('books', {...});
   
   // Query data
   final results = await db.query('books');
   
   // Update setting
   await DatabaseHelper.instance.setSetting('language', 'ur');
   
   // Get setting
   String? lang = await DatabaseHelper.instance.getSetting('language');

7. WHAT happens on app first launch?
   - Database file doesn't exist
   - _createDB() is called
   - All tables created
   - Default settings inserted
   - App ready to use!

8. WHAT if we need to change schema later?
   - Increment databaseVersion in constants
   - Add migration code in _upgradeDB()
   
   Example (add new column in version 2):
   Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
       await db.execute('ALTER TABLE books ADD COLUMN rating INTEGER');
     }
   }

═══════════════════════════════════════════════════════════════
*/