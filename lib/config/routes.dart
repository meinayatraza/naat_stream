import 'package:flutter/material.dart';

// Import screens (we'll create these next)
// import '../screens/home/home_screen.dart';
// import '../screens/book_detail/book_detail_screen.dart';
// import '../screens/poem_list/poem_list_screen.dart';
// import '../screens/poem_detail/poem_detail_screen.dart';
// import '../screens/favorites/favorites_screen.dart';
// import '../screens/user_poems/user_poems_screen.dart';
// import '../screens/user_poems/create_poem_screen.dart';
// import '../screens/auth/login_screen.dart';
// import '../screens/auth/register_screen.dart';
// import '../screens/settings/settings_screen.dart';

/// ═══════════════════════════════════════════════════════════════
/// APP ROUTES
/// Defines all navigation routes in the app
/// ═══════════════════════════════════════════════════════════════

class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  // ───────────────────────────────────────────────────────────────
  // ROUTE NAMES (constants for type safety)
  // ───────────────────────────────────────────────────────────────

  static const String home = '/';
  static const String bookDetail = '/book-detail';
  static const String poemList = '/poem-list';
  static const String poemDetail = '/poem-detail';
  static const String favorites = '/favorites';
  static const String downloads = '/downloads';
  static const String userPoems = '/user-poems';
  static const String createPoem = '/create-poem';
  static const String editPoem = '/edit-poem';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';
  static const String search = '/search';
  static const String bookmarkedVerses = '/bookmarked-verses';

  // ───────────────────────────────────────────────────────────────
  // ROUTE GENERATOR
  // ───────────────────────────────────────────────────────────────

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments;

    switch (settings.name) {
      // ─────────────────────────────────────────────────────────
      // HOME SCREEN (Main screen with books)
      // ─────────────────────────────────────────────────────────
      case home:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Home Screen')),
          ),
          // TODO: Replace with actual HomeScreen when created
          // builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // BOOK DETAIL SCREEN (Poet intro + 4 sorting options)
      // Arguments: bookId (int)
      // ─────────────────────────────────────────────────────────
      case bookDetail:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => Placeholder(
              child: Center(child: Text('Book Detail Screen\nBook ID: $args')),
            ),
            // TODO: Replace with actual BookDetailScreen
            // builder: (_) => BookDetailScreen(bookId: args),
            settings: settings,
          );
        }
        return _errorRoute('Book ID required');

      // ─────────────────────────────────────────────────────────
      // POEM LIST SCREEN (Alphabetically sorted poems)
      // Arguments: Map with bookId, sortType, letter (optional)
      // ─────────────────────────────────────────────────────────
      case poemList:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => Placeholder(
              child: Center(
                child: Text('Poem List Screen\n${args.toString()}'),
              ),
            ),
            // TODO: Replace with actual PoemListScreen
            // builder: (_) => PoemListScreen(
            //   bookId: args['bookId'],
            //   sortType: args['sortType'],
            //   letter: args['letter'],
            // ),
            settings: settings,
          );
        }
        return _errorRoute('Invalid poem list arguments');

      // ─────────────────────────────────────────────────────────
      // POEM DETAIL SCREEN (Full poem with verses)
      // Arguments: poemId (int)
      // ─────────────────────────────────────────────────────────
      case poemDetail:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => Placeholder(
              child: Center(child: Text('Poem Detail Screen\nPoem ID: $args')),
            ),
            // TODO: Replace with actual PoemDetailScreen
            // builder: (_) => PoemDetailScreen(poemId: args),
            settings: settings,
          );
        }
        return _errorRoute('Poem ID required');

      // ─────────────────────────────────────────────────────────
      // FAVORITES SCREEN (All favorite poems and verses)
      // ─────────────────────────────────────────────────────────
      case favorites:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Favorites Screen')),
          ),
          // TODO: Replace with actual FavoritesScreen
          // builder: (_) => const FavoritesScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // DOWNLOADS SCREEN (Downloaded audio files)
      // ─────────────────────────────────────────────────────────
      case downloads:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Downloads Screen')),
          ),
          // TODO: Replace with actual DownloadsScreen
          // builder: (_) => const DownloadsScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // USER POEMS SCREEN (User-created poems list)
      // ─────────────────────────────────────────────────────────
      case userPoems:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('User Poems Screen')),
          ),
          // TODO: Replace with actual UserPoemsScreen
          // builder: (_) => const UserPoemsScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // CREATE POEM SCREEN (Add new user poem)
      // ─────────────────────────────────────────────────────────
      case createPoem:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Create Poem Screen')),
          ),
          // TODO: Replace with actual CreatePoemScreen
          // builder: (_) => const CreatePoemScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // EDIT POEM SCREEN (Edit user poem)
      // Arguments: poemId (int)
      // ─────────────────────────────────────────────────────────
      case editPoem:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => Placeholder(
              child: Center(child: Text('Edit Poem Screen\nPoem ID: $args')),
            ),
            // TODO: Replace with actual EditPoemScreen
            // builder: (_) => EditPoemScreen(poemId: args),
            settings: settings,
          );
        }
        return _errorRoute('Poem ID required');

      // ─────────────────────────────────────────────────────────
      // SETTINGS SCREEN (Language, font size, etc.)
      // ─────────────────────────────────────────────────────────
      case settings:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Settings Screen')),
          ),
          // TODO: Replace with actual SettingsScreen
          // builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // LOGIN SCREEN (Sign in)
      // ─────────────────────────────────────────────────────────
      case login:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Login Screen')),
          ),
          // TODO: Replace with actual LoginScreen
          // builder: (_) => const LoginScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // REGISTER SCREEN (Sign up)
      // ─────────────────────────────────────────────────────────
      case register:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(
            child: Center(child: Text('Register Screen')),
          ),
          // TODO: Replace with actual RegisterScreen
          // builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // SEARCH SCREEN (Global or book search)
      // Arguments: Map with bookId (optional), searchType
      // ─────────────────────────────────────────────────────────
      case search:
        return MaterialPageRoute(
          builder: (_) => Placeholder(
            child: Center(
              child: Text('Search Screen\n${args?.toString() ?? "Global"}'),
            ),
          ),
          // TODO: Replace with actual SearchScreen
          // builder: (_) => SearchScreen(
          //   bookId: args?['bookId'],
          //   searchType: args?['searchType'],
          // ),
          settings: settings,
        );

      // ─────────────────────────────────────────────────────────
      // BOOKMARKED VERSES SCREEN (Selected verses for recitation)
      // Arguments: poemId (int)
      // ─────────────────────────────────────────────────────────
      case bookmarkedVerses:
        if (args is int) {
          return MaterialPageRoute(
            builder: (_) => Placeholder(
              child: Center(
                child: Text('Bookmarked Verses\nPoem ID: $args'),
              ),
            ),
            // TODO: Replace with actual BookmarkedVersesScreen
            // builder: (_) => BookmarkedVersesScreen(poemId: args),
            settings: settings,
          );
        }
        return _errorRoute('Poem ID required');

      // ─────────────────────────────────────────────────────────
      // DEFAULT: Route not found
      // ─────────────────────────────────────────────────────────
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // ERROR ROUTE (when route not found or invalid arguments)
  // ───────────────────────────────────────────────────────────────

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Can't use Navigator.pop here, need context
                  // This will be handled by back button
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Navigate to route with arguments
  // ───────────────────────────────────────────────────────────────

  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Navigate and replace current route
  // ───────────────────────────────────────────────────────────────

  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Navigate and remove all previous routes
  // ───────────────────────────────────────────────────────────────

  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Go back
  // ───────────────────────────────────────────────────────────────

  static void goBack(BuildContext context, {Object? result}) {
    Navigator.pop(context, result);
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is routing?
   - Navigation between screens in Flutter app
   - Like clicking links on a website
   - Each screen has a unique route name
   
   Example:
   Home Screen → User clicks book → Book Detail Screen
   Route: '/' → '/book-detail'

2. WHY use named routes?
   - Type-safe (constants prevent typos)
   - Easy to navigate: Navigator.pushNamed(context, AppRoutes.bookDetail)
   - Centralized navigation logic
   - Easy to add deep linking later

3. HOW to navigate between screens?
   
   // Navigate to book detail
   AppRoutes.navigateTo(
     context,
     AppRoutes.bookDetail,
     arguments: bookId,
   );
   
   // Navigate and replace (can't go back)
   AppRoutes.navigateAndReplace(
     context,
     AppRoutes.home,
   );
   
   // Navigate and clear all previous screens
   AppRoutes.navigateAndRemoveUntil(
     context,
     AppRoutes.home,
   );
   
   // Go back
   AppRoutes.goBack(context);

4. WHAT are arguments?
   - Data passed to next screen
   - Can be any type: int, String, Map, Object
   
   Examples:
   - Poem Detail: needs poemId (int)
   - Poem List: needs bookId, sortType, letter (Map)
   - Search: needs bookId (optional), searchType (Map)

5. HOW arguments work?
   
   // In Book List Screen:
   onTap: () {
     AppRoutes.navigateTo(
       context,
       AppRoutes.poemDetail,
       arguments: poem.id, // Pass poem ID
     );
   }
   
   // In routing:
   case poemDetail:
     if (args is int) {
       return MaterialPageRoute(
         builder: (_) => PoemDetailScreen(poemId: args),
       );
     }

6. WHY Placeholder widgets?
   - Screens not created yet
   - Shows what will be there
   - Replace with actual screens later
   
   Change from:
   builder: (_) => Placeholder(...)
   
   To:
   builder: (_) => PoemDetailScreen(poemId: args)

7. WHAT is _errorRoute?
   - Shows error when:
     * Route not found
     * Invalid arguments
     * Missing required data
   
   Example:
   User tries to open poem detail without poem ID
   → Shows error screen

8. ROUTE EXAMPLES:
   
   Home to Book Detail:
   Navigator.pushNamed(
     context, 
     AppRoutes.bookDetail, 
     arguments: 1,
   );
   
   Book Detail to Poem List (with sorting):
   Navigator.pushNamed(
     context,
     AppRoutes.poemList,
     arguments: {
       'bookId': 1,
       'sortType': 'first_letter',
       'letter': 'م',
     },
   );
   
   Poem List to Poem Detail:
   Navigator.pushNamed(
     context,
     AppRoutes.poemDetail,
     arguments: 5,
   );

9. APP NAVIGATION FLOW:
   
   Home Screen
   ├─ Book Detail Screen
   │  ├─ Poem List Screen
   │  │  └─ Poem Detail Screen
   │  │     └─ Bookmarked Verses Screen
   │  ├─ Favorites Screen
   │  └─ Downloads Screen
   ├─ User Poems Screen
   │  ├─ Create Poem Screen
   │  └─ Edit Poem Screen
   ├─ Search Screen
   ├─ Settings Screen
   └─ Login/Register Screens

10. USAGE IN CODE:
    
    // In any screen:
    import '../../config/routes.dart';
    
    // Navigate
    ElevatedButton(
      child: Text('View Book'),
      onPressed: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.bookDetail,
          arguments: widget.bookId,
        );
      },
    );
    
    // Go back
    AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => AppRoutes.goBack(context),
      ),
    );

═══════════════════════════════════════════════════════════════
*/