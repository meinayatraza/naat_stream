class Book {
  final int? id;
  final bool isUserCreated;
  final DateTime createdAt;

  // Translation data (from book_translations table)
  // These are populated when fetching from database
  String? titleUrdu;
  String? titleEnglish;
  String? poetNameUrdu;
  String? poetNameEnglish;
  String? poetIntroUrdu;
  String? poetIntroEnglish;
  String? poetIntroBangla;
  String? poetIntroHindi;

  Book({
    this.id,
    this.isUserCreated = false,
    DateTime? createdAt,
    this.titleUrdu,
    this.titleEnglish,
    this.poetNameUrdu,
    this.poetNameEnglish,
    this.poetIntroUrdu,
    this.poetIntroEnglish,
    this.poetIntroBangla,
    this.poetIntroHindi,
  }) : createdAt = createdAt ?? DateTime.now();

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get title in specific language
  // ───────────────────────────────────────────────────────────────

  String getTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return titleUrdu ?? titleEnglish ?? '';
      case 'en':
      case 'bn':
      case 'hi':
      default:
        return titleEnglish ?? titleUrdu ?? '';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get poet name in specific language
  // ───────────────────────────────────────────────────────────────

  String getPoetName(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return poetNameUrdu ?? poetNameEnglish ?? '';
      case 'en':
      case 'bn':
      case 'hi':
      default:
        return poetNameEnglish ?? poetNameUrdu ?? '';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get poet intro in specific language
  // ───────────────────────────────────────────────────────────────

  String getPoetIntro(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return poetIntroUrdu ?? poetIntroEnglish ?? '';
      case 'en':
        return poetIntroEnglish ?? poetIntroUrdu ?? '';
      case 'bn':
        return poetIntroBangla ?? poetIntroEnglish ?? '';
      case 'hi':
        return poetIntroHindi ?? poetIntroEnglish ?? '';
      default:
        return poetIntroEnglish ?? '';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: From database Map to Book object
  // ───────────────────────────────────────────────────────────────

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      isUserCreated: (map['is_user_created'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      titleUrdu: map['title_urdu'] as String?,
      titleEnglish: map['title_english'] as String?,
      poetNameUrdu: map['poet_name_urdu'] as String?,
      poetNameEnglish: map['poet_name_english'] as String?,
      poetIntroUrdu: map['poet_intro_urdu'] as String?,
      poetIntroEnglish: map['poet_intro_english'] as String?,
      poetIntroBangla: map['poet_intro_bangla'] as String?,
      poetIntroHindi: map['poet_intro_hindi'] as String?,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: Book object to database Map
  // ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'is_user_created': isUserCreated ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ───────────────────────────────────────────────────────────────
  // COPY WITH: Create a copy with modified fields
  // ───────────────────────────────────────────────────────────────

  Book copyWith({
    int? id,
    bool? isUserCreated,
    DateTime? createdAt,
    String? titleUrdu,
    String? titleEnglish,
    String? poetNameUrdu,
    String? poetNameEnglish,
    String? poetIntroUrdu,
    String? poetIntroEnglish,
    String? poetIntroBangla,
    String? poetIntroHindi,
  }) {
    return Book(
      id: id ?? this.id,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      createdAt: createdAt ?? this.createdAt,
      titleUrdu: titleUrdu ?? this.titleUrdu,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      poetNameUrdu: poetNameUrdu ?? this.poetNameUrdu,
      poetNameEnglish: poetNameEnglish ?? this.poetNameEnglish,
      poetIntroUrdu: poetIntroUrdu ?? this.poetIntroUrdu,
      poetIntroEnglish: poetIntroEnglish ?? this.poetIntroEnglish,
      poetIntroBangla: poetIntroBangla ?? this.poetIntroBangla,
      poetIntroHindi: poetIntroHindi ?? this.poetIntroHindi,
    );
  }

  @override
  String toString() {
    return 'Book(id: $id, title: ${titleEnglish ?? titleUrdu}, poet: ${poetNameEnglish ?? poetNameUrdu})';
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY nullable id?
   - When creating new book, it doesn't have id yet
   - Database assigns id automatically (AUTOINCREMENT)
   - After insertion, we get the id back

2. WHY separate fields for each language?
   - Easy to access without database queries
   - Fast performance (no joins needed)
   - Clear what data is available

3. WHAT are the helper methods?
   - getTitle(), getPoetName(), getPoetIntro()
   - They handle language fallback logic
   - Example: If Bangla user requests book title, returns English
     (because book titles only exist in Urdu/English)

4. WHAT is fromMap()?
   - Converts database row (Map) to Book object
   - Used when fetching from SQLite
   - Example: 
     Map row = {'id': 1, 'title_urdu': 'حدائق'...}
     Book book = Book.fromMap(row);

5. WHAT is toMap()?
   - Converts Book object to Map for database insertion
   - Used when saving to SQLite
   - Example:
     Book book = Book(...);
     db.insert('books', book.toMap());

6. WHAT is copyWith()?
   - Creates a copy of Book with some fields changed
   - Useful for updates without modifying original
   - Example:
     Book updated = book.copyWith(titleUrdu: 'نیا عنوان');

═══════════════════════════════════════════════════════════════
*/