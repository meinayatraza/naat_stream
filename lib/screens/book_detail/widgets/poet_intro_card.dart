import 'package:flutter/material.dart';
import '../../../models/book_model.dart';
import '../../../config/theme.dart';

/// ═══════════════════════════════════════════════════════════════
/// POET INTRO CARD
/// Displays book title, poet name, and poet introduction
/// ═══════════════════════════════════════════════════════════════

class PoetIntroCard extends StatefulWidget {
  final Book book;
  final String languageCode;

  const PoetIntroCard({
    Key? key,
    required this.book,
    required this.languageCode,
  }) : super(key: key);

  @override
  State<PoetIntroCard> createState() => _PoetIntroCardState();
}

class _PoetIntroCardState extends State<PoetIntroCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.book.getTitle(widget.languageCode);
    final poetName = widget.book.getPoetName(widget.languageCode);
    final poetIntro = widget.book.getPoetIntro(widget.languageCode);
    final hasIntro = poetIntro.isNotEmpty;
    final isRTL = widget.languageCode == 'ur';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient
          Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTheme.getFontFamily(widget.languageCode),
                      ),
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                ),

                const SizedBox(height: 8),

                // Poet Name
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        poetName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontFamily:
                                  AppTheme.getFontFamily(widget.languageCode),
                            ),
                        textDirection:
                            isRTL ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Poet Introduction
          if (hasIntro)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About the Poet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                        const Spacer(),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Introduction Text
                    AnimatedCrossFade(
                      firstChild: Text(
                        poetIntro.length > 150
                            ? '${poetIntro.substring(0, 150)}...'
                            : poetIntro,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontFamily:
                                  AppTheme.getFontFamily(widget.languageCode),
                            ),
                        textDirection:
                            isRTL ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      secondChild: Text(
                        poetIntro,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontFamily:
                                  AppTheme.getFontFamily(widget.languageCode),
                            ),
                        textDirection:
                            isRTL ? TextDirection.rtl : TextDirection.ltr,
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    if (poetIntro.length > 150)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _isExpanded ? 'Show less' : 'Read more',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No introduction available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
EXPLANATION:
═══════════════════════════════════════════════════════════════

1. CARD STRUCTURE:
   - Header (gradient) with book title & poet name
   - Expandable poet introduction
   - Shows in selected language

2. EXPANSION:
   - Click to expand/collapse
   - Shows 150 chars preview
   - Smooth animation
   - "Read more" / "Show less" text

3. RTL SUPPORT:
   - Detects if language is Urdu
   - Sets text direction accordingly
   - Proper alignment

4. EMPTY STATE:
   - Shows message if no intro available
   - Graceful handling

5. FONT SUPPORT:
   - Uses correct font for language
   - Urdu: Nastaleeq font
   - Others: Roboto

═══════════════════════════════════════════════════════════════
*/