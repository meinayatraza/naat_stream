import 'package:flutter/material.dart';
import '../data/repositories/favourites_repository.dart';
import '../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// FAVORITES PROVIDER
/// Manages favorites state (poems and verses)
/// Keeps track of what's favorited for quick UI updates
/// ═══════════════════════════════════════════════════════════════

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository _repository = FavoritesRepository();

  // Cache of favorited item IDs for quick lookup
  Set<String> _favoritePoemIds = {};
  Set<String> _favoriteVerseIds = {};

  // Current user ID (null for local user)
  String? _userId;

  bool _isInitialized = false;

  // ───────────────────────────────────────────────────────────────
  // GETTERS
  // ───────────────────────────────────────────────────────────────

  bool get isInitialized => _isInitialized;
  Set<String> get favoritePoemIds => _favoritePoemIds;
  Set<String> get favoriteVerseIds => _favoriteVerseIds;

  int get favoritePoemsCount => _favoritePoemIds.length;
  int get favoriteVersesCount => _favoriteVerseIds.length;
  int get totalFavoritesCount =>
      _favoritePoemIds.length + _favoriteVerseIds.length;

  // ───────────────────────────────────────────────────────────────
  // INITIALIZE: Load favorites from database
  // ───────────────────────────────────────────────────────────────

  Future<void> initialize({String? userId}) async {
    _userId = userId;
    await _loadFavorites();
    _isInitialized = true;
    print(
        '✅ Favorites Provider initialized: ${_favoritePoemIds.length} poems, ${_favoriteVerseIds.length} verses');
  }

  // ───────────────────────────────────────────────────────────────
  // LOAD FAVORITES: Get all favorite IDs from database
  // ───────────────────────────────────────────────────────────────

  Future<void> _loadFavorites() async {
    try {
      // Load favorite poems
      final poemResults = await _repository.getFavoritePoems(
        userId: _userId,
        languageCode: 'en', // Just need IDs, language doesn't matter
      );
      _favoritePoemIds =
          poemResults.map((map) => map['poem_id'].toString()).toSet();

      // Load favorite verses
      final verseResults = await _repository.getFavoriteVerses(
        userId: _userId,
        languageCode: 'en',
      );
      _favoriteVerseIds =
          verseResults.map((map) => map['verse_id'].toString()).toSet();

      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CHECK IF FAVORITED
  // ───────────────────────────────────────────────────────────────

  bool isPoemFavorited(int poemId) {
    return _favoritePoemIds.contains(poemId.toString());
  }

  bool isVerseFavorited(int verseId) {
    return _favoriteVerseIds.contains(verseId.toString());
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE FAVORITE POEM
  // ───────────────────────────────────────────────────────────────

  Future<bool> togglePoemFavorite(int poemId) async {
    try {
      final isAdded = await _repository.toggleFavorite(
        userId: _userId,
        itemType: AppConstants.itemTypePoem,
        itemId: poemId,
      );

      // Update cache
      if (isAdded) {
        _favoritePoemIds.add(poemId.toString());
      } else {
        _favoritePoemIds.remove(poemId.toString());
      }

      notifyListeners();
      return isAdded;
    } catch (e) {
      print('Error toggling poem favorite: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE FAVORITE VERSE
  // ───────────────────────────────────────────────────────────────

  Future<bool> toggleVerseFavorite(int verseId) async {
    try {
      final isAdded = await _repository.toggleFavorite(
        userId: _userId,
        itemType: AppConstants.itemTypeVerse,
        itemId: verseId,
      );

      // Update cache
      if (isAdded) {
        _favoriteVerseIds.add(verseId.toString());
      } else {
        _favoriteVerseIds.remove(verseId.toString());
      }

      notifyListeners();
      return isAdded;
    } catch (e) {
      print('Error toggling verse favorite: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // GET FAVORITE POEMS (with details)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFavoritePoems(
      String languageCode) async {
    return await _repository.getFavoritePoems(
      userId: _userId,
      languageCode: languageCode,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // GET FAVORITE VERSES (with details)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getFavoriteVerses(
      String languageCode) async {
    return await _repository.getFavoriteVerses(
      userId: _userId,
      languageCode: languageCode,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // GET FAVORITE POEM IDS IN BOOK (for displaying stars on list)
  // ───────────────────────────────────────────────────────────────

  Future<List<int>> getFavoritePoemIdsInBook(int bookId) async {
    return await _repository.getFavoritePoemIdsInBook(bookId, userId: _userId);
  }

  // ───────────────────────────────────────────────────────────────
  // CLEAR ALL FAVORITES
  // ───────────────────────────────────────────────────────────────

  Future<void> clearAllFavorites() async {
    try {
      await _repository.clearAllFavorites(userId: _userId);
      _favoritePoemIds.clear();
      _favoriteVerseIds.clear();
      notifyListeners();
      print('✅ All favorites cleared');
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // UPDATE USER ID (when user signs in/out)
  // ───────────────────────────────────────────────────────────────

  Future<void> updateUserId(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;
    await _loadFavorites(); // Reload favorites for new user
    print('✅ Favorites updated for user: $userId');
  }

  // ───────────────────────────────────────────────────────────────
  // REFRESH: Reload favorites from database
  // ───────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    await _loadFavorites();
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY cache favorite IDs in Set?
   - Fast lookup: O(1) time complexity
   - Check if poem is favorited instantly
   - No database query needed for every poem in list
   
   Without cache:
   for (each poem in list) {
     bool isFav = await checkDatabase(); // SLOW!
   }
   
   With cache:
   for (each poem in list) {
     bool isFav = provider.isPoemFavorited(id); // INSTANT!
   }

2. HOW to use in UI?
   
   // In poem list:
   Consumer<FavoritesProvider>(
     builder: (context, favProvider, child) {
       bool isFav = favProvider.isPoemFavorited(poem.id);
       
       return IconButton(
         icon: Icon(
           isFav ? Icons.favorite : Icons.favorite_border,
           color: isFav ? Colors.red : Colors.grey,
         ),
         onPressed: () async {
           bool added = await favProvider.togglePoemFavorite(poem.id);
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(added 
                 ? AppConstants.msgAddedToFavorites
                 : AppConstants.msgRemovedFromFavorites
               ),
             ),
           );
         },
       );
     },
   );

3. WHAT happens when user favorites a poem?
   
   User clicks favorite button
   ↓
   togglePoemFavorite() called
   ↓
   Repository adds to database
   ↓
   Provider adds ID to cache (_favoritePoemIds)
   ↓
   notifyListeners() called
   ↓
   All widgets listening rebuild
   ↓
   Heart icon becomes filled!

4. WHY separate methods for poems and verses?
   - They're stored differently (item_type field)
   - UI needs to know which type it's working with
   - Makes code clearer

5. WHAT is updateUserId for?
   
   // User signs in
   await favProvider.updateUserId('firebase_abc123');
   // Loads favorites for that user
   
   // User signs out
   await favProvider.updateUserId(null);
   // Loads local favorites

6. HOW favorites sync works?
   
   Local user (not signed in):
   userId = null
   Favorites stored locally
   
   User signs in:
   userId = 'abc123'
   DatabaseHelper.updateLocalDataToUser('abc123')
   favProvider.updateUserId('abc123')
   Favorites now linked to user
   Can sync to cloud

7. PERFORMANCE optimization:
   - Cache loaded once on app start
   - Quick checks without database
   - Only database access on toggle
   - Refresh when needed

8. UI EXAMPLE - Favorites Screen:
   
   FutureBuilder(
     future: favProvider.getFavoritePoems('ur'),
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return CircularProgressIndicator();
       }
       
       final poems = snapshot.data!;
       
       return ListView.builder(
         itemCount: poems.length,
         itemBuilder: (context, index) {
           final poem = poems[index];
           return ListTile(
             title: Text(poem['poem_title']),
             subtitle: Text(poem['book_title']),
             trailing: IconButton(
               icon: Icon(Icons.favorite, color: Colors.red),
               onPressed: () {
                 favProvider.togglePoemFavorite(poem['poem_id']);
               },
             ),
           );
         },
       );
     },
   );

═══════════════════════════════════════════════════════════════
*/