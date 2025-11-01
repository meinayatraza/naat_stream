import 'package:flutter/material.dart';
import '../data/repositories/bookmark_repository.dart';

/// ═══════════════════════════════════════════════════════════════
/// BOOKMARK PROVIDER
/// Manages verse bookmarks (for recitation selection)
/// Caches bookmarks per poem for quick lookup
/// ═══════════════════════════════════════════════════════════════

class BookmarkProvider extends ChangeNotifier {
  final BookmarkRepository _repository = BookmarkRepository();

  // Cache: Map<poemId, Set<verseId>>
  // Stores which verses are bookmarked for each poem
  Map<int, Set<int>> _bookmarkCache = {};

  // Current user ID (null for local user)
  String? _userId;

  bool _isInitialized = false;

  // ───────────────────────────────────────────────────────────────
  // GETTERS
  // ───────────────────────────────────────────────────────────────

  bool get isInitialized => _isInitialized;

  // ───────────────────────────────────────────────────────────────
  // INITIALIZE
  // ───────────────────────────────────────────────────────────────

  Future<void> initialize({String? userId}) async {
    _userId = userId;
    _isInitialized = true;
    print('✅ Bookmark Provider initialized');
  }

  // ───────────────────────────────────────────────────────────────
  // LOAD BOOKMARKS FOR POEM (lazy loading)
  // ───────────────────────────────────────────────────────────────

