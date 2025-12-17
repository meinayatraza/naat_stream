import 'package:sqflite/sqflite.dart';
import '../../models/poem_model.dart';
import '../../services/database/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════
/// POEM REPOSITORY
/// Handles all database operations related to poems
/// ═══════════════════════════════════════════════════════════════

class PoemRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ───────────────────────────────────────────────────────────────
  // GET ALL POEMS IN A BOOK (with titles in all languages)
  // ───────────────────────────────────────────────────────────────

  Future<List<Poem>> getPoemsByBookId(int bookId) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        p.*,
        MAX(CASE WHEN vc.language_code = 'ur' THEN vc.verse_text END) as title_urdu,
        MAX(CASE WHEN vc.language_code = 'en' THEN vc.verse_text END) as title_english,
        MAX(CASE WHEN vc.language_code = 'bn' THEN vc.verse_text END) as title_bangla,
        MAX(CASE WHEN vc.language_code = 'hi' THEN vc.verse_text END) as title_hindi
      FROM poems p
      LEFT JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      LEFT JOIN verse_content vc ON vc.verse_id = v.id
      WHERE p.book_id = ?
      GROUP BY p.id
      ORDER BY p.sort_order ASC
    ''', [bookId]);

    return results.map((map) {
      final poem = Poem.fromMap(map);
      // Extract first line only for titles
      if (map['title_urdu'] != null) {
        poem.titleUrdu = (map['title_urdu'] as String).split('\n').first;
      }
      if (map['title_english'] != null) {
        poem.titleEnglish = (map['title_english'] as String).split('\n').first;
      }
      if (map['title_bangla'] != null) {
        poem.titleBangla = (map['title_bangla'] as String).split('\n').first;
      }
      if (map['title_hindi'] != null) {
        poem.titleHindi = (map['title_hindi'] as String).split('\n').first;
      }
      return poem;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET POEMS SORTED BY FIRST LETTER (A-Z sorting)
  // ───────────────────────────────────────────────────────────────

  Future<List<Poem>> getPoemsByFirstLetter(int bookId, String letter) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        p.*,
        MAX(CASE WHEN vc.language_code = 'ur' THEN vc.verse_text END) as title_urdu,
        MAX(CASE WHEN vc.language_code = 'en' THEN vc.verse_text END) as title_english,
        MAX(CASE WHEN vc.language_code = 'bn' THEN vc.verse_text END) as title_bangla,
        MAX(CASE WHEN vc.language_code = 'hi' THEN vc.verse_text END) as title_hindi
      FROM poems p
      LEFT JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      LEFT JOIN verse_content vc ON vc.verse_id = v.id
      WHERE p.book_id = ? AND p.first_letter_urdu = ?
      GROUP BY p.id
      ORDER BY p.sort_order ASC
    ''', [bookId, letter]);

    return results.map((map) {
      final poem = Poem.fromMap(map);
      if (map['title_urdu'] != null) {
        poem.titleUrdu = (map['title_urdu'] as String).split('\n').first;
      }
      if (map['title_english'] != null) {
        poem.titleEnglish = (map['title_english'] as String).split('\n').first;
      }
      if (map['title_bangla'] != null) {
        poem.titleBangla = (map['title_bangla'] as String).split('\n').first;
      }
      if (map['title_hindi'] != null) {
        poem.titleHindi = (map['title_hindi'] as String).split('\n').first;
      }
      return poem;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET POEMS SORTED BY LAST LETTER (Z-A sorting)
  // ───────────────────────────────────────────────────────────────

  Future<List<Poem>> getPoemsByLastLetter(int bookId, String letter) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        p.*,
        MAX(CASE WHEN vc.language_code = 'ur' THEN vc.verse_text END) as title_urdu,
        MAX(CASE WHEN vc.language_code = 'en' THEN vc.verse_text END) as title_english
      FROM poems p
      LEFT JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      LEFT JOIN verse_content vc ON vc.verse_id = v.id
      WHERE p.book_id = ? AND p.last_letter_urdu = ?
      GROUP BY p.id
      ORDER BY p.sort_order ASC
    ''', [bookId, letter]);

    return results.map((map) {
      final poem = Poem.fromMap(map);
      if (map['title_urdu'] != null) {
        poem.titleUrdu = (map['title_urdu'] as String).split('\n').first;
      }
      if (map['title_english'] != null) {
        poem.titleEnglish = (map['title_english'] as String).split('\n').first;
      }
      return poem;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET POEM BY ID (with title)
  // ───────────────────────────────────────────────────────────────

  Future<Poem?> getPoemById(int id) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        p.*,
        MAX(CASE WHEN vc.language_code = 'ur' THEN vc.verse_text END) as title_urdu,
        MAX(CASE WHEN vc.language_code = 'en' THEN vc.verse_text END) as title_english,
        MAX(CASE WHEN vc.language_code = 'bn' THEN vc.verse_text END) as title_bangla,
        MAX(CASE WHEN vc.language_code = 'hi' THEN vc.verse_text END) as title_hindi
      FROM poems p
      LEFT JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      LEFT JOIN verse_content vc ON vc.verse_id = v.id
      WHERE p.id = ?
      GROUP BY p.id
    ''', [id]);

    if (results.isEmpty) return null;

    final poem = Poem.fromMap(results.first);
    final map = results.first;
    if (map['title_urdu'] != null) {
      poem.titleUrdu = (map['title_urdu'] as String).split('\n').first;
    }
    if (map['title_english'] != null) {
      poem.titleEnglish = (map['title_english'] as String).split('\n').first;
    }
    if (map['title_bangla'] != null) {
      poem.titleBangla = (map['title_bangla'] as String).split('\n').first;
    }
    if (map['title_hindi'] != null) {
      poem.titleHindi = (map['title_hindi'] as String).split('\n').first;
    }
    return poem;
  }

  // ───────────────────────────────────────────────────────────────
  // INSERT POEM
  // ───────────────────────────────────────────────────────────────

  Future<int> insertPoem(Poem poem) async {
    final db = await _dbHelper.database;
    return await db.insert('poems', poem.toMap());
  }

  // ───────────────────────────────────────────────────────────────
  // UPDATE POEM
  // ───────────────────────────────────────────────────────────────

  Future<void> updatePoem(Poem poem) async {
    final db = await _dbHelper.database;
    await db.update(
      'poems',
      poem.toMap(),
      where: 'id = ?',
      whereArgs: [poem.id],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // DELETE POEM (cascades to verses)
  // ───────────────────────────────────────────────────────────────

  Future<void> deletePoem(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'poems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SEARCH POEMS IN BOOK (by title - searches verse text)
  // ───────────────────────────────────────────────────────────────

  Future<List<Poem>> searchPoemsInBook(
    int bookId,
    String searchTerm,
    String languageCode,
  ) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT DISTINCT
        p.*,
        vc.verse_text as title_text
      FROM poems p
      JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      JOIN verse_content vc ON vc.verse_id = v.id AND vc.language_code = ?
      WHERE p.book_id = ? AND vc.verse_text LIKE ?
      ORDER BY p.sort_order ASC
    ''', [languageCode, bookId, '%$searchTerm%']);

    return results.map((map) {
      final poem = Poem.fromMap(map);
      final title = (map['title_text'] as String).split('\n').first;

      // Set title based on language
      switch (languageCode) {
        case 'ur':
          poem.titleUrdu = title;
          break;
        case 'en':
          poem.titleEnglish = title;
          break;
        case 'bn':
          poem.titleBangla = title;
          break;
        case 'hi':
          poem.titleHindi = title;
          break;
      }

      return poem;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET POEM COUNT IN BOOK
  // ───────────────────────────────────────────────────────────────

  Future<int> getPoemCountInBook(int bookId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM poems WHERE book_id = ?',
      [bookId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ───────────────────────────────────────────────────────────────
  // MARK AUDIO AS DOWNLOADED
  // ───────────────────────────────────────────────────────────────

  Future<void> markAudioDownloaded(int poemId, bool isDownloaded) async {
    final db = await _dbHelper.database;
    await db.update(
      'poems',
      {'is_audio_downloaded': isDownloaded ? 1 : 0},
      where: 'id = ?',
      whereArgs: [poemId],
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY get poem titles from verses?
   - Poems don't have separate title field
   - Title = first line of first verse
   - We join with verses table to get it

2. WHAT is .split('\n').first?
   - Verse might have multiple lines
   - We only want first line for title
   - Example:
     "مصطفیٰ جان رحمت\nشمع بزم ہدایت"
     → Only "مصطفیٰ جان رحمت" is used as title

3. HOW sorting works?
   - getPoemsByFirstLetter('م') → All poems starting with م
   - getPoemsByLastLetter('م') → All poems ending with م
   - Used when user clicks alphabet on top of screen

4. WHY searchPoemsInBook searches in verse_text?
   - Because poem title IS the verse text
   - When user searches "مصطفیٰ", we search in first verses
   - Returns poems whose first verse contains search term

5. HOW to use in UI?
   
   // Get all poems in a book
   List<Poem> poems = await poemRepo.getPoemsByBookId(1);
   
   // Get poems starting with 'م'
   List<Poem> mPoems = await poemRepo.getPoemsByFirstLetter(1, 'م');
   
   // Search poems
   List<Poem> results = await poemRepo.searchPoemsInBook(
     1, 'مصطفیٰ', 'ur'
   );
   
   // Display
   ListView.builder(
     itemCount: poems.length,
     itemBuilder: (context, index) {
       return ListTile(
         title: Text(poems[index].getTitle('ur')),
         trailing: Icon(poems[index].hasAudio ? Icons.music : null),
       );
     },
   );

═══════════════════════════════════════════════════════════════
*/