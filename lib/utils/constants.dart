class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ───────────────────────────────────────────────────────────────
  // APP INFO
  // ───────────────────────────────────────────────────────────────

  static const String appName = 'Naat Collection';
  static const String appVersion = '1.0.0';

  // ───────────────────────────────────────────────────────────────
  // DATABASE
  // ───────────────────────────────────────────────────────────────

  static const String databaseName = 'naat_collection.db';
  static const int databaseVersion = 1;

  // ───────────────────────────────────────────────────────────────
  // SUPPORTED LANGUAGES
  // ───────────────────────────────────────────────────────────────

  static const String languageUrdu = 'ur';
  static const String languageEnglish = 'en';
  static const String languageBangla = 'bn';
  static const String languageHindi = 'hi';

  static const List<String> supportedLanguages = [
    languageUrdu,
    languageEnglish,
    languageBangla,
    languageHindi,
  ];

  // Language names (for display in UI)
  static const Map<String, String> languageNames = {
    languageUrdu: 'اردو',
    languageEnglish: 'English',
    languageBangla: 'বাংলা',
    languageHindi: 'हिंदी',
  };

  // Default content language
  static const String defaultLanguage = languageEnglish;

  // Languages with book translations (Urdu & English only)
  static const List<String> bookTranslationLanguages = [
    languageUrdu,
    languageEnglish,
  ];

  // ───────────────────────────────────────────────────────────────
  // RTL LANGUAGES
  // ───────────────────────────────────────────────────────────────

  static const List<String> rtlLanguages = [
    languageUrdu,
  ];

  static bool isRTL(String languageCode) {
    return rtlLanguages.contains(languageCode);
  }

  // ───────────────────────────────────────────────────────────────
  // URDU ALPHABET (for sorting)
  // ───────────────────────────────────────────────────────────────

  static const List<String> urduAlphabet = [
    'ا',
    'ب',
    'پ',
    'ت',
    'ٹ',
    'ث',
    'ج',
    'چ',
    'ح',
    'خ',
    'د',
    'ڈ',
    'ذ',
    'ر',
    'ڑ',
    'ز',
    'ژ',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ع',
    'غ',
    'ف',
    'ق',
    'ک',
    'گ',
    'ل',
    'م',
    'ن',
    'و',
    'ہ',
    'ھ',
    'ء',
    'ی',
    'ے',
  ];

  // ───────────────────────────────────────────────────────────────
  // ITEM TYPES (for favorites/bookmarks)
  // ───────────────────────────────────────────────────────────────

  static const String itemTypePoem = 'poem';
  static const String itemTypeVerse = 'verse';

  // ───────────────────────────────────────────────────────────────
  // SETTINGS KEYS
  // ───────────────────────────────────────────────────────────────

  static const String settingKeyLanguage = 'language';
  static const String settingKeyFontSize = 'font_size';

  // Font size range
  static const double minFontSize = 14.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 18.0;

  // ───────────────────────────────────────────────────────────────
  // SORTING OPTIONS
  // ───────────────────────────────────────────────────────────────

  static const String sortByFirstLetter = 'first_letter';
  static const String sortByLastLetter = 'last_letter';

  // ───────────────────────────────────────────────────────────────
  // SEARCH FILTERS
  // ───────────────────────────────────────────────────────────────

  static const String searchFilterText = 'text'; // Search in verse text
  static const String searchFilterTitle = 'title'; // Search in poem title

  // ───────────────────────────────────────────────────────────────
  // USER TYPES
  // ───────────────────────────────────────────────────────────────

  static const String userTypeLocal = 'local'; // Not signed in
  static const String userTypeSynced = 'synced'; // Signed in

  // ───────────────────────────────────────────────────────────────
  // PAGINATION
  // ───────────────────────────────────────────────────────────────

  static const int poemsPerPage = 20;
  static const int versesPerPage = 50;
  static const int searchResultsPerPage = 15;

  // ───────────────────────────────────────────────────────────────
  // AUDIO PLAYER
  // ───────────────────────────────────────────────────────────────

  static const Duration audioSeekDuration = Duration(seconds: 10);
  static const Duration autoHideControlsDuration = Duration(seconds: 5);

  // ───────────────────────────────────────────────────────────────
  // ANIMATION DURATIONS
  // ───────────────────────────────────────────────────────────────

  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // ───────────────────────────────────────────────────────────────
  // UI SPACING
  // ───────────────────────────────────────────────────────────────

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // ───────────────────────────────────────────────────────────────
  // CACHE & STORAGE
  // ───────────────────────────────────────────────────────────────

  static const String audioDownloadFolder = 'audio_downloads';
  static const int maxCachedAudioFiles = 50;

  // ───────────────────────────────────────────────────────────────
  // SYNC SETTINGS
  // ───────────────────────────────────────────────────────────────

  static const Duration syncInterval = Duration(minutes: 30);
  static const int maxRetries = 3;

  // ───────────────────────────────────────────────────────────────
  // VALIDATION
  // ───────────────────────────────────────────────────────────────

  static const int minSearchLength = 2;
  static const int maxVerseLength = 1000;
  static const int maxExplanationLength = 5000;

  // ───────────────────────────────────────────────────────────────
  // UI MESSAGES (ALWAYS IN ENGLISH - App interface language)
  // ───────────────────────────────────────────────────────────────

  // App interface is ALWAYS in English
  // Language selection ONLY affects content (verses, translations, explanations)

  // General Messages
  static const String msgNoDataFound = 'No data found';
  static const String msgSearchHint = 'Search...';
  static const String msgLoading = 'Loading...';
  static const String msgError = 'Error';
  static const String msgSuccess = 'Success';

  // Favorites & Bookmarks
  static const String msgAddedToFavorites = 'Added to favorites';
  static const String msgRemovedFromFavorites = 'Removed from favorites';
  static const String msgAddedToBookmarks = 'Verse bookmarked for recitation';
  static const String msgRemovedFromBookmarks = 'Bookmark removed';

  // Actions
  static const String msgCopiedToClipboard = 'Copied to clipboard';
  static const String msgShared = 'Shared successfully';
  static const String msgDownloaded = 'Downloaded successfully';
  static const String msgDeleted = 'Deleted successfully';

  // Auth
  static const String msgSignInRequired = 'Sign in required';
  static const String msgSignInSuccess = 'Signed in successfully';
  static const String msgSignOutSuccess = 'Signed out successfully';

  // Network
  static const String msgNoInternet = 'No internet connection';
  static const String msgSyncComplete = 'Sync completed';
  static const String msgSyncFailed = 'Sync failed';

  // Menu Items (Drawer)
  static const String menuHome = 'Home';
  static const String menuFavorites = 'Favorites';
  static const String menuDownloads = 'Downloads';
  static const String menuUserPoems = 'My Poems';
  static const String menuSettings = 'Settings';
  static const String menuLanguage = 'Content Language';
  static const String menuFontSize = 'Font Size';
  static const String menuSignIn = 'Sign In';
  static const String menuSignOut = 'Sign Out';
  static const String menuAbout = 'About';

  // Screen Titles
  static const String titleBooks = 'Books';
  static const String titlePoems = 'Poems';
  static const String titleFavorites = 'Favorites';
  static const String titleDownloads = 'Downloads';
  static const String titleBookmarks = 'Bookmarked Verses';
  static const String titleUserPoems = 'My Poems';
  static const String titleCreatePoem = 'Create Poem';
  static const String titleSettings = 'Settings';
  static const String titleSearch = 'Search';

  // Buttons
  static const String btnShare = 'Share';
  static const String btnCopy = 'Copy';
  static const String btnFavorite = 'Favorite';
  static const String btnBookmark = 'Bookmark';
  static const String btnDownload = 'Download';
  static const String btnDelete = 'Delete';
  static const String btnSave = 'Save';
  static const String btnCancel = 'Cancel';
  static const String btnApply = 'Apply';
  static const String btnSignIn = 'Sign In';
  static const String btnSignUp = 'Sign Up';
  static const String btnSignOut = 'Sign Out';

  // Sorting Options
  static const String sortFirstAlphabet = 'Sort A-Z';
  static const String sortLastAlphabet = 'Sort Z-A';
  static const String sortFavorites = 'Favorites';
  static const String sortDownloads = 'Downloads';

  // Search Filters
  static const String filterSearchInText = 'Search in Text';
  static const String filterSearchInTitle = 'Search in Title';

  // Language Names (for display in language selector)
  static const Map<String, String> contentLanguageNames = {
    languageUrdu: 'اردو (Urdu)',
    languageEnglish: 'English',
    languageBangla: 'বাংলা (Bangla)',
    languageHindi: 'हिंदी (Hindi)',
  };
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY use constants?
   - Avoid typos (compiler catches errors)
   - Easy to change values in one place
   - Better code completion in IDE
   - Example: AppConstants.languageUrdu instead of 'ur'

2. WHY urduAlphabet list?
   - Used for the horizontal alphabet selector
   - When user clicks 'م', filter poems starting with 'م'
   - Maintains correct Urdu alphabetical order

3. WHY messages Map?
   - Simple localization without heavy packages
   - Each message has 4 language versions
   - Easy to add more messages later
   
   Usage:
   String msg = AppConstants.getMessage('loading', 'ur');
   // Returns: 'لوڈ ہو رہا ہے...'

4. WHY separate constants for book vs verse languages?
   - Book translations: Urdu/English only
   - Verse content: All 4 languages
   - Makes it clear in code which applies where

5. WHAT'S NEXT?
   We'll create the Language model and provider
   to manage language switching throughout the app.

═══════════════════════════════════════════════════════════════
*/