import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../services/database/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════
/// AUTH PROVIDER
/// Manages user authentication (sign in/out)
/// Handles cloud sync when user signs in
/// ═══════════════════════════════════════════════════════════════

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  // ───────────────────────────────────────────────────────────────
  // GETTERS
  // ───────────────────────────────────────────────────────────────

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isSignedIn => _currentUser != null;
  bool get isLocal => _currentUser == null;

  String? get userId => _currentUser?.id;
  String? get userEmail => _currentUser?.email;
  String? get displayName => _currentUser?.displayName;

  // ───────────────────────────────────────────────────────────────
  // INITIALIZE: Check if user already signed in
  // ───────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if Firebase user exists
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        // User is signed in, load from local database
        _currentUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
        );

        print('✅ User already signed in: ${_currentUser!.email}');
      } else {
        print('ℹ️ No user signed in (local mode)');
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SIGN IN WITH EMAIL & PASSWORD
  // ───────────────────────────────────────────────────────────────

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign in with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user object
        _currentUser = User(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
          displayName: credential.user!.displayName,
        );

        // Link local data to this user
        await DatabaseHelper.instance.updateLocalDataToUser(_currentUser!.id);

        _isLoading = false;
        notifyListeners();

        print('✅ Sign in successful: ${_currentUser!.email}');
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      print('❌ Sign in error: ${e.code}');
      throw _handleFirebaseError(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print('❌ Sign in error: $e');
      throw 'Sign in failed. Please try again.';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SIGN UP WITH EMAIL & PASSWORD
  // ───────────────────────────────────────────────────────────────

  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create account with Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await credential.user!.updateDisplayName(displayName);
        }

        // Create user object
        _currentUser = User(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
          displayName: displayName ?? credential.user!.displayName,
        );

        // Link local data to this user
        await DatabaseHelper.instance.updateLocalDataToUser(_currentUser!.id);

        _isLoading = false;
        notifyListeners();

        print('✅ Sign up successful: ${_currentUser!.email}');
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      print('❌ Sign up error: ${e.code}');
      throw _handleFirebaseError(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print('❌ Sign up error: $e');
      throw 'Sign up failed. Please try again.';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SIGN OUT
  // ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseAuth.signOut();

      // Reset local data to NULL user_id
      await DatabaseHelper.instance.resetUserIdToNull();

      _currentUser = null;
      _isLoading = false;
      notifyListeners();

      print('✅ Sign out successful');
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print('❌ Sign out error: $e');
      throw 'Sign out failed. Please try again.';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // SEND PASSWORD RESET EMAIL
  // ───────────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.code}');
      throw _handleFirebaseError(e);
    } catch (e) {
      print('❌ Password reset error: $e');
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // UPDATE DISPLAY NAME
  // ───────────────────────────────────────────────────────────────

  Future<void> updateDisplayName(String displayName) async {
    if (_currentUser == null) return;

    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);

      _currentUser = _currentUser!.copyWith(displayName: displayName);
      notifyListeners();

      print('✅ Display name updated: $displayName');
    } catch (e) {
      print('❌ Update display name error: $e');
      throw 'Failed to update name. Please try again.';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // DELETE ACCOUNT
  // ───────────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Delete Firebase account
      await _firebaseAuth.currentUser?.delete();

      // Reset local data
      await DatabaseHelper.instance.resetUserIdToNull();

      _currentUser = null;
      _isLoading = false;
      notifyListeners();

      print('✅ Account deleted');
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      print('❌ Delete account error: $e');
      throw 'Failed to delete account. Please try again.';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // HANDLE FIREBASE ERRORS (convert to user-friendly messages)
  // ───────────────────────────────────────────────────────────────

  String _handleFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHAT is Firebase Authentication?
   - Cloud service for user accounts
   - Handles sign in, sign up, passwords
   - Secure and reliable
   - Free tier available

2. HOW user flow works?
   
   WITHOUT SIGN IN (Local Mode):
   User installs app
   → Uses app normally
   → Favorites/bookmarks stored locally (user_id = NULL)
   → Data on device only
   
   WITH SIGN IN:
   User creates account
   → Signs in with email/password
   → Gets unique user_id from Firebase
   → Local data linked to user_id
   → Can sync to cloud (future feature)
   → Switch devices, data restored

3. HOW to use in Sign In Screen?
   
   class SignInScreen extends StatefulWidget {
     @override
     _SignInScreenState createState() => _SignInScreenState();
   }
   
   class _SignInScreenState extends State<SignInScreen> {
     final _emailController = TextEditingController();
     final _passwordController = TextEditingController();
     
     @override
     Widget build(BuildContext context) {
       return Consumer<AuthProvider>(
         builder: (context, authProvider, child) {
           return Scaffold(
             body: Padding(
               padding: EdgeInsets.all(16),
               child: Column(
                 children: [
                   TextField(
                     controller: _emailController,
                     decoration: InputDecoration(
                       labelText: 'Email',
                     ),
                   ),
                   
                   TextField(
                     controller: _passwordController,
                     obscureText: true,
                     decoration: InputDecoration(
                       labelText: 'Password',
                     ),
                   ),
                   
                   SizedBox(height: 20),
                   
                   ElevatedButton(
                     onPressed: authProvider.isLoading 
                       ? null 
                       : () => _signIn(authProvider),
                     child: authProvider.isLoading
                       ? CircularProgressIndicator()
                       : Text('Sign In'),
                   ),
                   
                   TextButton(
                     onPressed: () => _signUp(authProvider),
                     child: Text('Create Account'),
                   ),
                 ],
               ),
             ),
           );
         },
       );
     }
     
     Future<void> _signIn(AuthProvider authProvider) async {
       try {
         final success = await authProvider.signInWithEmail(
           _emailController.text,
           _passwordController.text,
         );
         
         if (success) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Signed in successfully!')),
           );
           Navigator.pop(context);
         }
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString())),
         );
       }
     }
     
     Future<void> _signUp(AuthProvider authProvider) async {
       try {
         final success = await authProvider.signUpWithEmail(
           _emailController.text,
           _passwordController.text,
         );
         
         if (success) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Account created!')),
           );
           Navigator.pop(context);
         }
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString())),
         );
       }
     }
   }

