import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'package:provider/provider.dart';

// We'll create these files next
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/language_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/auth_provider.dart';
import 'services/database/database_helper.dart';

void main() async {
  // STEP 1: Ensure Flutter is initialized
  // This is needed because we're doing async work before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 2: Initialize the database
  // This creates all tables if they don't exist
  await DatabaseHelper.instance.database;

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
        title: AppConstants.appName,
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

3. WHY Consumer<LanguageProvider>?
   - When user changes language, the entire app needs to rebuild
   - Consumer listens to LanguageProvider and rebuilds MaterialApp
   - This changes text direction (RTL for Urdu) and triggers translations

4. WHY Directionality widget?
   - Urdu is written right-to-left
   - This widget changes the entire app's layout direction
   - English, Hindi, Bangla are LTR (left-to-right)

5. WHAT'S NEXT?
   - We'll create the files imported here one by one
   - Start with config/theme.dart (for colors and fonts)
   - Then models (to define our data structure)
   - Then database setup
   - Finally screens

═══════════════════════════════════════════════════════════════
*/