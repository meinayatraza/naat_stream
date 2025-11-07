import 'package:flutter/material.dart';
import '../../../models/poem_model.dart';
import '../../../config/theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// POEM ITEM
/// Displays a single poem in the list
/// ═══════════════════════════════════════════════════════════════

class PoemItem extends StatelessWidget {
  final Poem poem;
  final String languageCode;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const PoemItem({
    Key? key,
    required this.poem,
    required this.languageCode,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = poem.getTitle(languageCode);
    final isRTL = languageCode == 'ur';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Poem Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Poem Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTheme.getFontFamily(languageCode),
                          ),
                      textDirection:
                          isRTL ? TextDirection.rtl : TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Media Icons (if audio/video available)
                    Row(
                      children: [
                        if (poem.hasAudio)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.audiotrack,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (poem.hasVideo)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.videocam,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (!poem.hasAudio && !poem.hasVideo)
                          Text(
                            'Tap to read',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Favorite Button
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onFavoriteToggle,
                tooltip:
                    isFavorite ? 'Remove from favorites' : 'Add to favorites',
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
EXPLANATION:
═══════════════════════════════════════════════════════════════

1. CARD LAYOUT:
   [Icon] [Title + Media icons] [Favorite] [Arrow]
   
2. POEM TITLE:
   - First line of first verse
   - Max 2 lines with ellipsis
   - RTL for Urdu
   - Appropriate font for language

3. MEDIA INDICATORS:
   - 🎵 Audio icon if hasAudio
   - 🎥 Video icon if hasVideo
   - "Tap to read" if no media

4. FAVORITE BUTTON:
   - Filled heart if favorited (red)
   - Empty heart if not favorited (gray)
   - Tap to toggle

5. INTERACTION:
   - Tap card → Navigate to poem detail
   - Tap heart → Toggle favorite
   - Visual feedback (ripple)

6. VISUAL DESIGN:
   - Clean and simple
   - Clear hierarchy
   - Easy to scan list

═══════════════════════════════════════════════════════════════
*/