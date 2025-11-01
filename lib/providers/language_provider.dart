import 'package:flutter/material.dart';
import '../services/database/database_helper.dart';
import '../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// LANGUAGE PROVIDER
/// Manages content language selection (Urdu, English, Bangla, Hindi)
/// Note: App UI is always English, this only affects content
/// ═══════════════════════════════════════════════════════════════

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = AppConstants.defaultLanguage; // Default: English
  double _fontSize = AppConstants.defaultFontSize; // Default: 18.0
  bool _isInitialized = false;

  // ───────────────────────────────────────────────────────────────
  // GETTERS
  // ───────────────────────────────────────────────────────────────

  String get currentLanguage => _currentLanguage;
  double get fontSize => _fontSize;
  bool get isInitialized => _isInitialized;

  // Check if current language is RTL (only Urdu)
  bool get isRTL => AppConstants.isContentRTL(_currentLanguage);

  // Get language name for display
  String get currentLanguageName =>
      AppConstants.languageNames[_currentLanguage] ?? 'English';

  // ───────────────────────────────────────────────────────────────
  // INITIALIZE: Load saved settings from database
  // ───────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load language from database
      final savedLanguage = await DatabaseHelper.instance.getSetting(
        AppConstants.settingKeyLanguage,
      );

      if (savedLanguage != null &&
          AppConstants.supportedLanguages.contains(savedLanguage)) {
        _currentLanguage = savedLanguage;
      }

      // Load font size from database
      final savedFontSize = await DatabaseHelper.instance.getSetting(
        AppConstants.settingKeyFontSize,
      );

      if (savedFontSize != null) {
        _fontSize =
            double.tryParse(savedFontSize) ?? AppConstants.defaultFontSize;
      }

      _isInitialized = true;
      notifyListeners();

      print(
          '✅ Language Provider initialized: $_currentLanguage, Font: $_fontSize');
    } catch (e) {
      print('Error initializing language provider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CHANGE LANGUAGE: Update content language
  // ───────────────────────────────────────────────────────────────

  Future<void> changeLanguage(String languageCode) async {
    if (!AppConstants.supportedLanguages.contains(languageCode)) {
      print('⚠️ Unsupported language: $languageCode');
      return;
    }

    if (_currentLanguage == languageCode) return; // Already set

    try {
      // Save to database
      await DatabaseHelper.instance.setSetting(
        AppConstants.settingKeyLanguage,
        languageCode,
      );

      // Update state
      _currentLanguage = languageCode;
      notifyListeners();

      print('✅ Language changed to: $languageCode');
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CHANGE FONT SIZE: Update content font size
  // ───────────────────────────────────────────────────────────────

  Future<void> changeFontSize(double size) async {
    if (size < AppConstants.minFontSize || size > AppConstants.maxFontSize) {
      print('⚠️ Font size out of range: $size');
      return;
    }

    if (_fontSize == size) return; // Already set

    try {
      // Save to database
      await DatabaseHelper.instance.setSetting(
        AppConstants.settingKeyFontSize,
        size.toString(),
      );

      // Update state
      _fontSize = size;
      notifyListeners();

      print('✅ Font size changed to: $size');
    } catch (e) {
      print('Error changing font size: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // RESET TO DEFAULTS
  // ───────────────────────────────────────────────────────────────

  Future<void> resetToDefaults() async {
    await changeLanguage(AppConstants.defaultLanguage);
    await changeFontSize(AppConstants.defaultFontSize);
  }

  // ───────────────────────────────────────────────────────────────
  // GET FONT FAMILY FOR CURRENT LANGUAGE
  // ───────────────────────────────────────────────────────────────

  String getFontFamily() {
    switch (_currentLanguage) {
      case 'ur':
        return 'NafeesNastaleeq'; // Urdu font
      case 'en':
      case 'bn':
      case 'hi':
      default:
        return 'Roboto'; // Default font
    }
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is a Provider?
   - It's a class that holds app state
   - When state changes, it notifies all listening widgets
   - Widgets automatically rebuild with new data
   
   Think of it like a radio station:
   - Provider = Radio station broadcasting
   - Widgets = Radios listening
   - When station changes song, all radios hear it

2. WHY use ChangeNotifier?
   - Built-in Flutter class for state management
   - notifyListeners() tells all widgets to rebuild
   - Simple and efficient
   
   Example:
   _currentLanguage = 'ur';
   notifyListeners(); // All widgets using this provider rebuild

3. HOW to use in UI?
   
   // Method 1: Consumer (rebuilds when state changes)
   Consumer<LanguageProvider>(
     builder: (context, langProvider, child) {
       return Text(
         verseContent.verseText,
         style: TextStyle(
           fontFamily: langProvider.getFontFamily(),
           fontSize: langProvider.fontSize,
         ),
       );
     },
   );
   
   // Method 2: Provider.of (access without listening)
   final langCode = Provider.of<LanguageProvider>(
     context, 
     listen: false, // Don't rebuild when changed
   ).currentLanguage;
   
   // Method 3: context.watch (rebuilds when changed)
   final langCode = context.watch<LanguageProvider>().currentLanguage;
   
   // Method 4: context.read (access without listening)
   context.read<LanguageProvider>().changeLanguage('ur');

4. WHY initialize()?
   - Load saved settings from database on app start
   - User's previous language choice is remembered
   - Called once in main.dart or first screen

5. WHAT happens when user changes language?
   
   User clicks "Urdu" in settings
   ↓
   changeLanguage('ur') called
   ↓
   Saves to database (persists across sessions)
   ↓
   Updates _currentLanguage
   ↓
   Calls notifyListeners()
   ↓
   All widgets listening to LanguageProvider rebuild
   ↓
   Verses now show in Urdu!

6. WHY separate currentLanguage and isRTL?
   - currentLanguage: ur, en, bn, hi
   - isRTL: Only true for Urdu
   
   Used for text direction in verses:
   Text(
     verse.verseText,
     textDirection: langProvider.isRTL 
       ? TextDirection.rtl 
       : TextDirection.ltr,
   );

7. IMPORTANT: App UI vs Content Language
   
   App UI (Always English):
   - Menu items: "Favorites", "Settings"
   - Buttons: "Share", "Copy"
   - Messages: "Loading..."
   
   Content Language (User Selectable):
   - Verses, translations, explanations
   - Book titles, poet intros
   - Changes when user changes language

═══════════════════════════════════════════════════════════════
*/