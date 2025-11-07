import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/book_model.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../utils/constants.dart';
import 'widgets/book_card.dart';
import '../../../widgets/common/app_drawer.dart';

/// ═══════════════════════════════════════════════════════════════
/// HOME SCREEN
/// Main screen showing admin books and user poems section
/// ═══════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookRepository _bookRepository = BookRepository();

  List<Book> _adminBooks = [];
  List<Book> _userBooks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // ───────────────────────────────────────────────────────────────
  // LOAD BOOKS (admin and user-created)
  // ───────────────────────────────────────────────────────────────

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all books
      final allBooks = await _bookRepository.getAllBooks();

      // Separate admin and user books
      _adminBooks = allBooks.where((book) => !book.isUserCreated).toList();
      _userBooks = allBooks.where((book) => book.isUserCreated).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load books: $e';
        _isLoading = false;
      });
    }
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Global Search Button
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.search);
            },
          ),
        ],
      ),

      // Side Drawer Menu
      drawer: const AppDrawer(),

      // Main Content
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildContent(),

      // Floating Action Button (Create User Poem)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.createPoem);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Poem'),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD ERROR WIDGET
  // ───────────────────────────────────────────────────────────────

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBooks,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD CONTENT
  // ───────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Books Section
            _buildAdminBooksSection(),

            const SizedBox(height: 24),

            // User Poems Section
            _buildUserPoemsSection(),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD ADMIN BOOKS SECTION
  // ───────────────────────────────────────────────────────────────

  Widget _buildAdminBooksSection() {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.book,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Books',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
            ),

            // Books Grid
            if (_adminBooks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No books available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _adminBooks.length,
                itemBuilder: (context, index) {
                  final book = _adminBooks[index];
                  return BookCard(
                    book: book,
                    languageCode: langProvider.currentLanguage,
                    onTap: () {
                      AppRoutes.navigateTo(
                        context,
                        AppRoutes.bookDetail,
                        arguments: book.id,
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD USER POEMS SECTION
  // ───────────────────────────────────────────────────────────────

  Widget _buildUserPoemsSection() {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppTheme.accentColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'My Poems',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                      ),
                    ],
                  ),
                  if (_userBooks.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        AppRoutes.navigateTo(context, AppRoutes.userPoems);
                      },
                      child: const Text('View All'),
                    ),
                ],
              ),
            ),

            // User Poems List
            if (_userBooks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No poems created yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the button below to create your first poem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _userBooks.length > 3 ? 3 : _userBooks.length,
                itemBuilder: (context, index) {
                  final book = _userBooks[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.accentLightColor,
                        child: Icon(
                          Icons.book,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      title: Text(
                        book.getTitle(langProvider.currentLanguage),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Tap to view',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        AppRoutes.navigateTo(
                          context,
                          AppRoutes.bookDetail,
                          arguments: book.id,
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. SCREEN STRUCTURE:
   AppBar (with search)
   Drawer (side menu)
   Body:
     ├─ Admin Books (grid)
     └─ User Poems (list, max 3 shown)
   FAB (create poem button)

2. DATA LOADING:
   - Loads all books on initState
   - Separates admin and user books
   - Shows loading indicator while fetching
   - Shows error if loading fails
   - Pull to refresh to reload

3. ADMIN BOOKS:
   - Displayed in 2-column grid
   - Uses BookCard widget (we'll create next)
   - Click opens Book Detail screen
   - Shown at top (main content)

4. USER POEMS:
   - Displayed as list
   - Shows max 3 on home screen
   - "View All" button to see complete list
   - Shows empty state if none created
   - Separate section below admin books

5. FLOATING ACTION BUTTON:
   - Always visible
   - Quick access to create poem
   - Opens Create Poem screen

6. REFRESH:
   - Pull down to refresh
   - Reloads all books from database
   - Updates UI automatically

7. NAVIGATION:
   - Book card → Book Detail
   - Search icon → Search Screen
   - Create button → Create Poem Screen
   - View All → User Poems Screen

═══════════════════════════════════════════════════════════════
*/











// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   // Mock user data — replace with real auth state later
//   final String? currentUserFirstName = "Ali"; // Set to null if not signed in

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.menu, color: Colors.black),
//           onPressed: () {
//             Scaffold.of(context).openDrawer();
//           },
//         ),
//         title: Text(
//           currentUserFirstName != null
//               ? 'Welcome ${currentUserFirstName}!'
//               : 'Welcome Back!',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: CircleAvatar(
//               backgroundColor: Colors.grey[200],
//               child: Icon(Icons.person, color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text('Menu', style: TextStyle(color: Colors.white)),
//             ),
//             ListTile(title: Text('Home'), onTap: () => Navigator.pop(context)),
//             ListTile(
//                 title: Text('Favorites'), onTap: () => Navigator.pop(context)),
//             ListTile(
//                 title: Text('Settings'), onTap: () => Navigator.pop(context)),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // App Logo Placeholder
//             Container(
//               height: 120,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//                 color: Colors.grey[100],
//                 image: DecorationImage(
//                   image: AssetImage(
//                       'assets/logo_placeholder.png'), // Replace with actual asset
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   'Naat Collection',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black.withOpacity(0.7),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 24),

//             // Search Bar
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//                 color: Colors.grey[50],
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search poems or books...',
//                   border: InputBorder.none,
//                   prefixIcon: Icon(Icons.search, color: Colors.grey),
//                 ),
//               ),
//             ),
//             SizedBox(height: 32),

//             // Heading: Featured Books
//             Text(
//               'Featured Books',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: 16),

//             // Horizontal Scrollable Row of Books
//             SizedBox(
//               height: 220,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 5, // Mock data count
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: EdgeInsets.only(right: 16),
//                     child: _buildBookCard(
//                       title: 'Book $index',
//                       poet: 'Poet Name $index',
//                       imageUrl:
//                           'https://via.placeholder.com/150', // Replace with real images
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 32),

//             // Heading: Others
//             Text(
//               'Others',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: 16),

//             // Another Horizontal Scrollable Row
//             SizedBox(
//               height: 220,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: 4, // Mock data count
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: EdgeInsets.only(right: 16),
//                     child: _buildBookCard(
//                       title: 'Other Book $index',
//                       poet: 'Poet $index',
//                       imageUrl: 'https://via.placeholder.com/150',
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 40), // Bottom padding for scroll
//           ],
//         ),
//       ),
//     );
//   }

//   // Reusable Book Card Widget
//   Widget _buildBookCard({
//     required String title,
//     required String poet,
//     required String imageUrl,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(
//         width: 160,
//         padding: EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 imageUrl,
//                 height: 100,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SizedBox(height: 12),
//             Text(
//               title,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               poet,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
