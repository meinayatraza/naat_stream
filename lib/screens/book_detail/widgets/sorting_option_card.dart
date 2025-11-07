import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// SORTING OPTION CARD
/// Displays one of the 4 sorting/filter options
/// ═══════════════════════════════════════════════════════════════

class SortingOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const SortingOptionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Card(
      elevation: isDisabled ? 1 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with background circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Subtitle
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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

1. CARD STRUCTURE:
   - Icon with colored circle background
   - Title (e.g., "Sort A-Z")
   - Subtitle (description)
   - Count badge (number of items)

2. COLORS:
   - Each card has unique color
   - A-Z: Green
   - Z-A: Amber
   - Favorites: Red
   - Downloads: Blue

3. DISABLED STATE:
   - When onTap is null (no items)
   - Reduced opacity (50%)
   - Lower elevation
   - No tap response

4. RESPONSIVE:
   - Works in grid layout
   - Adapts to card size
   - Text overflow handling

5. INTERACTION:
   - InkWell ripple effect
   - Navigates when tapped
   - Visual feedback

═══════════════════════════════════════════════════════════════
*/