  Future<void> _loadBookmarksForPoem(int poemId) async {
    if (_bookmarkCache.containsKey(poemId)) return; // Already loaded

    try {
      final verseIds = await _repository.getBookmarkedVerseIds(
        userId: _userId,
        poemId: poemId,
      );

      _bookmarkCache[poemId] = verseIds.toSet();
    } catch (e) {
      print('Error loading bookmarks for poem $poemId: $e');
      _bookmarkCache[poemId] = {};
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CHECK IF VERSE IS BOOKMARKED
  // ───────────────────────────────────────────────────────────────

  Future<bool> isVerseBookmarked(int poemId, int verseId) async {
    // Ensure bookmarks are loaded for this poem
    await _loadBookmarksForPoem(poemId);

    return _bookmarkCache[poemId]?.contains(verseId) ?? false;
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOKMARK COUNT FOR POEM
  // ───────────────────────────────────────────────────────────────

  Future<int> getBookmarkCount(int poemId) async {
    await _loadBookmarksForPoem(poemId);
    return _bookmarkCache[poemId]?.length ?? 0;
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE BOOKMARK
  // ───────────────────────────────────────────────────────────────

  Future<bool> toggleBookmark(int poemId, int verseId) async {
    try {
      // Ensure cache is loaded
      await _loadBookmarksForPoem(poemId);

      // Toggle in database
      final isAdded = await _repository.toggleBookmark(
        userId: _userId,
        poemId: poemId,
        verseId: verseId,
      );

      // Update cache
      if (isAdded) {
        _bookmarkCache[poemId]?.add(verseId);
      } else {
        _bookmarkCache[poemId]?.remove(verseId);
      }

      notifyListeners();
      return isAdded;
    } catch (e) {
      print('Error toggling bookmark: $e');
      return false;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // GET BOOKMARKED VERSES (with content)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBookmarkedVerses(
    int poemId,
    String languageCode,
  ) async {
    return await _repository.getBookmarkedVerses(
      userId: _userId,
      poemId: poemId,
      languageCode: languageCode,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // GET ALL BOOKMARKS (across all poems)
  // ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBookmarks(
      String languageCode) async {
    return await _repository.getAllBookmarks(
      userId: _userId,
      languageCode: languageCode,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CLEAR BOOKMARKS FOR POEM
  // ───────────────────────────────────────────────────────────────

  Future<void> clearBookmarksForPoem(int poemId) async {
    try {
      await _repository.clearBookmarksForPoem(
        userId: _userId,
        poemId: poemId,
      );

      _bookmarkCache[poemId]?.clear();
      notifyListeners();

      print('✅ Bookmarks cleared for poem $poemId');
    } catch (e) {
      print('Error clearing bookmarks: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // REORDER BOOKMARKS
  // ───────────────────────────────────────────────────────────────

  Future<void> reorderBookmarks(int poemId, List<int> verseIds) async {
    try {
      await _repository.reorderBookmarks(
        userId: _userId,
        poemId: poemId,
        verseIds: verseIds,
      );

      // Update cache
      _bookmarkCache[poemId] = verseIds.toSet();
      notifyListeners();

      print('✅ Bookmarks reordered for poem $poemId');
    } catch (e) {
      print('Error reordering bookmarks: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // UPDATE USER ID (when user signs in/out)
  // ───────────────────────────────────────────────────────────────

  Future<void> updateUserId(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;
    _bookmarkCache.clear(); // Clear cache, will reload on demand
    notifyListeners();

    print('✅ Bookmarks updated for user: $userId');
  }

  // ───────────────────────────────────────────────────────────────
  // CLEAR CACHE FOR POEM (force reload next time)
  // ───────────────────────────────────────────────────────────────

  void clearCacheForPoem(int poemId) {
    _bookmarkCache.remove(poemId);
    notifyListeners();
  }

  // ───────────────────────────────────────────────────────────────
  // REFRESH ALL (clear all cache)
  // ───────────────────────────────────────────────────────────────

  void refreshAll() {
    _bookmarkCache.clear();
    notifyListeners();
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY lazy loading?
   - Don't load all bookmarks for all poems on app start
   - Only load when user opens a specific poem
   - Saves memory and faster startup
   
   Example:
   User opens poem #5
   → _loadBookmarksForPoem(5) called
   → Loads only poem #5's bookmarks
   → Cached for quick access later

2. WHY Map<poemId, Set<verseId>>?
   - Each poem has its own set of bookmarked verses
   - Easy to check: _bookmarkCache[5].contains(12)
   - Efficient: O(1) lookup
   
   Structure:
   {
     5: {12, 15, 18, 20},    // Poem 5 has 4 bookmarked verses
     10: {3, 7},              // Poem 10 has 2 bookmarked verses
   }

3. HOW to use in poem detail screen?
   
   class PoemDetailScreen extends StatelessWidget {
     final int poemId;
     
     @override
     Widget build(BuildContext context) {
       return Consumer<BookmarkProvider>(
         builder: (context, bookmarkProvider, child) {
           return FutureBuilder<int>(
             future: bookmarkProvider.getBookmarkCount(poemId),
             builder: (context, snapshot) {
               final count = snapshot.data ?? 0;
               
               return AppBar(
                 title: Text('Poem Detail'),
                 actions: [
                   // Show bookmark count button
                   TextButton.icon(
                     icon: Icon(Icons.bookmark),
                     label: Text('Bookmarked ($count)'),
                     onPressed: count > 0 
                       ? () => _showBookmarkedVersesDialog()
                       : null,
                   ),
                 ],
               );
             },
           );
         },
       );
     }
   }

4. HOW to show bookmark icon on each verse?
   
   // In verse card:
   FutureBuilder<bool>(
     future: bookmarkProvider.isVerseBookmarked(
       widget.poemId, 
       verse.id,
     ),
     builder: (context, snapshot) {
       final isBookmarked = snapshot.data ?? false;
       
       return IconButton(
         icon: Icon(
           isBookmarked ? Icons.bookmark : Icons.bookmark_border,
           color: isBookmarked ? Colors.blue : Colors.grey,
         ),
         onPressed: () async {
           final added = await bookmarkProvider.toggleBookmark(
             widget.poemId,
             verse.id,
           );
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(added 
                 ? AppConstants.msgAddedToBookmarks
                 : AppConstants.msgRemovedFromBookmarks
               ),
             ),
           );
         },
       );
     },
   );

5. HOW to show bookmarked verses dialog?
   
   void _showBookmarkedVersesDialog() async {
     final langCode = context.read<LanguageProvider>().currentLanguage;
     
     final verses = await context.read<BookmarkProvider>()
       .getBookmarkedVerses(widget.poemId, langCode);
     
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text(AppConstants.titleBookmarks),
         content: SingleChildScrollView(
           child: Column(
             children: verses.map((verse) {
               return ListTile(
                 title: Text('Verse ${verse['verse_order']}'),
                 subtitle: Text(verse['verse_text']),
               );
             }).toList(),
           ),
         ),
         actions: [
           TextButton(
             child: Text('Clear All'),
             onPressed: () {
               context.read<BookmarkProvider>()
                 .clearBookmarksForPoem(widget.poemId);
               Navigator.pop(context);
             },
           ),
           TextButton(
             child: Text('Close'),
             onPressed: () => Navigator.pop(context),
           ),
         ],
       ),
     );
   }

6. DIFFERENCE between Favorites and Bookmarks (again):
   
   FAVORITES:
   - Purpose: User likes content
   - Icon: ⭐ or ❤️
   - Can be: Poems OR Verses
   - Stored: favorites table
   - Cache: All favorites loaded at start
   
   BOOKMARKS:
   - Purpose: Select verses for recitation
   - Icon: 🔖
   - Can be: Verses only (within a poem)
   - Stored: bookmarks table
   - Cache: Loaded per poem (lazy)

7. WHY clearCache methods?
   - clearCacheForPoem(): If bookmarks changed externally
   - refreshAll(): After sync from cloud
   - Forces reload from database

8. PERFORMANCE:
   - Lazy loading = Fast app startup
   - Caching = No repeated database queries
   - Only loads data when needed
   - Memory efficient

═══════════════════════════════════════════════════════════════
*/