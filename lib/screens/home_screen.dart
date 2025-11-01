import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  // Mock user data — replace with real auth state later
  final String? currentUserFirstName = "Ali"; // Set to null if not signed in

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          currentUserFirstName != null
              ? 'Welcome ${currentUserFirstName}!'
              : 'Welcome Back!',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(title: Text('Home'), onTap: () => Navigator.pop(context)),
            ListTile(
                title: Text('Favorites'), onTap: () => Navigator.pop(context)),
            ListTile(
                title: Text('Settings'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo Placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey[100],
                image: DecorationImage(
                  image: AssetImage(
                      'assets/logo_placeholder.png'), // Replace with actual asset
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  'Naat Collection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey[50],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search poems or books...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Heading: Featured Books
            Text(
              'Featured Books',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            // Horizontal Scrollable Row of Books
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Mock data count
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: _buildBookCard(
                      title: 'Book $index',
                      poet: 'Poet Name $index',
                      imageUrl:
                          'https://via.placeholder.com/150', // Replace with real images
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),

            // Heading: Others
            Text(
              'Others',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            // Another Horizontal Scrollable Row
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4, // Mock data count
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: _buildBookCard(
                      title: 'Other Book $index',
                      poet: 'Poet $index',
                      imageUrl: 'https://via.placeholder.com/150',
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 40), // Bottom padding for scroll
          ],
        ),
      ),
    );
  }

  // Reusable Book Card Widget
  Widget _buildBookCard({
    required String title,
    required String poet,
    required String imageUrl,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 160,
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              poet,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
