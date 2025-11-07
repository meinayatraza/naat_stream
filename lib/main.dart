import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // ← ADD THIS
import 'dart:io' show Platform;

// Import files
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/language_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/auth_provider.dart';
import 'services/database/database_helper.dart';

void main() async {
  // STEP 1: Ensure Flutter is initialized
  // This is needed because we're doing async work before runApp()
  WidgetsFlutterBinding.ensureInitialized();
  print("✅ Flutter initialized");

  // 👇👇👇 CRITICAL STEP FOR DESKTOP PLATFORMS 👇👇👇
  // Initialize database factory based on platform
  if (!kIsWeb) {
    // Desktop platforms (Windows, macOS, Linux)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Initialize database
    await DatabaseHelper.instance.database;
  } else {
    // Running on the web
    print("⚠️ Running on the web. SQLite is not supported.");
  }
  // STEP 3: Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // STEP 4: Wrap app with MultiProvider
    // This makes all providers available throughout the app
    return MultiProvider(
      providers: [
        // Language Provider - manages current language
        ChangeNotifierProvider(create: (_) => LanguageProvider()),

        // Audio Provider - manages persistent audio player
        ChangeNotifierProvider(create: (_) => AudioProvider()),

        // Favorites Provider - manages favorites (poems & verses)
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),

        // Bookmark Provider - manages verse bookmarks for recitation
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),

        // Auth Provider - manages user authentication
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],

      // STEP 5: Build MaterialApp
      // Note: App UI is always in English and LTR
      // Only content (verses) changes based on language selection
      child: MaterialApp(
        // STEP 6: App Configuration
        title: 'Naat Collection',
        debugShowCheckedModeBanner: false,

        // STEP 7: Theme from theme.dart
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light, // You can make this dynamic later

        // STEP 8: Routing
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY async in main()?
   - We need to initialize the database before the app runs
   - WidgetsFlutterBinding.ensureInitialized() is required for async main()

2. WHY MultiProvider?
   - Provider is a state management solution in Flutter
   - It allows data to be accessed anywhere in the app
   - Changes in providers automatically rebuild listening widgets

3. IMPORTANT: App UI Language
   - The entire app interface is ALWAYS in ENGLISH
   - Menus, buttons, messages = English only
   - Language selection ONLY affects CONTENT:
     * Verse text
     * Translation
     * Explanation
     * Book titles
     * Poet introductions

4. WHY LanguageProvider then?
   - It manages which content language to display (ur/en/bn/hi)
   - When user changes language, only content widgets rebuild
   - App interface (menus, buttons) stays English

5. WHAT'S NEXT?
   - We'll create the files imported here one by one
   - Start with models (to define our data structure)
   - Then database setup
   - Then providers
   - Finally screens

═══════════════════════════════════════════════════════════════
*/