import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/verse_model.dart';
import '../../../providers/favourites_provider.dart';
import '../../../providers/bookmark_provider.dart';
import '../../../config/theme.dart';
import '../../../utils/constants.dart';

class VerseCard extends StatefulWidget {
  final Verse verse;
  final int verseNumber;
  final int poemId;
  final String languageCode;
  final double fontSize;

  const VerseCard({
    Key? key,
    required this.verse,
    required this.verseNumber,
    required this.poemId,
    required this.languageCode,
    required this.fontSize,
  }) : super(key: key);

  @override
  State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  bool _isFavorite = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final favProvider = context.read<FavoritesProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();

    final isFav = favProvider.isVerseFavorited(widget.verse.id!);
    final isBook = await bookmarkProvider.isVerseBookmarked(
      widget.poemId,
      widget.verse.id!,
    );

    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isBookmarked = isBook;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.verse.getContent(widget.languageCode);
    final isRTL = widget.languageCode == 'ur';

    if (content == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse Number
            Text(
              'Verse ${widget.verseNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Verse Text
            Text(
              content.verseText,
              style: TextStyle(
                fontSize: widget.fontSize,
                height: 1.8,
                fontFamily: AppTheme.getFontFamily(widget.languageCode),
              ),
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            ),

            // Translation (if available)
            if (content.hasTranslation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content.translation!,
                  style: TextStyle(
                    fontSize: widget.fontSize - 2,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],

            // Explanation (if available)
            if (content.hasExplanation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.explanation!,
                      style: TextStyle(
                        fontSize: widget.fontSize - 2,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.share,
                  label: AppConstants.btnShare,
                  onPressed: () => _shareVerse(content.verseText),
                ),
                _buildActionButton(
                  icon: Icons.copy,
                  label: AppConstants.btnCopy,
                  onPressed: () => _copyVerse(content.verseText),
                ),
                _buildActionButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  label: AppConstants.btnFavorite,
                  color: _isFavorite ? Colors.red : null,
                  onPressed: _toggleFavorite,
                ),
                _buildActionButton(
                  icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: AppConstants.btnBookmark,
                  color: _isBookmarked ? Colors.blue : null,
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppTheme.iconActiveColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color ?? AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareVerse(String text) async {
    // TODO: Implement share
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share - Coming soon!')),
    );
  }

  Future<void> _copyVerse(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppConstants.msgCopiedToClipboard)),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final favProvider = context.read<FavoritesProvider>();
    final isAdded = await favProvider.toggleVerseFavorite(widget.verse.id!);
    setState(() => _isFavorite = isAdded);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdded
              ? AppConstants.msgAddedToFavorites
              : AppConstants.msgRemovedFromFavorites),
        ),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    final bookmarkProvider = context.read<BookmarkProvider>();
    final isAdded =
        await bookmarkProvider.toggleBookmark(widget.poemId, widget.verse.id!);
    setState(() => _isBookmarked = isAdded);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdded
              ? AppConstants.msgAddedToBookmarks
              : AppConstants.msgRemovedFromBookmarks),
        ),
      );
    }
  }
}