4. HOW to show user info in drawer?
   
   Consumer<AuthProvider>(
     builder: (context, authProvider, child) {
       return Drawer(
         child: ListView(
           children: [
             // User header
             UserAccountsDrawerHeader(
               accountName: Text(
                 authProvider.isSignedIn 
                   ? authProvider.displayName ?? 'User'
                   : 'Guest',
               ),
               accountEmail: Text(
                 authProvider.isSignedIn
                   ? authProvider.userEmail ?? ''
                   : 'Not signed in',
               ),
               currentAccountPicture: CircleAvatar(
                 child: Text(
                   authProvider.isSignedIn
                     ? authProvider.displayName?[0] ?? 'U'
                     : 'G',
                 ),
               ),
             ),
             
             // Menu items
             ListTile(
               leading: Icon(Icons.home),
               title: Text('Home'),
               onTap: () {},
             ),
             
             Divider(),
             
             // Sign in/out
             if (!authProvider.isSignedIn)
               ListTile(
                 leading: Icon(Icons.login),
                 title: Text('Sign In'),
                 onTap: () {
                   Navigator.pushNamed(context, '/signin');
                 },
               )
             else
               ListTile(
                 leading: Icon(Icons.logout),
                 title: Text('Sign Out'),
                 onTap: () async {
                   await authProvider.signOut();
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Signed out')),
                   );
                 },
               ),
           ],
         ),
       );
     },
   );

5. WHAT happens on sign in?
   
   User enters email/password
   ↓
   signInWithEmail() called
   ↓
   Firebase validates credentials
   ↓
   If valid: Gets user_id (UID)
   ↓
   DatabaseHelper.updateLocalDataToUser(user_id)
   ↓
   All local favorites/bookmarks now have user_id
   ↓
   _currentUser set
   ↓
   notifyListeners()
   ↓
   UI updates (drawer shows user info)

6. WHAT is updateLocalDataToUser?
   
   Before sign in:
   favorites table:
   ┌────┬─────────┬──────┬─────────┐
   │ id │ user_id │ type │ item_id │
   ├────┼─────────┼──────┼─────────┤
   │ 1  │ NULL    │ poem │ 5       │
   │ 2  │ NULL    │ poem │ 12      │
   └────┴─────────┴──────┴─────────┘
   
   After sign in:
   favorites table:
   ┌────┬─────────┬──────┬─────────┐
   │ id │ user_id │ type │ item_id │
   ├────┼─────────┼──────┼─────────┤
   │ 1  │ abc123  │ poem │ 5       │
   │ 2  │ abc123  │ poem │ 12      │
   └────┴─────────┴──────┴─────────┘
   
   Now these favorites belong to user 'abc123'!

7. IMPORTANT: Other providers must update too!
   
   // When user signs in:
   await authProvider.signInWithEmail(...);
   
   // Update other providers:
   await favoritesProvider.updateUserId(authProvider.userId);
   await bookmarkProvider.updateUserId(authProvider.userId);

8. ERROR HANDLING:
   
   Firebase gives error codes like:
   - 'user-not-found'
   - 'wrong-password'
   - 'email-already-in-use'
   
   _handleFirebaseError() converts to friendly messages:
   - "No account found with this email."
   - "Incorrect password."
   - "An account already exists with this email."

9. WHY try-catch everywhere?
   - Firebase operations can fail (network, invalid input)
   - Catch errors, show user-friendly message
   - Prevent app crash

10. FUTURE: Cloud Sync
    Once user is signed in, you can:
    - Upload favorites to Firestore
    - Download favorites on new device
    - Real-time sync across devices
    
    (We'll implement this in future versions)

═══════════════════════════════════════════════════════════════
*/