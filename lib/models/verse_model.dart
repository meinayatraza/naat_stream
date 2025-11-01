class Verse {
  final int? id;
  final int poemId;
  final int verseOrder;

  // Content in different languages (from verse_content table)
  VerseContent? urduContent;
  VerseContent? englishContent;
  VerseContent? banglaContent;
  VerseContent? hindiContent;

  Verse({
    this.id,
    required this.poemId,
    required this.verseOrder,
    this.urduContent,
    this.englishContent,
    this.banglaContent,
    this.hindiContent,
  });

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get content in specific language
  // ───────────────────────────────────────────────────────────────

  VerseContent? getContent(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return urduContent;
      case 'en':
        return englishContent;
      case 'bn':
        return banglaContent;
      case 'hi':
        return hindiContent;
      default:
        return englishContent ?? urduContent;
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: From database Map to Verse object
  // ───────────────────────────────────────────────────────────────

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int?,
      poemId: map['poem_id'] as int,
      verseOrder: map['verse_order'] as int,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: Verse object to database Map
  // ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'poem_id': poemId,
      'verse_order': verseOrder,
    };
  }

  // ───────────────────────────────────────────────────────────────
  // COPY WITH: Create a copy with modified fields
  // ───────────────────────────────────────────────────────────────

  Verse copyWith({
    int? id,
    int? poemId,
    int? verseOrder,
    VerseContent? urduContent,
    VerseContent? englishContent,
    VerseContent? banglaContent,
    VerseContent? hindiContent,
  }) {
    return Verse(
      id: id ?? this.id,
      poemId: poemId ?? this.poemId,
      verseOrder: verseOrder ?? this.verseOrder,
      urduContent: urduContent ?? this.urduContent,
      englishContent: englishContent ?? this.englishContent,
      banglaContent: banglaContent ?? this.banglaContent,
      hindiContent: hindiContent ?? this.hindiContent,
    );
  }

  @override
  String toString() {
    return 'Verse(id: $id, poemId: $poemId, order: $verseOrder)';
  }
}

/// ═══════════════════════════════════════════════════════════════
/// VERSE CONTENT MODEL
/// Represents the actual text content of a verse in one language
/// ═══════════════════════════════════════════════════════════════

class VerseContent {
  final int? id;
  final int verseId;
  final String languageCode;
  final String verseText; // The actual verse
  final String? translation; // Translation (optional)
  final String? explanation; // Explanation (optional)

  VerseContent({
    this.id,
    required this.verseId,
    required this.languageCode,
    required this.verseText,
    this.translation,
    this.explanation,
  });

  // ───────────────────────────────────────────────────────────────
  // HELPER: Check if translation/explanation available
  // ───────────────────────────────────────────────────────────────

  bool get hasTranslation => translation != null && translation!.isNotEmpty;
  bool get hasExplanation => explanation != null && explanation!.isNotEmpty;

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get first line of verse (for poem title)
  // ───────────────────────────────────────────────────────────────

  String getFirstLine() {
    final lines = verseText.split('\n');
    return lines.isNotEmpty ? lines[0].trim() : verseText;
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: From database Map to VerseContent object
  // ───────────────────────────────────────────────────────────────

  factory VerseContent.fromMap(Map<String, dynamic> map) {
    return VerseContent(
      id: map['id'] as int?,
      verseId: map['verse_id'] as int,
      languageCode: map['language_code'] as String,
      verseText: map['verse_text'] as String,
      translation: map['translation'] as String?,
      explanation: map['explanation'] as String?,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: VerseContent object to database Map
  // ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'verse_id': verseId,
      'language_code': languageCode,
      'verse_text': verseText,
      'translation': translation,
      'explanation': explanation,
    };
  }

  // ───────────────────────────────────────────────────────────────
  // COPY WITH: Create a copy with modified fields
  // ───────────────────────────────────────────────────────────────

  VerseContent copyWith({
    int? id,
    int? verseId,
    String? languageCode,
    String? verseText,
    String? translation,
    String? explanation,
  }) {
    return VerseContent(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      languageCode: languageCode ?? this.languageCode,
      verseText: verseText ?? this.verseText,
      translation: translation ?? this.translation,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  String toString() {
    return 'VerseContent(lang: $languageCode, text: ${verseText.substring(0, verseText.length > 30 ? 30 : verseText.length)}...)';
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY separate Verse and VerseContent?
   - Verse = structure (which poem, which order)
   - VerseContent = actual text in each language
   - Clean separation of concerns
   
   Example:
   Verse #123 (order: 1, poem: 5)
     ├─ UrduContent: "مصطفیٰ جان رحمت..."
     ├─ EnglishContent: "Mustafa, soul of mercy..."
     ├─ BanglaContent: "মুস্তফা..."
     └─ HindiContent: "मुस्तफा..."

2. WHY verseOrder field?
   - Verses must be displayed in correct order
   - Order 1, 2, 3... within a poem
   - Can't rely on id (might not be sequential)

3. HOW to use in UI?
   
   // Get current language from provider
   String lang = languageProvider.currentLanguage;
   
   // Get content for that language
   VerseContent? content = verse.getContent(lang);
   
   // Display verse
   Text(content?.verseText ?? 'No content');
   
   // Display translation (if available)
   if (content?.hasTranslation == true) {
     Text(content!.translation!);
   }
   
   // Display explanation (if available)
   if (content?.hasExplanation == true) {
     Text(content!.explanation!);
   }

4. WHY getFirstLine() method?
   - Poem title = first line of first verse
   - Some verses might have multiple lines
   - This extracts just the first line
   
   Example:
   verseText = "مصطفیٰ جان رحمت\nشمع بزم ہدایت"
   getFirstLine() returns: "مصطفیٰ جان رحمت"

5. IMPORTANT: Database relationship
   
   verses table:
   ┌────┬─────────┬─────────────┐
   │ id │ poem_id │ verse_order │
   ├────┼─────────┼─────────────┤
   │ 1  │ 10      │ 1           │ ← First verse of poem 10
   │ 2  │ 10      │ 2           │ ← Second verse of poem 10
   └────┴─────────┴─────────────┘
   
   verse_content table:
   ┌────┬──────────┬───────┬────────────────┐
   │ id │ verse_id │ lang  │ verse_text     │
   ├────┼──────────┼───────┼────────────────┤
   │ 1  │ 1        │ ur    │ مصطفیٰ جان...  │
   │ 2  │ 1        │ en    │ Mustafa...     │
   │ 3  │ 1        │ bn    │ মুস্তফা...     │
   │ 4  │ 1        │ hi    │ मुस्तफा...     │
   └────┴──────────┴───────┴────────────────┘

═══════════════════════════════════════════════════════════════
*/