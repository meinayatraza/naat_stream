import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/poem_repository.dart';
import '../../data/repositories/favourites_repository.dart';
import '../../providers/language_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';
import 'widgets/poet_intro_card.dart';
import 'widgets/sorting_option_card.dart';

/// ═══════════════════════════════════════════════════════════════
/// BOOK DETAIL SCREEN
/// Shows poet introduction and 4 sorting/filter options
/// ═══════════════════════════════════════════════════════════════

class BookDetailScreen extends StatefulWidget {
  final int bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookRepository _bookRepository = BookRepository();
  final PoemRepository _poemRepository = PoemRepository();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();

  Book? _book;
  int _totalPoems = 0;
  int _favoritePoemsCount = 0;
  int _downloadedPoemsCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  // ───────────────────────────────────────────────────────────────
  // LOAD BOOK DETAILS
  // ───────────────────────────────────────────────────────────────

  Future<void> _loadBookDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load book
      _book = await _bookRepository.getBookById(widget.bookId);

      if (_book == null) {
        setState(() {
          _error = 'Book not found';
          _isLoading = false;
        });
        return;
      }

      // Load poem count
      _totalPoems = await _poemRepository.getPoemCountInBook(widget.bookId);

      // Load favorites count in this book
      final favIds = await _favoritesRepository.getFavoritePoemIdsInBook(
        widget.bookId,
        userId: null, // Local user
      );
      _favoritePoemsCount = favIds.length;

      // TODO: Load downloaded count when audio feature is implemented
      _downloadedPoemsCount = 0;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load book: $e';
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
        title: Text(_book?.getTitle(
              context.read<LanguageProvider>().currentLanguage,
            ) ??
            'Book Detail'),
        actions: [
          // Search in this book
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search in this book',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),
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
            onPressed: _loadBookDetails,
            child: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD CONTENT
  // ───────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return RefreshIndicator(
          onRefresh: _loadBookDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Poet Introduction Card
                  PoetIntroCard(
                    book: _book!,
                    languageCode: langProvider.currentLanguage,
                  ),

                  const SizedBox(height: 24),

                  // Section Title
                  Text(
                    'Browse Poems',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // 4 Sorting Options in 2x2 Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      // Sort A-Z
                      SortingOptionCard(
                        icon: Icons.sort_by_alpha,
                        title: AppConstants.sortFirstAlphabet,
                        subtitle: 'Sort by first letter',
                        count: _totalPoems,
                        color: AppTheme.primaryColor,
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.poemList,
                            arguments: {
                              'bookId': widget.bookId,
                              'sortType': AppConstants.sortByFirstLetter,
                            },
                          );
                        },
                      ),

                      // Sort Z-A
                      SortingOptionCard(
                        icon: Icons.format_list_numbered_rtl,
                        title: AppConstants.sortLastAlphabet,
                        subtitle: 'Sort by last letter',
                        count: _totalPoems,
                        color: AppTheme.accentColor,
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.poemList,
                            arguments: {
                              'bookId': widget.bookId,
                              'sortType': AppConstants.sortByLastLetter,
                            },
                          );
                        },
                      ),

                      // Favorites
                      SortingOptionCard(
                        icon: Icons.favorite,
                        title: AppConstants.sortFavorites,
                        subtitle: 'Your favorite poems',
                        count: _favoritePoemsCount,
                        color: Colors.red[700]!,
                        onTap: _favoritePoemsCount > 0
                            ? () {
                                AppRoutes.navigateTo(
                                  context,
                                  AppRoutes.poemList,
                                  arguments: {
                                    'bookId': widget.bookId,
                                    'sortType': 'favorites',
                                  },
                                );
                              }
                            : null,
                      ),

                      // Downloads
                      SortingOptionCard(
                        icon: Icons.download,
                        title: AppConstants.sortDownloads,
                        subtitle: 'Downloaded audio',
                        count: _downloadedPoemsCount,
                        color: Colors.blue[700]!,
                        onTap: _downloadedPoemsCount > 0
                            ? () {
                                AppRoutes.navigateTo(
                                  context,
                                  AppRoutes.downloads,
                                  arguments: {'bookId': widget.bookId},
                                );
                              }
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Quick Stats Card
                  _buildStatsCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD STATS CARD
  // ───────────────────────────────────────────────────────────────

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildStatRow(Icons.article, 'Total Poems', _totalPoems),
            const SizedBox(height: 8),
            _buildStatRow(Icons.favorite, 'Favorites', _favoritePoemsCount),
            const SizedBox(height: 8),
            _buildStatRow(Icons.download, 'Downloads', _downloadedPoemsCount),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD STAT ROW
  // ───────────────────────────────────────────────────────────────

  Widget _buildStatRow(IconData icon, String label, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.iconActiveColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. SCREEN STRUCTURE:
   - Poet Introduction Card (top)
   - 4 Sorting Options (2x2 grid)
   - Statistics Card (bottom)

2. SORTING OPTIONS:
   A-Z: Sort poems by first Urdu letter
   Z-A: Sort poems by last Urdu letter
   Favorites: Show only favorited poems
   Downloads: Show only downloaded poems

3. NAVIGATION:
   Each option navigates to PoemListScreen with:
   - bookId
   - sortType
   - Optional: letter (for alphabet sorting)

4. COUNTS:
   - Total poems: From PoemRepository
   - Favorites: From FavoritesRepository
   - Downloads: Will be implemented with audio

5. DISABLED STATE:
   - Favorites/Downloads cards disabled if count = 0
   - Shown with reduced opacity
   - No navigation when clicked

6. SEARCH:
   - Search button in AppBar
   - Searches only in this book
   - Navigates to SearchScreen with bookId

7. REFRESH:
   - Pull down to reload
   - Recalculates all counts
   - Updates UI

═══════════════════════════════════════════════════════════════
*/
