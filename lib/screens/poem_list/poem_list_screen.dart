import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/poem_model.dart';
import '../../data/repositories/poem_repository.dart';
import '../../data/repositories/favourites_repository.dart';
import '../../providers/language_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';
import 'widgets/alphabet_selector.dart';
import 'widgets/poem_item.dart';

/// ═══════════════════════════════════════════════════════════════
/// POEM LIST SCREEN
/// Shows poems sorted by alphabet, or filtered (favorites)
/// ═══════════════════════════════════════════════════════════════

class PoemListScreen extends StatefulWidget {
  final int bookId;
  final String sortType; // 'first_letter', 'last_letter', 'favorites'
  final String? letter; // Optional: specific letter to filter

  const PoemListScreen({
    Key? key,
    required this.bookId,
    required this.sortType,
    this.letter,
  }) : super(key: key);

  @override
  State<PoemListScreen> createState() => _PoemListScreenState();
}

class _PoemListScreenState extends State<PoemListScreen> {
  final PoemRepository _poemRepository = PoemRepository();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();

  List<Poem> _poems = [];
  List<int> _favoritePoemIds = [];
  String? _selectedLetter;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedLetter = widget.letter;
    _loadPoems();
  }

  // ───────────────────────────────────────────────────────────────
  // LOAD POEMS
  // ───────────────────────────────────────────────────────────────

  Future<void> _loadPoems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Poem> poems;

      if (widget.sortType == 'favorites') {
        // Load favorite poems
        final favIds = await _favoritesRepository.getFavoritePoemIdsInBook(
          widget.bookId,
          userId: null,
        );

        _favoritePoemIds = favIds;

        if (favIds.isEmpty) {
          poems = [];
        } else {
          // Get all poems and filter favorites
          final allPoems =
              await _poemRepository.getPoemsByBookId(widget.bookId);
          poems = allPoems.where((p) => favIds.contains(p.id)).toList();
        }
      } else if (_selectedLetter != null) {
        // Load poems by specific letter
        if (widget.sortType == AppConstants.sortByFirstLetter) {
          poems = await _poemRepository.getPoemsByFirstLetter(
            widget.bookId,
            _selectedLetter!,
          );
        } else {
          poems = await _poemRepository.getPoemsByLastLetter(
            widget.bookId,
            _selectedLetter!,
          );
        }
      } else {
        // Load all poems
        poems = await _poemRepository.getPoemsByBookId(widget.bookId);
      }

      // Load favorite poem IDs
      if (widget.sortType != 'favorites') {
        _favoritePoemIds = await _favoritesRepository.getFavoritePoemIdsInBook(
          widget.bookId,
          userId: null,
        );
      }

      setState(() {
        _poems = poems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load poems: $e';
        _isLoading = false;
      });
    }
  }

  // ───────────────────────────────────────────────────────────────
  // ON LETTER SELECTED
  // ───────────────────────────────────────────────────────────────

  void _onLetterSelected(String letter) {
    if (_selectedLetter != letter) {
      setState(() {
        _selectedLetter = letter;
      });
      _loadPoems();
    }
  }

  // ───────────────────────────────────────────────────────────────
  // GET SCREEN TITLE
  // ───────────────────────────────────────────────────────────────

  String _getScreenTitle() {
    switch (widget.sortType) {
      case 'first_letter':
        return AppConstants.sortFirstAlphabet;
      case 'last_letter':
        return AppConstants.sortLastAlphabet;
      case 'favorites':
        return AppConstants.sortFavorites;
      default:
        return 'Poems';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showAlphabetSelector = widget.sortType != 'favorites';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          // Search in this book
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              AppRoutes.navigateTo(
                context,
                AppRoutes.search,
                arguments: {
                  'bookId': widget.bookId,
                  'searchType': 'book',
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Alphabet Selector (for A-Z / Z-A sorting)
          if (showAlphabetSelector)
            AlphabetSelector(
              selectedLetter: _selectedLetter,
              onLetterSelected: _onLetterSelected,
            ),

          // Poems List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _buildPoemsList(),
          ),
        ],
      ),
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
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPoems,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD POEMS LIST
  // ───────────────────────────────────────────────────────────────

  Widget _buildPoemsList() {
    if (_poems.isEmpty) {
      return _buildEmptyState();
    }

    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return RefreshIndicator(
          onRefresh: _loadPoems,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _poems.length,
            itemBuilder: (context, index) {
              final poem = _poems[index];
              final isFavorite = _favoritePoemIds.contains(poem.id);

              return PoemItem(
                poem: poem,
                languageCode: langProvider.currentLanguage,
                isFavorite: isFavorite,
                onTap: () {
                  AppRoutes.navigateTo(
                    context,
                    AppRoutes.poemDetail,
                    arguments: poem.id,
                  );
                },
                onFavoriteToggle: () => _toggleFavorite(poem.id!),
              );
            },
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD EMPTY STATE
  // ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    if (widget.sortType == 'favorites') {
      message = 'No favorite poems in this book yet';
      icon = Icons.favorite_border;
    } else if (_selectedLetter != null) {
      message = 'No poems starting with "$_selectedLetter"';
      icon = Icons.search_off;
    } else {
      message = 'No poems available';
      icon = Icons.library_books_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          if (widget.sortType == 'favorites')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add poems to favorites to see them here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // TOGGLE FAVORITE
  // ───────────────────────────────────────────────────────────────

  Future<void> _toggleFavorite(int poemId) async {
    final favProvider = context.read<FavoritesProvider>();

    try {
      final isAdded = await favProvider.togglePoemFavorite(poemId);

      // Update local list
      setState(() {
        if (isAdded) {
          _favoritePoemIds.add(poemId);
        } else {
          _favoritePoemIds.remove(poemId);

          // If in favorites mode, remove from list
          if (widget.sortType == 'favorites') {
            _poems.removeWhere((p) => p.id == poemId);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdded
                  ? AppConstants.msgAddedToFavorites
                  : AppConstants.msgRemovedFromFavorites,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. SCREEN MODES:
   - A-Z Sorting: Shows alphabet selector, filters by first letter
   - Z-A Sorting: Shows alphabet selector, filters by last letter
   - Favorites: No alphabet selector, shows only favorites

2. ALPHABET SELECTOR:
   - Horizontal scrollable Urdu letters
   - Click letter to filter poems
   - Only shown for A-Z and Z-A modes

3. POEM LOADING:
   Three different loading strategies:
   - By first letter: getPoemsByFirstLetter()
   - By last letter: getPoemsByLastLetter()
   - Favorites: Filter by favorite IDs

4. FAVORITE TOGGLE:
   - Star icon on each poem
   - Click to add/remove favorite
   - In favorites mode: removes from list immediately
   - Shows snackbar feedback

5. NAVIGATION:
   - Click poem → Poem Detail Screen
   - Search icon → Search Screen (book-level)

6. EMPTY STATES:
   - No favorites: Shows helpful message
   - No poems with letter: Shows "No poems starting with..."
   - No poems at all: Shows generic message

═══════════════════════════════════════════════════════════════
*/