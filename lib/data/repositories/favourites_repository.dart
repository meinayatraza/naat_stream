import 'package:sqflite/sqflite.dart';
import '../../models/poem_model.dart';
import '../../models/verse_model.dart';
import '../../services/database/database_helper.dart';
import '../../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// FAVORITES REPOSITORY
/// Handles all database operations related to favorites
/// (Both poems and verses can be favorited)
/// ═══════════════════════════════════════════════════════════════

class FavoritesRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ───────────────────────────────────────────────────────────────
  // ADD TO FAVORITES (poem or verse)
  // ───────────────────────────────────────────────────────────────

  Future<bool> addToFavorites({
    String? userId, // null for local user
    required String itemType, // 'poem' or 'verse'
    required int itemId,
  }) async {
    final db = await _dbHelper.database;

    try {
      await db.insert(
        'favorites',
        {
          'user_id': userId,
          'item_type': itemType,
          'item_id': itemId,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if already exists
      );
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // REMOVE FROM FAVORITES
  // ───────────────────────────────────────────────────────────────

  Future<bool> removeFromFavorites({
    String? userId,
    required String itemType,
    required int itemId,
  }) async {
    final db = await _dbHelper.database;

    try {
      final count = await db.delete(
        'favorites',
        where: 'user_id IS ? AND item_type = ? AND item_id = ?',
        whereArgs: [userId, itemType, itemId],
      );
      return count > 0;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CHECK IF ITEM IS FAVORITED
  // ───────────────────────────────────────────────────────────────

  Future<bool> isFavorite({
    String? userId,
    required String itemType,
    required int itemId,
  }) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'favorites',
      where: 'user_id IS ? AND item_type = ? AND item_id = ?',
      whereArgs: [userId, itemType, itemId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ───────────────────────────────────────────────────────────────
  // GET ALL FAVORITE POEMS (with details)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFavoritePoems({
    String? userId,
    String languageCode = 'en',
  }) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        f.id as favorite_id,
        f.created_at as favorited_at,
        p.id as poem_id,
        p.book_id,
        p.audio_url,
        p.video_url,
        vc.verse_text as poem_title,
        b_trans.book_title
      FROM favorites f
      JOIN poems p ON f.item_id = p.id
      LEFT JOIN verses v ON v.poem_id = p.id AND v.verse_order = 1
      LEFT JOIN verse_content vc ON vc.verse_id = v.id AND vc.language_code = ?
      LEFT JOIN book_translations b_trans 
        ON b_trans.book_id = p.book_id 
        AND b_trans.language_code = 'en'
      WHERE f.user_id IS ? AND f.item_type = ?
      ORDER BY f.created_at DESC
    ''', [languageCode, userId, AppConstants.itemTypePoem]);

    // Extract first line as title
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
  // GET ALL FAVORITE VERSES (with details)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFavoriteVerses({
    String? userId,
    String languageCode = 'en',
  }) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT 
        f.id as favorite_id,
        f.created_at as favorited_at,
        v.id as verse_id,
        v.poem_id,
        v.verse_order,
        p.book_id,
        vc.verse_text,
        vc.translation,
        vc.explanation,
        b_trans.book_title
      FROM favorites f
      JOIN verses v ON f.item_id = v.id
      JOIN verse_content vc ON vc.verse_id = v.id AND vc.language_code = ?
      JOIN poems p ON v.poem_id = p.id
      LEFT JOIN book_translations b_trans 
        ON b_trans.book_id = p.book_id 
        AND b_trans.language_code = 'en'
      WHERE f.user_id IS ? AND f.item_type = ?
      ORDER BY f.created_at DESC
    ''', [languageCode, userId, AppConstants.itemTypeVerse]);

    return results;
  }

  // ───────────────────────────────────────────────────────────────
  // GET FAVORITE POEMS IN A SPECIFIC BOOK
  // ───────────────────────────────────────────────────────────────

  Future<List<int>> getFavoritePoemIdsInBook(int bookId,
      {String? userId}) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT f.item_id
      FROM favorites f
      JOIN poems p ON f.item_id = p.id
      WHERE f.user_id IS ? 
        AND f.item_type = ? 
        AND p.book_id = ?
    ''', [userId, AppConstants.itemTypePoem, bookId]);

    return results.map((map) => map['item_id'] as int).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET FAVORITE VERSES IN A SPECIFIC POEM
  // ───────────────────────────────────────────────────────────────

  Future<List<int>> getFavoriteVerseIdsInPoem(int poemId,
      {String? userId}) async {
    final db = await _dbHelper.database;

    final results = await db.rawQuery('''
      SELECT f.item_id
      FROM favorites f
      JOIN verses v ON f.item_id = v.id
      WHERE f.user_id IS ? 
        AND f.item_type = ? 
        AND v.poem_id = ?
    ''', [userId, AppConstants.itemTypeVerse, poemId]);

    return results.map((map) => map['item_id'] as int).toList();
  }

  // ───────────────────────────────────────────────────────────────
  // GET FAVORITES COUNT
  // ───────────────────────────────────────────────────────────────

  Future<Map<String, int>> getFavoritesCount({String? userId}) async {
    final db = await _dbHelper.database;

    final poemCountResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM favorites 
      WHERE user_id IS ? AND item_type = ?
    ''', [userId, AppConstants.itemTypePoem]);

    final verseCountResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM favorites 
      WHERE user_id IS ? AND item_type = ?
    ''', [userId, AppConstants.itemTypeVerse]);

    return {
      'poems': Sqflite.firstIntValue(poemCountResult) ?? 0,
      'verses': Sqflite.firstIntValue(verseCountResult) ?? 0,
    };
  }

  // ───────────────────────────────────────────────────────────────
  // CLEAR ALL FAVORITES (for user)
  // ───────────────────────────────────────────────────────────────

  Future<void> clearAllFavorites({String? userId}) async {
    final db = await _dbHelper.database;
    await db.delete(
      'favorites',
      where: 'user_id IS ?',
      whereArgs: [userId],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE FAVORITE (add if not exists, remove if exists)
  // ───────────────────────────────────────────────────────────────

  Future<bool> toggleFavorite({
    String? userId,
    required String itemType,
    required int itemId,
  }) async {
    final isFav = await isFavorite(
      userId: userId,
      itemType: itemType,
      itemId: itemId,
    );

    if (isFav) {
      await removeFromFavorites(
        userId: userId,
        itemType: itemType,
        itemId: itemId,
      );
      return false; // Removed
    } else {
      await addToFavorites(
        userId: userId,
        itemType: itemType,
        itemId: itemId,
      );
      return true; // Added
    }
  }

  // ───────────────────────────────────────────────────────────────
  // GET ALL FAVORITES FOR SYNC (when user signs in)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllFavoritesForSync({
    String? userId,
  }) async {
    final db = await _dbHelper.database;

    final results = await db.query(
      'favorites',
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

1. WHY both poems and verses can be favorited?
   - User might like entire poem → favorite the poem
   - User might like specific verse → favorite the verse
   - item_type field distinguishes between them

2. HOW isFavorite works?
   - Checks if item exists in favorites table
   - Used to show filled/empty heart icon in UI
   
   Usage:
   bool isFav = await favRepo.isFavorite(
     userId: null,
     itemType: 'poem',
     itemId: 5,
   );
   
   Icon(isFav ? Icons.favorite : Icons.favorite_border)

3. WHAT is toggleFavorite?
   - Convenience method for UI
   - If favorited → remove it
   - If not favorited → add it
   - Returns true if added, false if removed
   
   Usage:
   IconButton(
     icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
     onPressed: () async {
       bool added = await favRepo.toggleFavorite(
         userId: null,
         itemType: 'poem',
         itemId: widget.poemId,
       );
       
       if (added) {
         showSnackBar('Added to favorites');
       } else {
         showSnackBar('Removed from favorites');
       }
     },
   );

4. WHY getFavoritePoems returns Map not Poem object?
   - It includes extra info (book_title, favorited_at)
   - More flexible for display
   - Can easily add more fields without changing model

5. HOW favorites work with user_id?
   
   Local user (not signed in):
   userId = null
   Favorites stored locally
   
   Signed-in user:
   userId = 'firebase_abc123'
   Favorites linked to user
   Can sync to cloud

6. WHAT is getFavoritePoemIdsInBook for?
   - When showing poems in a book
   - Need to know which ones are favorited
   - Returns just IDs (fast query)
   - Used to show star icon on poem list
   
   Usage:
   List<int> favIds = await favRepo.getFavoritePoemIdsInBook(1);
   
   // In list builder:
   bool isFav = favIds.contains(poem.id);
   Icon(isFav ? Icons.star : Icons.star_border)

7. CLOUD SYNC usage:
   
   // When user signs in
   List<Map> allFavs = await favRepo.getAllFavoritesForSync();
   
   // Upload to Firebase
   await Firebase.collection('favorites')
     .doc(userId)
     .set({'items': allFavs});
   
   // When user signs in on new device
   Map data = await Firebase.collection('favorites')
     .doc(userId)
     .get();
   
   // Insert each favorite locally
   for (var fav in data['items']) {
     await favRepo.addToFavorites(...);
   }

═══════════════════════════════════════════════════════════════
*/