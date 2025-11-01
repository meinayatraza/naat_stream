import 'package:sqflite/sqflite.dart';
import '../../services/database/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════
/// BOOKMARK REPOSITORY
/// Handles bookmarks for verse selection (for recitation)
/// User selects specific verses from a poem to recite easily
/// ═══════════════════════════════════════════════════════════════

class BookmarkRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ───────────────────────────────────────────────────────────────
  // ADD BOOKMARK (bookmark a verse in a poem)
  // ───────────────────────────────────────────────────────────────

  Future<bool> addBookmark({
    String? userId,
    required int poemId,
    required int verseId,
  }) async {
    final db = await _dbHelper.database;

    try {
      // Get current max order for this poem
      final maxOrderResult = await db.rawQuery('''
        SELECT MAX(bookmark_order) as max_order 
        FROM bookmarks 
        WHERE user_id IS ? AND poem_id = ?
      ''', [userId, poemId]);

      final maxOrder = Sqflite.firstIntValue(maxOrderResult) ?? 0;

      await db.insert(
        'bookmarks',
        {
          'user_id': userId,
          'poem_id': poemId,
          'verse_id': verseId,
          'bookmark_order': maxOrder + 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (e) {
      print('Error adding bookmark: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // REMOVE BOOKMARK
  // ───────────────────────────────────────────────────────────────

  Future<bool> removeBookmark({
    String? userId,
    required int poemId,
    required int verseId,
  }) async {
    final db = await _dbHelper.database;

    try {
      final count = await db.delete(
        'bookmarks',
        where: 'user_id IS ? AND poem_id = ? AND verse_id = ?',
        whereArgs: [userId, poemId, verseId],
      );
      return count > 0;
    } catch (e) {
      print('Error removing bookmark: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CHECK IF VERSE IS BOOKMARKED
  // ───────────────────────────────────────────────────────────────

  Future<bool> isBookmarked({
    String? userId,
    required int poemId,
    required int verseId,
  }) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'bookmarks',
      where: 'user_id IS ? AND poem_id = ? AND verse_id = ?',
      whereArgs: [userId, poemId, verseId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOKMARKED VERSES FOR A POEM (with content)
  // This is what user sees when clicking "Bookmarked Verses" button
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBookmarkedVerses({
    String? userId,
    required int poemId,
    required String languageCode,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        b.id as bookmark_id,
        b.bookmark_order,
        v.id as verse_id,
        v.verse_order,
        vc.verse_text,
        vc.translation,
        vc.explanation
      FROM bookmarks b
      JOIN verses v ON b.verse_id = v.id
      JOIN verse_content vc ON vc.verse_id = v.id AND vc.language_code = ?
      WHERE b.user_id IS ? AND b.poem_id = ?
      ORDER BY b.bookmark_order ASC
    ''', [languageCode, userId, poemId]);

    return results;
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOKMARKED VERSE IDS FOR A POEM (just IDs for quick check)
  // ───────────────────────────────────────────────────────────────

  Future<List<int>> getBookmarkedVerseIds({
    String? userId,
    required int poemId,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'bookmarks',
      columns: ['verse_id'],
      where: 'user_id IS ? AND poem_id = ?',
      whereArgs: [userId, poemId],
    );

    return results.map((map) => map['verse_id'] as int).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOKMARK COUNT FOR A POEM
  // ───────────────────────────────────────────────────────────────

  Future<int> getBookmarkCount({
    String? userId,
    required int poemId,
  }) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM bookmarks 
      WHERE user_id IS ? AND poem_id = ?
    ''', [userId, poemId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ───────────────────────────────────────────────────────────────
  // REORDER BOOKMARKS (user can change order)
  // ───────────────────────────────────────────────────────────────

  Future<void> reorderBookmarks({
    String? userId,
    required int poemId,
    required List<int> verseIds, // New order
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      for (int i = 0; i < verseIds.length; i++) {
        await txn.update(
          'bookmarks',
          {'bookmark_order': i + 1},
          where: 'user_id IS ? AND poem_id = ? AND verse_id = ?',
          whereArgs: [userId, poemId, verseIds[i]],
        );
      }
    });
  }

  // ───────────────────────────────────────────────────────────────
  // CLEAR ALL BOOKMARKS FOR A POEM
  // ───────────────────────────────────────────────────────────────

  Future<void> clearBookmarksForPoem({
    String? userId,
    required int poemId,
  }) async {
    final db = await _dbHelper.database;

    await db.delete(
      'bookmarks',
      where: 'user_id IS ? AND poem_id = ?',
      whereArgs: [userId, poemId],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE BOOKMARK (add if not exists, remove if exists)
  // ───────────────────────────────────────────────────────────────

  Future<bool> toggleBookmark({
    String? userId,
    required int poemId,
    required int verseId,
  }) async {
    final isBookmark = await isBookmarked(
      userId: userId,
      poemId: poemId,
      verseId: verseId,
    );

    if (isBookmark) {
      await removeBookmark(
        userId: userId,
        poemId: poemId,
        verseId: verseId,
      );
      return false; // Removed
    } else {
      await addBookmark(
        userId: userId,
        poemId: poemId,
        verseId: verseId,
      );
      return true; // Added
    }
  }

  // ───────────────────────────────────────────────────────────────
  // GET ALL BOOKMARKS (for a user - across all poems)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBookmarks({
    String? userId,
    String languageCode = 'en',
  }) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        b.poem_id,
        p.book_id,
        COUNT(b.verse_id) as bookmark_count,
        b_trans.book_title,
        vc.verse_text as poem_title
      FROM bookmarks b
      JOIN poems p ON b.poem_id = p.id
      JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      JOIN verse_content vc ON vc.verse_id = v.id AND vc.language_code = ?
      LEFT JOIN book_translations b_trans 
        ON b_trans.book_id = p.book_id AND b_trans.language_code = 'en'
      WHERE b.user_id IS ?
      GROUP BY b.poem_id
      ORDER BY b.created_at DESC
    ''', [languageCode, userId]);

    // Extract first line as poem title
    return results.map((map) {
      final modifiedMap = Map<String, dynamic>.from(map);
      if (map['poem_title'] != null) {
        modifiedMap['poem_title'] =
            (map['poem_title'] as String).split('\n').first;
      }
      return modifiedMap;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET ALL BOOKMARKS FOR SYNC
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBookmarksForSync({
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'bookmarks',
      where: 'user_id IS ?',
      whereArgs: [userId],
    );

    return results;
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is the purpose of bookmarks?
   - Different from favorites!
   - Favorites = user likes the poem/verse
   - Bookmarks = user wants to recite specific verses
   
   Example Use Case:
   Poem has 20 verses, but user only wants to recite verses 
   3, 7, 12, and 15 during a gathering. They bookmark these 
   4 verses, then click "Bookmarked Verses" button to see 
   only those 4 verses together.

2. WHY bookmark_order field?
   - User can arrange verses in custom order
   - Maybe they want verse 15 before verse 7
   - reorderBookmarks() allows this
   
   Usage:
   // User drags verses to new order: [15, 7, 3, 12]
   await bookmarkRepo.reorderBookmarks(
     userId: null,
     poemId: 5,
     verseIds: [15, 7, 3, 12],
   );

3. HOW UI works with bookmarks?
   
   POEM DETAIL SCREEN:
   ┌─────────────────────────────────────────────┐
   │ Poem Title          🔖 Bookmarked (4) →    │
   ├─────────────────────────────────────────────┤
   │                                             │
   │ Verse 1: مصطفیٰ جان رحمت...                 │
   │ [Share] [Copy] [⭐] [🔖]                    │
   │                                             │
   │ Verse 2: شمع بزم ہدایت...                   │
   │ [Share] [Copy] [⭐] [🔖]  ← Click to bookmark│
   │                                             │
   └─────────────────────────────────────────────┘
   
   BOOKMARKED VERSES POPUP (when user clicks "Bookmarked (4)"):
   ┌─────────────────────────────────────────────┐
   │ Bookmarked Verses for Recitation            │
   ├─────────────────────────────────────────────┤
   │ 1. Verse 3: جو چمکا...                      │
   │ 2. Verse 7: کہ جن کو...                     │
   │ 3. Verse 12: محمد کا...                     │
   │ 4. Verse 15: رسول اللہ...                   │
   │                                             │
   │ [Reorder] [Clear All] [Close]              │
   └─────────────────────────────────────────────┘

4. CODE example for UI:
   
   // Get bookmark count for top-right badge
   int count = await bookmarkRepo.getBookmarkCount(
     userId: null,
     poemId: widget.poemId,
   );
   
   // Show "Bookmarked (4)" button
   TextButton(
     child: Text('Bookmarked ($count)'),
     onPressed: () => showBookmarkedVersesDialog(),
   );
   
   // Check if verse is bookmarked (show filled/empty icon)
   bool isBookmarked = await bookmarkRepo.isBookmarked(
     userId: null,
     poemId: widget.poemId,
     verseId: verse.id,
   );
   
   IconButton(
     icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
     onPressed: () async {
       bool added = await bookmarkRepo.toggleBookmark(
         userId: null,
         poemId: widget.poemId,
         verseId: verse.id,
       );
       
       if (added) {
         showSnackBar('Verse bookmarked for recitation');
       } else {
         showSnackBar('Bookmark removed');
       }
     },
   );

5. WHAT is getAllBookmarks for?
   - Shows all poems that have bookmarked verses
   - User can see which poems they've bookmarked from
   - Useful for a dedicated "My Bookmarks" screen
   
   Result:
   [
     {
       poem_id: 5,
       bookmark_count: 4,
       book_title: 'Hadaiq-e-Bakhshish',
       poem_title: 'مصطفیٰ جان رحمت'
     },
     {
       poem_id: 12,
       bookmark_count: 2,
       book_title: 'Salam-e-Raza',
       poem_title: 'یا نبی'
     }
   ]

6. DIFFERENCE between favorites and bookmarks:

   FAVORITES:
   - Purpose: User likes it
   - Action: ⭐ Star icon
   - Storage: favorites table
   - Can be: poems OR verses
   - Usage: "Save for later", "I like this"
   
   BOOKMARKS:
   - Purpose: User wants to recite selected verses
   - Action: 🔖 Bookmark icon
   - Storage: bookmarks table
   - Can be: verses only (not whole poems)
   - Usage: "Select verses for recitation"

═══════════════════════════════════════════════════════════════
*/