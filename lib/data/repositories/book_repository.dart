import 'package:sqflite/sqflite.dart';
import '../../models/book_model.dart';
import '../../services/database/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════
/// BOOK REPOSITORY
/// Handles all database operations related to books
/// Think of this as the "Book Manager"
/// ═══════════════════════════════════════════════════════════════

class BookRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ───────────────────────────────────────────────────────────────
  // GET ALL BOOKS (with translations)
  // ───────────────────────────────────────────────────────────────

  Future<List<Book>> getAllBooks() async {
    final db = await _dbHelper.database;

    // Get all books with their translations in one query
    final results = await db.rawQuery('''
      SELECT 
        b.id,
        b.is_user_created,
        b.created_at,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.book_title END) as title_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.book_title END) as title_english,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.poet_name END) as poet_name_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.poet_name END) as poet_name_english,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.poet_intro END) as poet_intro_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.poet_intro END) as poet_intro_english,
        MAX(CASE WHEN bt.language_code = 'bn' THEN bt.poet_intro END) as poet_intro_bangla,
        MAX(CASE WHEN bt.language_code = 'hi' THEN bt.poet_intro END) as poet_intro_hindi
      FROM books b
      LEFT JOIN book_translations bt ON b.id = bt.book_id
      GROUP BY b.id
      ORDER BY b.is_user_created ASC, b.created_at DESC
    ''');

    return results.map((map) => Book.fromMap(map)).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOK BY ID (with translations)
  // ───────────────────────────────────────────────────────────────

  Future<Book?> getBookById(int id) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        b.id,
        b.is_user_created,
        b.created_at,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.book_title END) as title_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.book_title END) as title_english,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.poet_name END) as poet_name_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.poet_name END) as poet_name_english,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.poet_intro END) as poet_intro_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.poet_intro END) as poet_intro_english,
        MAX(CASE WHEN bt.language_code = 'bn' THEN bt.poet_intro END) as poet_intro_bangla,
        MAX(CASE WHEN bt.language_code = 'hi' THEN bt.poet_intro END) as poet_intro_hindi
      FROM books b
      LEFT JOIN book_translations bt ON b.id = bt.book_id
      WHERE b.id = ?
      GROUP BY b.id
    ''', [id]);

    if (results.isEmpty) return null;
    return Book.fromMap(results.first);
  }

  // ───────────────────────────────────────────────────────────────
  // GET USER-CREATED BOOKS ONLY
  // ───────────────────────────────────────────────────────────────

  Future<List<Book>> getUserCreatedBooks() async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        b.id,
        b.is_user_created,
        b.created_at,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.book_title END) as title_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.book_title END) as title_english,
        MAX(CASE WHEN bt.language_code = 'ur' THEN bt.poet_name END) as poet_name_urdu,
        MAX(CASE WHEN bt.language_code = 'en' THEN bt.poet_name END) as poet_name_english
      FROM books b
      LEFT JOIN book_translations bt ON b.id = bt.book_id
      WHERE b.is_user_created = 1
      GROUP BY b.id
      ORDER BY b.created_at DESC
    ''');

    return results.map((map) => Book.fromMap(map)).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // INSERT BOOK (with translations)
  // ───────────────────────────────────────────────────────────────

  Future<int> insertBook(
    Book book, {
    String? titleUrdu,
    String? titleEnglish,
    String? poetNameUrdu,
    String? poetNameEnglish,
    String? poetIntroUrdu,
    String? poetIntroEnglish,
    String? poetIntroBangla,
    String? poetIntroHindi,
  }) async {
    final db = await _dbHelper.database;

    // Use transaction to ensure all or nothing
    return await db.transaction((txn) async {
      // 1. Insert book
      final bookId = await txn.insert('books', book.toMap());

      // 2. Insert Urdu translation (if provided)
      if (titleUrdu != null || poetNameUrdu != null) {
        await txn.insert('book_translations', {
          'book_id': bookId,
          'language_code': 'ur',
          'book_title': titleUrdu,
          'poet_name': poetNameUrdu,
          'poet_intro': poetIntroUrdu,
        });
      }

      // 3. Insert English translation (if provided)
      if (titleEnglish != null || poetNameEnglish != null) {
        await txn.insert('book_translations', {
          'book_id': bookId,
          'language_code': 'en',
          'book_title': titleEnglish,
          'poet_name': poetNameEnglish,
          'poet_intro': poetIntroEnglish,
        });
      }

      // 4. Insert Bangla poet intro (if provided)
      if (poetIntroBangla != null) {
        await txn.insert('book_translations', {
          'book_id': bookId,
          'language_code': 'bn',
          'book_title': null,
          'poet_name': null,
          'poet_intro': poetIntroBangla,
        });
      }

      // 5. Insert Hindi poet intro (if provided)
      if (poetIntroHindi != null) {
        await txn.insert('book_translations', {
          'book_id': bookId,
          'language_code': 'hi',
          'book_title': null,
          'poet_name': null,
          'poet_intro': poetIntroHindi,
        });
      }

      return bookId;
    });
  }

  // ───────────────────────────────────────────────────────────────
  // UPDATE BOOK (with translations)
  // ───────────────────────────────────────────────────────────────

  Future<void> updateBook(
    int bookId, {
    String? titleUrdu,
    String? titleEnglish,
    String? poetNameUrdu,
    String? poetNameEnglish,
    String? poetIntroUrdu,
    String? poetIntroEnglish,
    String? poetIntroBangla,
    String? poetIntroHindi,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Update or insert Urdu translation
      if (titleUrdu != null || poetNameUrdu != null || poetIntroUrdu != null) {
        await txn.insert(
          'book_translations',
          {
            'book_id': bookId,
            'language_code': 'ur',
            'book_title': titleUrdu,
            'poet_name': poetNameUrdu,
            'poet_intro': poetIntroUrdu,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Update or insert English translation
      if (titleEnglish != null ||
          poetNameEnglish != null ||
          poetIntroEnglish != null) {
        await txn.insert(
          'book_translations',
          {
            'book_id': bookId,
            'language_code': 'en',
            'book_title': titleEnglish,
            'poet_name': poetNameEnglish,
            'poet_intro': poetIntroEnglish,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Similar for Bangla and Hindi poet intros
      if (poetIntroBangla != null) {
        await txn.insert(
          'book_translations',
          {
            'book_id': bookId,
            'language_code': 'bn',
            'book_title': null,
            'poet_name': null,
            'poet_intro': poetIntroBangla,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      if (poetIntroHindi != null) {
        await txn.insert(
          'book_translations',
          {
            'book_id': bookId,
            'language_code': 'hi',
            'book_title': null,
            'poet_name': null,
            'poet_intro': poetIntroHindi,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ───────────────────────────────────────────────────────────────
  // DELETE BOOK (cascades to poems, verses, etc.)
  // ───────────────────────────────────────────────────────────────

  Future<void> deleteBook(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Note: Foreign key CASCADE will auto-delete:
    // - book_translations
    // - poems (and their verses, verse_content)
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOK COUNT
  // ───────────────────────────────────────────────────────────────

  Future<int> getBookCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM books');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is a Repository?
   - It's like a "manager" for a specific type of data
   - BookRepository manages all Book operations
   - Separates database logic from UI logic
   
   Think of it like:
   UI (Screen) → "I need all books" → Repository → Database

2. WHY use Repository pattern?
   ❌ Without Repository:
   - Database queries scattered everywhere in UI code
   - Hard to maintain
   - Duplicate code
   
   ✅ With Repository:
   - All database logic in one place
   - Easy to test
   - Reusable methods
   - Clean UI code

3. WHAT is that complex SQL query?
   It joins books with book_translations table and uses
   MAX(CASE WHEN...) to pivot translations into columns.
   
   Result looks like:
   ┌────┬────────────┬───────────────┬─────────────┐
   │ id │ title_urdu │ title_english │ poet_name.. │
   ├────┼────────────┼───────────────┼─────────────┤
   │ 1  │ حدائق      │ Hadaiq-e-Bak  │ اعلیٰ حضرت  │
   └────┴────────────┴───────────────┴─────────────┘

4. WHY use transactions?
   - insertBook inserts into 2+ tables (books + translations)
   - If one fails, all should rollback
   - Keeps data consistent

5. HOW to use in UI?
   
   // In your screen:
   final bookRepo = BookRepository();
   
   // Get all books
   List<Book> books = await bookRepo.getAllBooks();
   
   // Display in UI
   ListView.builder(
     itemCount: books.length,
     itemBuilder: (context, index) {
       return Text(books[index].getTitle('en'));
     },
   );

6. WHAT is ConflictAlgorithm.replace?
   - If book_translation already exists, replace it
   - Used in update operations
   - Prevents duplicate constraint errors

═══════════════════════════════════════════════════════════════
*/