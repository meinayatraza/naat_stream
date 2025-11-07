import 'package:flutter/material.dart';
import '../../../../models/book_model.dart';
import '../../../../config/theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// BOOK CARD
/// Displays a book in grid format on home screen
/// ═══════════════════════════════════════════════════════════════

class BookCard extends StatelessWidget {
  final Book book;
  final String languageCode;
  final VoidCallback onTap;

  const BookCard({
    Key? key,
    required this.book,
    required this.languageCode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = book.getTitle(languageCode);
    final poetName = book.getPoetName(languageCode);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Cover (top section with gradient)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryLightColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book,
                    size: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),

            // Book Info (bottom section)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Book Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.getFontFamily(languageCode),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Poet Name
                    Text(
                      'By: $poetName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                            fontFamily: AppTheme.getFontFamily(languageCode),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
EXPLANATION:
═══════════════════════════════════════════════════════════════

1. CARD STRUCTURE:
   Top 60%: Book cover (gradient background with icon)
   Bottom 40%: Book info (title + poet name)

2. GRADIENT:
   - Uses theme colors
   - Makes card visually appealing
   - Can be replaced with actual book cover images later

3. TEXT HANDLING:
   - Uses appropriate font for language
   - Ellipsis if text too long
   - Title max 2 lines, poet max 1 line

4. INTERACTION:
   - InkWell for ripple effect
   - onTap callback to parent

5. RESPONSIVE:
   - Works in grid layout
   - Adapts to different screen sizes
   - Maintains aspect ratio

═══════════════════════════════════════════════════════════════
*/