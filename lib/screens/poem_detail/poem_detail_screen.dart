import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/poem_model.dart';
import '../../models/verse_model.dart';
import '../../data/repositories/poem_repository.dart';
import '../../data/repositories/verse_repository.dart';
import '../../providers/language_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/audio_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';
import 'widgets/verse_card.dart';
//import 'widgets/audio_player_bar.dart';

/// ═══════════════════════════════════════════════════════════════
/// POEM DETAIL SCREEN
/// Shows all verses of a poem with actions
/// ═══════════════════════════════════════════════════════════════

class PoemDetailScreen extends StatefulWidget {
  final int poemId;

  const PoemDetailScreen({
    Key? key,
    required this.poemId,
  }) : super(key: key);

  @override
  State<PoemDetailScreen> createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends State<PoemDetailScreen> {
  final PoemRepository _poemRepository = PoemRepository();
  final VerseRepository _verseRepository = VerseRepository();

  Poem? _poem;
  List<Verse> _verses = [];
  bool _isPoemFavorite = false;
  int _bookmarkCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoemDetails();
  }

  // ───────────────────────────────────────────────────────────────
  // LOAD POEM DETAILS
  // ───────────────────────────────────────────────────────────────

  Future<void> _loadPoemDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final langProvider = context.read<LanguageProvider>();
      final favProvider = context.read<FavoritesProvider>();
      final bookmarkProvider = context.read<BookmarkProvider>();

      // Load poem
      _poem = await _poemRepository.getPoemById(widget.poemId);

      if (_poem == null) {
        setState(() {
          _error = 'Poem not found';
          _isLoading = false;
        });
        return;
      }

      // Load verses
      _verses = await _verseRepository.getVersesByPoemId(
        widget.poemId,
        langProvider.currentLanguage,
      );

      // Check if poem is favorited
      _isPoemFavorite = favProvider.isPoemFavorited(widget.poemId);

      // Get bookmark count
      _bookmarkCount = await bookmarkProvider.getBookmarkCount(widget.poemId);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load poem: $e';
        _isLoading = false;
      });
    }
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _poem?.getTitle(context.read<LanguageProvider>().currentLanguage) ??
              'Poem',
        ),
        actions: [
          // Bookmarked Verses Button
          if (_bookmarkCount > 0)
            IconButton(
              icon: Badge(
                label: Text(_bookmarkCount.toString()),
                child: const Icon(Icons.bookmark),
              ),
              tooltip: AppConstants.titleBookmarks,
              onPressed: _showBookmarkedVerses,
            ),

          // More Options
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite_all',
                child: Row(
                  children: [
                    Icon(
                      _isPoemFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isPoemFavorite ? Colors.red : null,
                    ),
                    const SizedBox(width: 12),
                    Text(_isPoemFavorite ? 'Unfavorite Poem' : 'Favorite Poem'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_all',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 12),
                    Text('Copy All Verses'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_all',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 12),
                    Text('Share Poem'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),

      // Audio Player Bar (if audio available)
      // bottomNavigationBar:
      //     _poem?.hasAudio == true ? AudioPlayerBar(poem: _poem!) : null,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD ERROR WIDGET
  // ───────────────────────────────────────────────────────────────

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPoemDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD CONTENT
  // ───────────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_verses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No verses available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Consumer2<LanguageProvider, FavoritesProvider>(
      builder: (context, langProvider, favProvider, child) {
        return RefreshIndicator(
          onRefresh: _loadPoemDetails,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _verses.length,
            itemBuilder: (context, index) {
              final verse = _verses[index];
              return VerseCard(
                verse: verse,
                verseNumber: index + 1,
                poemId: widget.poemId,
                languageCode: langProvider.currentLanguage,
                fontSize: langProvider.fontSize,
              );
            },
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HANDLE MENU ACTIONS
  // ───────────────────────────────────────────────────────────────

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'favorite_all':
        await _togglePoemFavorite();
        break;
      case 'copy_all':
        await _copyAllVerses();
        break;
      case 'share_all':
        await _sharePoem();
        break;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE POEM FAVORITE
  // ───────────────────────────────────────────────────────────────

  Future<void> _togglePoemFavorite() async {
    final favProvider = context.read<FavoritesProvider>();

    try {
      final isAdded = await favProvider.togglePoemFavorite(widget.poemId);

      setState(() {
        _isPoemFavorite = isAdded;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdded
                  ? AppConstants.msgAddedToFavorites
                  : AppConstants.msgRemovedFromFavorites,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ───────────────────────────────────────────────────────────────
  // COPY ALL VERSES
  // ───────────────────────────────────────────────────────────────

  Future<void> _copyAllVerses() async {
    final langCode = context.read<LanguageProvider>().currentLanguage;
    final buffer = StringBuffer();

    // Add poem title
    buffer.writeln(_poem!.getTitle(langCode));
    buffer.writeln('─' * 30);
    buffer.writeln();

    // Add all verses
    for (var i = 0; i < _verses.length; i++) {
      final verse = _verses[i];
      final content = verse.getContent(langCode);

      if (content != null) {
        buffer.writeln('${i + 1}. ${content.verseText}');
        buffer.writeln();
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppConstants.msgCopiedToClipboard)),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SHARE POEM
  // ───────────────────────────────────────────────────────────────

  Future<void> _sharePoem() async {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality - Coming soon!')),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SHOW BOOKMARKED VERSES
  // ───────────────────────────────────────────────────────────────

  void _showBookmarkedVerses() {
    AppRoutes.navigateTo(
      context,
      AppRoutes.bookmarkedVerses,
      arguments: widget.poemId,
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. SCREEN STRUCTURE:
   - AppBar with title, bookmarks button, menu
   - Scrollable list of verses (VerseCard for each)
   - Bottom audio player (if audio available)

2. DATA LOADING:
   - Loads poem details
   - Loads all verses in selected language
   - Checks favorite status
   - Gets bookmark count

3. VERSE DISPLAY:
   - Each verse in a VerseCard
   - Shows verse number (1, 2, 3...)
   - Language and font size from providers
   - RTL support for Urdu

4. MENU ACTIONS:
   - Favorite/Unfavorite entire poem
   - Copy all verses to clipboard
   - Share poem (placeholder)

5. BOOKMARKS:
   - Shows count badge if bookmarks exist
   - Click to view bookmarked verses
   - Updates when verses are bookmarked

6. AUDIO PLAYER:
   - Shows at bottom if audio available
   - Persistent across app
   - Handled by AudioProvider

7. REFRESH:
   - Pull down to reload
   - Useful if language changed elsewhere

═══════════════════════════════════════════════════════════════
*/