import 'package:sqflite/sqflite.dart';
import '../../models/verse_model.dart';
import '../../services/database/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════
/// VERSE REPOSITORY
/// Handles all database operations related to verses
/// This is the most important repository for content display
/// ═══════════════════════════════════════════════════════════════

class VerseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ───────────────────────────────────────────────────────────────
  // GET ALL VERSES OF A POEM (with content in specific language)
  // ───────────────────────────────────────────────────────────────

  Future<List<Verse>> getVersesByPoemId(int poemId, String languageCode) async {
    final db = await _dbHelper.database;

    // Get verses with their content in specified language
    final results = await db.rawQuery('''
      SELECT 
        v.id,
        v.poem_id,
        v.verse_order,
        vc.verse_text,
        vc.translation,
        vc.explanation
      FROM verses v
      JOIN verse_content vc ON v.id = vc.verse_id AND vc.language_code = ?
      WHERE v.poem_id = ?
      ORDER BY v.verse_order ASC
    ''', [languageCode, poemId]);

    return results.map((map) {
      final verse = Verse(
        id: map['id'] as int,
        poemId: map['poem_id'] as int,
        verseOrder: map['verse_order'] as int,
      );

      // Add content based on language
      final content = VerseContent(
        verseId: verse.id!,
        languageCode: languageCode,
        verseText: map['verse_text'] as String,
        translation: map['translation'] as String?,
        explanation: map['explanation'] as String?,
      );

      switch (languageCode) {
        case 'ur':
          verse.urduContent = content;
          break;
        case 'en':
          verse.englishContent = content;
          break;
        case 'bn':
          verse.banglaContent = content;
          break;
        case 'hi':
          verse.hindiContent = content;
          break;
      }

      return verse;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET SINGLE VERSE BY ID (with all language content)
  // ───────────────────────────────────────────────────────────────

  Future<Verse?> getVerseById(int verseId) async {
    final db = await _dbHelper.database;

    // Get verse basic info
    final verseResult = await db.query(
      'verses',
      where: 'id = ?',
      whereArgs: [verseId],
    );

    if (verseResult.isEmpty) return null;

    final verse = Verse.fromMap(verseResult.first);

    // Get all language contents
    final contentResults = await db.query(
      'verse_content',
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );

    for (var contentMap in contentResults) {
      final content = VerseContent.fromMap(contentMap);
      switch (content.languageCode) {
        case 'ur':
          verse.urduContent = content;
          break;
        case 'en':
          verse.englishContent = content;
          break;
        case 'bn':
          verse.banglaContent = content;
          break;
        case 'hi':
          verse.hindiContent = content;
          break;
      }
    }

    return verse;
  }

  // ───────────────────────────────────────────────────────────────
  // INSERT VERSE WITH CONTENT (all languages)
  // ───────────────────────────────────────────────────────────────

  Future<int> insertVerse({
    required int poemId,
    required int verseOrder,
    String? urduText,
    String? urduTranslation,
    String? urduExplanation,
    String? englishText,
    String? englishTranslation,
    String? englishExplanation,
    String? banglaText,
    String? banglaTranslation,
    String? banglaExplanation,
    String? hindiText,
    String? hindiTranslation,
    String? hindiExplanation,
  }) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      // 1. Insert verse
      final verseId = await txn.insert('verses', {
        'poem_id': poemId,
        'verse_order': verseOrder,
      });

      // 2. Insert Urdu content (if provided)
      if (urduText != null) {
        await txn.insert('verse_content', {
          'verse_id': verseId,
          'language_code': 'ur',
          'verse_text': urduText,
          'translation': urduTranslation,
          'explanation': urduExplanation,
        });
      }

      // 3. Insert English content (if provided)
      if (englishText != null) {
        await txn.insert('verse_content', {
          'verse_id': verseId,
          'language_code': 'en',
          'verse_text': englishText,
          'translation': englishTranslation,
          'explanation': englishExplanation,
        });
      }

      // 4. Insert Bangla content (if provided)
      if (banglaText != null) {
        await txn.insert('verse_content', {
          'verse_id': verseId,
          'language_code': 'bn',
          'verse_text': banglaText,
          'translation': banglaTranslation,
          'explanation': banglaExplanation,
        });
      }

      // 5. Insert Hindi content (if provided)
      if (hindiText != null) {
        await txn.insert('verse_content', {
          'verse_id': verseId,
          'language_code': 'hi',
          'verse_text': hindiText,
          'translation': hindiTranslation,
          'explanation': hindiExplanation,
        });
      }

      return verseId;
    });
  }

  // ───────────────────────────────────────────────────────────────
  // UPDATE VERSE CONTENT (for specific language)
  // ───────────────────────────────────────────────────────────────

  Future<void> updateVerseContent({
    required int verseId,
    required String languageCode,
    required String verseText,
    String? translation,
    String? explanation,
  }) async {
    final db = await _dbHelper.database;

    await db.insert(
      'verse_content',
      {
        'verse_id': verseId,
        'language_code': languageCode,
        'verse_text': verseText,
        'translation': translation,
        'explanation': explanation,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // DELETE VERSE (cascades to verse_content)
  // ───────────────────────────────────────────────────────────────

  Future<void> deleteVerse(int verseId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'verses',
      where: 'id = ?',
      whereArgs: [verseId],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // GLOBAL SEARCH: Search verses across ALL books
  // (Searches only in verse_text, not translation/explanation)
  // EXCLUDES user-created poems (they are standalone)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> globalSearch(
    String searchTerm,
    String languageCode, {
    int limit = 50,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        v.id as verse_id,
        v.poem_id,
        v.verse_order,
        p.book_id,
        vc.verse_text,
        b_trans.book_title as book_title
      FROM verse_content vc
      JOIN verses v ON vc.verse_id = v.id
      JOIN poems p ON v.poem_id = p.id
      JOIN books b ON p.book_id = b.id
      LEFT JOIN book_translations b_trans 
        ON b_trans.book_id = p.book_id 
        AND b_trans.language_code = 'en'
      WHERE vc.language_code = ? 
        AND vc.verse_text LIKE ?
        AND b.is_user_created = 0
      ORDER BY p.book_id, p.id, v.verse_order
      LIMIT ?
    ''', [languageCode, '%$searchTerm%', limit]);

    return results;
  }

  // ───────────────────────────────────────────────────────────────
  // BOOK-LEVEL SEARCH: Search verses within a specific book
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchInBook(
    int bookId,
    String searchTerm,
    String languageCode, {
    int limit = 50,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        v.id as verse_id,
        v.poem_id,
        v.verse_order,
        vc.verse_text
      FROM verse_content vc
      JOIN verses v ON vc.verse_id = v.id
      JOIN poems p ON v.poem_id = p.id
      WHERE p.book_id = ? 
        AND vc.language_code = ? 
        AND vc.verse_text LIKE ?
      ORDER BY p.id, v.verse_order
      LIMIT ?
    ''', [bookId, languageCode, '%$searchTerm%', limit]);

    return results;
  }

  // ───────────────────────────────────────────────────────────────
  // GET VERSE COUNT IN POEM
  // ───────────────────────────────────────────────────────────────

  Future<int> getVerseCountInPoem(int poemId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM verses WHERE poem_id = ?',
      [poemId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY this is the most important repository?
   - Verses are the main content users interact with
   - Contains search functionality (most used feature)
   - Handles multi-language content

2. HOW getVersesByPoemId works?
   - Gets all verses of a poem
   - In specific language only (efficient!)
   - Returns verses in correct order
   
   Usage:
   List<Verse> verses = await verseRepo.getVersesByPoemId(5, 'ur');
   // Returns verses of poem #5 in Urdu

3. WHAT is the difference between searches?
   
   globalSearch():
   - Searches across ALL books
   - Used when user searches from home screen
   - Returns results from entire database
   
   searchInBook():
   - Searches within ONE book only
   - Used when user searches from book detail screen
   - Faster, more focused results

4. WHY search only in verse_text?
   - As per your requirement
   - Doesn't search in translation or explanation
   - Makes search faster and more relevant

5. HOW insertVerse works with transaction?
   - Inserts verse in verses table
   - Then inserts content in verse_content for each language
   - If any fails, all rollback (data consistency)
   
   Usage:
   await verseRepo.insertVerse(
     poemId: 1,
     verseOrder: 1,
     urduText: 'مصطفیٰ جان رحمت پہ لاکھوں سلام',
     urduExplanation: 'اس شعر میں...',
     englishText: 'Millions of blessings...',
     englishExplanation: 'This verse...',
   );

6. SEARCH results format:
   Returns List<Map> with:
   - verse_id: ID of the verse
   - poem_id: Which poem it belongs to
   - verse_order: Position in poem
   - book_id: Which book (for global search)
   - verse_text: The actual matching text
   - book_title: Book name (for global search)

7. HOW to display search results in UI:
   
   final results = await verseRepo.globalSearch('مصطفیٰ', 'ur');
   
   ListView.builder(
     itemCount: results.length,
     itemBuilder: (context, index) {
       final result = results[index];
       return ListTile(
         title: Text(result['verse_text']),
         subtitle: Text('From: ${result['book_title']}'),
         onTap: () {
           // Navigate to poem detail
           Navigator.push(
             PoemDetailScreen(poemId: result['poem_id'])
           );
         },
       );
     },
   );

═══════════════════════════════════════════════════════════════
*/