import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// ALPHABET SELECTOR
/// Horizontal scrollable Urdu alphabet selector
/// ═══════════════════════════════════════════════════════════════

class AlphabetSelector extends StatelessWidget {
  final String? selectedLetter;
  final ValueChanged<String> onLetterSelected;

  const AlphabetSelector({
    Key? key,
    required this.selectedLetter,
    required this.onLetterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: AppConstants.urduAlphabet.length,
        itemBuilder: (context, index) {
          final letter = AppConstants.urduAlphabet[index];
          final isSelected = selectedLetter == letter;

          return _buildLetterButton(
            context,
            letter,
            isSelected,
          );
        },
      ),
    );
  }

  Widget _buildLetterButton(
    BuildContext context,
    String letter,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onLetterSelected(letter),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 44,
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                fontFamily: 'NafeesNastaleeq',
              ),
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

1. HORIZONTAL LIST:
   - Scrollable left to right
   - Shows all Urdu letters (ا ب پ ت...)
   - 38 letters total

2. LETTER BUTTONS:
   - 44x44 size
   - Rounded corners
   - Selected: Green background, white text
   - Unselected: Gray background, black text

3. INTERACTION:
   - Tap letter to select
   - Triggers onLetterSelected callback
   - Parent screen reloads poems

4. VISUAL FEEDBACK:
   - Selected letter highlighted
   - Ripple effect on tap
   - Clear visual distinction

5. FONT:
   - Uses Nastaleeq font for proper Urdu display
   - Bold weight for visibility

═══════════════════════════════════════════════════════════════
*/