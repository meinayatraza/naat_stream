import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favourites_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';

/// ═══════════════════════════════════════════════════════════════
/// APP DRAWER
/// Side navigation menu with all app sections
/// ═══════════════════════════════════════════════════════════════

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // User Header
          _buildUserHeader(context),

          // Home
          _buildMenuItem(
            context,
            icon: Icons.home,
            title: AppConstants.menuHome,
            route: AppRoutes.home,
          ),

          const Divider(),

          // Favorites
          _buildFavoritesMenuItem(context),

          // Downloads
          _buildMenuItem(
            context,
            icon: Icons.download,
            title: AppConstants.menuDownloads,
            route: AppRoutes.downloads,
          ),

          // My Poems
          _buildMenuItem(
            context,
            icon: Icons.edit_note,
            title: AppConstants.menuUserPoems,
            route: AppRoutes.userPoems,
          ),

          const Divider(),

          // Settings
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: AppConstants.menuSettings,
            route: AppRoutes.settings,
          ),

          const Divider(),

          // Sign In / Sign Out
          _buildAuthMenuItem(context),

          // About
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: AppConstants.menuAbout,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD USER HEADER
  // ───────────────────────────────────────────────────────────────

  Widget _buildUserHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isSignedIn = authProvider.isSignedIn;
        final displayName = authProvider.displayName ?? 'Guest';
        final email = authProvider.userEmail ?? 'Not signed in';

        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryLightColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              displayName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          accountName: Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            email,
            style: const TextStyle(fontSize: 14),
          ),
          otherAccountsPictures: isSignedIn
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // TODO: Edit profile
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit profile - Coming soon!'),
                        ),
                      );
                    },
                  ),
                ]
              : null,
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD REGULAR MENU ITEM
  // ───────────────────────────────────────────────────────────────

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.iconActiveColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer

        if (onTap != null) {
          onTap();
        } else if (route != null) {
          AppRoutes.navigateTo(context, route);
        }
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD FAVORITES MENU ITEM (with count badge)
  // ───────────────────────────────────────────────────────────────

  Widget _buildFavoritesMenuItem(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, child) {
        final count = favProvider.totalFavoritesCount;

        return ListTile(
          leading: Icon(Icons.favorite, color: AppTheme.iconActiveColor),
          title: Text(AppConstants.menuFavorites),
          trailing: count > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          onTap: () {
            Navigator.pop(context);
            AppRoutes.navigateTo(context, AppRoutes.favorites);
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD AUTH MENU ITEM (Sign In / Sign Out)
  // ───────────────────────────────────────────────────────────────

  Widget _buildAuthMenuItem(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isSignedIn) {
          // Show Sign Out
          return ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              AppConstants.menuSignOut,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);

              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await authProvider.signOut();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppConstants.msgSignOutSuccess),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          );
        } else {
          // Show Sign In
          return ListTile(
            leading: Icon(Icons.login, color: AppTheme.iconActiveColor),
            title: Text(AppConstants.menuSignIn),
            onTap: () {
              Navigator.pop(context);
              AppRoutes.navigateTo(context, AppRoutes.login);
            },
          );
        }
      },
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SHOW ABOUT DIALOG
  // ───────────────────────────────────────────────────────────────

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Icon(
        Icons.menu_book,
        size: 48,
        color: AppTheme.primaryColor,
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A comprehensive Naat collection app with multi-language support.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Features:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Multi-language support (Urdu, English, Bangla, Hindi)'),
        const Text('• Offline-first database'),
        const Text('• Audio playback'),
        const Text('• Favorites & bookmarks'),
        const Text('• User-created poems'),
        const Text('• Cloud sync (optional)'),
      ],
    );
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. DRAWER STRUCTURE:
   - User header (with profile)
   - Main menu items
   - Dividers for sections
   - Auth option (sign in/out)
   - About

2. USER HEADER:
   - Shows user avatar (first letter)
   - Display name
   - Email
   - Edit button if signed in
   - Guest mode if not signed in

3. FAVORITES COUNT:
   - Red badge showing total favorites
   - Updates automatically via provider
   - Only shows if count > 0

4. SIGN IN/OUT:
   - Changes based on auth state
   - Sign out shows confirmation dialog
   - Updates all providers on sign out

5. RESPONSIVE:
   - Closes drawer after navigation
   - Shows feedback messages
   - Handles errors gracefully

6. ABOUT DIALOG:
   - Shows app info
   - Version number
   - Features list

═══════════════════════════════════════════════════════════════
*/