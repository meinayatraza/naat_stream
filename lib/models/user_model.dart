/// ═══════════════════════════════════════════════════════════════
/// USER MODEL
/// Represents a user account (for cloud sync)
/// ═══════════════════════════════════════════════════════════════

class User {
  final String id; // Firebase UID
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime? lastSyncAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    DateTime? createdAt,
    this.lastSyncAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ───────────────────────────────────────────────────────────────
  // HELPER: Check if user data is synced
  // ───────────────────────────────────────────────────────────────

  bool get isSynced => lastSyncAt != null;

  // Get time since last sync
  Duration? get timeSinceLastSync {
    if (lastSyncAt == null) return null;
    return DateTime.now().difference(lastSyncAt!);
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: From database Map to User object
  // ───────────────────────────────────────────────────────────────

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: User object to database Map
  // ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: To Firebase format
  // ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toFirebaseMap() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSyncAt': lastSyncAt?.millisecondsSinceEpoch,
    };
  }

  // ───────────────────────────────────────────────────────────────
  // COPY WITH: Create a copy with modified fields
  // ───────────────────────────────────────────────────────────────

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastSyncAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $displayName)';
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY User model?
   - Optional feature for cloud sync
   - User can use app without creating account
   - When they sign in, their data gets backed up

2. WHAT is Firebase UID?
   - Unique identifier from Firebase Authentication
   - Example: "aBc123XyZ789"
   - Used to link local data to cloud user

3. HOW sync works with User?
   
   Before Sign-in:
   favorites table: user_id = NULL (local only)
   
   After Sign-in:
   favorites table: user_id = "aBc123XyZ789" (synced)
   Firebase: favorites stored in cloud with this user_id

4. WHAT is lastSyncAt?
   - Timestamp of last successful cloud sync
   - Used to show user when data was last backed up
   - Helps with sync conflict resolution

5. WHY toFirebaseMap()?
   - Firebase Firestore uses different format
   - Timestamps as milliseconds, not ISO strings
   - Separates Firebase logic from SQLite logic

═══════════════════════════════════════════════════════════════
*/