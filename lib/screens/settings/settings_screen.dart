import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// SETTINGS SCREEN
/// Allows users to change language and font size
/// ═══════════════════════════════════════════════════════════════

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.titleSettings),
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return ListView(
            children: [
              // Language Section
              _buildSectionHeader(context, 'Content Language'),
              _buildLanguageTile(context, langProvider),

              const Divider(height: 32),

              // Font Size Section
              _buildSectionHeader(context, 'Font Size'),
              _buildFontSizeTile(context, langProvider),

              const Divider(height: 32),

              // Preview Section
              _buildSectionHeader(context, 'Preview'),
              _buildPreviewCard(context, langProvider),

              const SizedBox(height: 24),

              // Reset Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () => _resetToDefaults(context, langProvider),
                  child: const Text('Reset to Defaults'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
      ),
    );
  }

  Widget _buildLanguageTile(
      BuildContext context, LanguageProvider langProvider) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppTheme.iconActiveColor),
      title: const Text('Select Language'),
      subtitle: Text(langProvider.currentLanguageName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, langProvider),
    );
  }

  Widget _buildFontSizeTile(
      BuildContext context, LanguageProvider langProvider) {
    return Column(
      children: [
        ListTile(
          leading:
              const Icon(Icons.format_size, color: AppTheme.iconActiveColor),
          title: const Text('Adjust Font Size'),
          subtitle:
              Text('Current: ${langProvider.fontSize.toStringAsFixed(0)}'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: AppConstants.minFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Slider(
                  value: langProvider.fontSize,
                  min: AppConstants.minFontSize,
                  max: AppConstants.maxFontSize,
                  divisions:
                      ((AppConstants.maxFontSize - AppConstants.minFontSize) /
                              2)
                          .toInt(),
                  label: langProvider.fontSize.toStringAsFixed(0),
                  onChanged: (value) => langProvider.changeFontSize(value),
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: AppConstants.maxFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(
      BuildContext context, LanguageProvider langProvider) {
    final sampleTexts = {
      'ur': 'مصطفیٰ جان رحمت پہ لاکھوں سلام',
      'en': 'This is how the verse text will appear',
      'bn': 'এই পদটি দেখতে কেমন হবে',
      'hi': 'यह पद कैसा दिखेगा',
    };

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verse Preview:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              sampleTexts[langProvider.currentLanguage] ?? sampleTexts['en']!,
              style: TextStyle(
                fontSize: langProvider.fontSize,
                height: 1.8,
                fontFamily: langProvider.getFontFamily(),
              ),
              textDirection:
                  langProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, LanguageProvider langProvider) {
    String? selectedLanguage = langProvider.currentLanguage;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppConstants.supportedLanguages.map((langCode) {
                  return RadioListTile<String>(
                    title: Text(AppConstants.languageNames[langCode]!),
                    value: langCode,
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedLanguage != null) {
                      langProvider.changeLanguage(selectedLanguage!);
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Language changed successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resetToDefaults(
      BuildContext context, LanguageProvider langProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
            'This will reset language to English and font size to 18.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await langProvider.resetToDefaults();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults')),
        );
      }
    }
  }
}

/* 
═══════════════════════════════════════════════════════════════
FEATURES:
═══════════════════════════════════════════════════════════════

✅ Language Selection - Radio button dialog with 4 languages
✅ Font Size Slider - 14 to 32, visual min/max indicators
✅ Live Preview - Shows sample text in selected language/size
✅ Reset to Defaults - English + 18pt font
✅ Clean UI - Sections with headers, icons, proper spacing

USAGE:
- Tap language → Shows dialog with radio buttons
- Drag slider → Font size changes instantly
- Preview updates in real-time
- Changes persist in database
- Affects all verses app-wide

═══════════════════════════════════════════════════════════════
*/