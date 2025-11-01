/// ═══════════════════════════════════════════════════════════════
/// POEM MODEL
/// Represents a poem (naat) within a book
/// Note: Poem title is the first line of first verse
/// ═══════════════════════════════════════════════════════════════

class Poem {
  final int? id;
  final int bookId;
  final int sortOrder;
  final String firstLetterUrdu; // For A-Z sorting
  final String lastLetterUrdu; // For Z-A sorting
  final String? audioUrl;
  final String? videoUrl;
  final bool isAudioDownloaded;
  final DateTime createdAt;

  // Poem title (first verse's first line) in different languages
  // These are populated when fetching with verses
  String? titleUrdu;
  String? titleEnglish;
  String? titleBangla;
  String? titleHindi;

  Poem({
    this.id,
    required this.bookId,
    this.sortOrder = 0,
    required this.firstLetterUrdu,
    required this.lastLetterUrdu,
    this.audioUrl,
    this.videoUrl,
    this.isAudioDownloaded = false,
    DateTime? createdAt,
    this.titleUrdu,
    this.titleEnglish,
    this.titleBangla,
    this.titleHindi,
  }) : createdAt = createdAt ?? DateTime.now();

  // ───────────────────────────────────────────────────────────────
  // HELPER: Get poem title in specific language
  // ───────────────────────────────────────────────────────────────

  String getTitle(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return titleUrdu ?? titleEnglish ?? 'Untitled';
      case 'en':
        return titleEnglish ?? titleUrdu ?? 'Untitled';
      case 'bn':
        return titleBangla ?? titleEnglish ?? 'Untitled';
      case 'hi':
        return titleHindi ?? titleEnglish ?? 'Untitled';
      default:
        return titleEnglish ?? 'Untitled';
    }
  }

  // ───────────────────────────────────────────────────────────────
  // HELPER: Check if audio/video available
  // ───────────────────────────────────────────────────────────────

  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  // ───────────────────────────────────────────────────────────────
  // CONVERT: From database Map to Poem object
  // ───────────────────────────────────────────────────────────────

  factory Poem.fromMap(Map<String, dynamic> map) {
    return Poem(
      id: map['id'] as int?,
      bookId: map['book_id'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      firstLetterUrdu: map['first_letter_urdu'] as String,
      lastLetterUrdu: map['last_letter_urdu'] as String,
      audioUrl: map['audio_url'] as String?,
      videoUrl: map['video_url'] as String?,
      isAudioDownloaded: (map['is_audio_downloaded'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      titleUrdu: map['title_urdu'] as String?,
      titleEnglish: map['title_english'] as String?,
      titleBangla: map['title_bangla'] as String?,
      titleHindi: map['title_hindi'] as String?,
    );
  }

  // ───────────────────────────────────────────────────────────────
  // CONVERT: Poem object to database Map
  // ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'book_id': bookId,
      'sort_order': sortOrder,
      'first_letter_urdu': firstLetterUrdu,
      'last_letter_urdu': lastLetterUrdu,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'is_audio_downloaded': isAudioDownloaded ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ───────────────────────────────────────────────────────────────
  // COPY WITH: Create a copy with modified fields
  // ───────────────────────────────────────────────────────────────

  Poem copyWith({
    int? id,
    int? bookId,
    int? sortOrder,
    String? firstLetterUrdu,
    String? lastLetterUrdu,
    String? audioUrl,
    String? videoUrl,
    bool? isAudioDownloaded,
    DateTime? createdAt,
    String? titleUrdu,
    String? titleEnglish,
    String? titleBangla,
    String? titleHindi,
  }) {
    return Poem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      sortOrder: sortOrder ?? this.sortOrder,
      firstLetterUrdu: firstLetterUrdu ?? this.firstLetterUrdu,
      lastLetterUrdu: lastLetterUrdu ?? this.lastLetterUrdu,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isAudioDownloaded: isAudioDownloaded ?? this.isAudioDownloaded,
      createdAt: createdAt ?? this.createdAt,
      titleUrdu: titleUrdu ?? this.titleUrdu,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      titleBangla: titleBangla ?? this.titleBangla,
      titleHindi: titleHindi ?? this.titleHindi,
    );
  }

  @override
  String toString() {
    return 'Poem(id: $id, bookId: $bookId, title: ${titleEnglish ?? titleUrdu}, firstLetter: $firstLetterUrdu)';
  }
}

/* 
═══════════════════════════════════════════════════════════════
TEACHER'S EXPLANATION:
═══════════════════════════════════════════════════════════════

1. WHY no separate title in database?
   - Poem title = first line of first verse
   - We extract it when needed from verse_content table
   - title fields here are just cached values for display

2. WHY firstLetterUrdu and lastLetterUrdu?
   - For sorting functionality
   - User clicks "Sort A-Z" → uses firstLetterUrdu
   - User clicks "Sort Z-A" → uses lastLetterUrdu
   - Example: Poem starts with 'م' and ends with 'م'

3. HOW to get poem title?
   When fetching poems from database:
   
   SELECT 
     p.*,
     (SELECT verse_text FROM verse_content vc 
      JOIN verses v ON vc.verse_id = v.id 
      WHERE v.poem_id = p.id AND v.verse_order = 1 
      AND vc.language_code = 'ur' LIMIT 1) as title_urdu
   FROM poems p
   
   Then extract first line from title_urdu

4. WHY isAudioDownloaded?
   - Track if audio file is downloaded locally
   - If false, stream from URL (needs internet)
   - If true, play from local storage (offline)

5. WHAT is sortOrder?
   - Custom ordering within a book
   - Admin can set order: 1, 2, 3...
   - Default 0 means natural order

═══════════════════════════════════════════════════════════════
*/