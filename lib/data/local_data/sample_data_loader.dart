import '../../services/database/database_helper.dart';

/// ═══════════════════════════════════════════════════════════════
/// SAMPLE DATA LOADER
/// Inserts sample books, poems, and verses into database
/// Call this once to populate database with test data
/// ═══════════════════════════════════════════════════════════════

class SampleDataLoader {
  static Future<void> loadSampleData() async {
    final db = await DatabaseHelper.instance.database;

    print('🔄 Loading sample data...');

    // Check if data already exists
    final existingBooks = await db.query('books', limit: 1);
    if (existingBooks.isNotEmpty) {
      print('⚠️ Sample data already exists. Skipping...');
      return;
    }

    await db.transaction((txn) async {
      // ═══════════════════════════════════════════════════════════
      // BOOK 1: Hadaiq-e-Bakhshish
      // ═══════════════════════════════════════════════════════════

      final book1Id = await txn.insert('books', {
        'is_user_created': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Book 1 - Urdu Translation
      await txn.insert('book_translations', {
        'book_id': book1Id,
        'language_code': 'ur',
        'book_title': 'حدائق بخشش',
        'poet_name': 'اعلیٰ حضرت امام احمد رضا خان',
        'poet_intro':
            'امام احمد رضا خان بریلوی رحمۃ اللہ علیہ (1856-1921) اہل سنت کے عظیم عالم دین، مفتی اور شاعر تھے۔ آپ نے اسلامی علوم میں بے مثال کام کیا اور نعت شریف کے میدان میں نمایاں مقام حاصل کیا۔',
      });

      // Book 1 - English Translation
      await txn.insert('book_translations', {
        'book_id': book1Id,
        'language_code': 'en',
        'book_title': 'Hadaiq-e-Bakhshish',
        'poet_name': 'Imam Ahmad Raza Khan',
        'poet_intro':
            'Imam Ahmad Raza Khan Barelvi (1856-1921) was a great Islamic scholar, jurist, and poet. He made unparalleled contributions to Islamic sciences and achieved a prominent position in the field of Naat (poetry in praise of Prophet Muhammad).',
      });

      // Book 1 - Bangla Poet Intro
      await txn.insert('book_translations', {
        'book_id': book1Id,
        'language_code': 'bn',
        'poet_intro':
            'ইমাম আহমাদ রেজা খান বেরেলভী (১৮৫৬-১৯২১) একজন মহান ইসলামিক পণ্ডিত, আইনবিদ এবং কবি ছিলেন। তিনি ইসলামিক বিজ্ঞানে অতুলনীয় অবদান রেখেছিলেন।',
      });

      // Book 1 - Hindi Poet Intro
      await txn.insert('book_translations', {
        'book_id': book1Id,
        'language_code': 'hi',
        'poet_intro':
            'इमाम अहमद रज़ा खान बरेलवी (1856-1921) एक महान इस्लामिक विद्वान, न्यायविद और कवि थे। उन्होंने इस्लामिक विज्ञान में अतुलनीय योगदान दिया।',
      });

      // ═══════════════════════════════════════════════════════════
      // POEM 1: Mustafa Jaan-e-Rahmat
      // ═══════════════════════════════════════════════════════════

      final poem1Id = await txn.insert('poems', {
        'book_id': book1Id,
        'sort_order': 1,
        'first_letter_urdu': 'م',
        'last_letter_urdu': 'م',
        'audio_url':
            'https://example.com/audio/poem1.mp3', // Replace with actual URL
        'video_url': null,
        'is_audio_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Poem 1 - Verse 1
      final verse1Id = await txn.insert('verses', {
        'poem_id': poem1Id,
        'verse_order': 1,
      });

      await txn.insert('verse_content', {
        'verse_id': verse1Id,
        'language_code': 'ur',
        'verse_text':
            'مصطفیٰ جان رحمت پہ لاکھوں سلام\nشمع بزم ہدایت پہ لاکھوں سلام',
        'translation':
            'ملایم ترجمہ: محمد مصطفیٰ جو رحمت کی جان ہیں ان پر لاکھوں سلام، ہدایت کی محفل کے چراغ پر لاکھوں سلام',
        'explanation':
            'اس شعر میں حضور نبی کریم صلی اللہ علیہ وسلم کی عظمت اور رحمت کا ذکر ہے۔ آپ کو رحمت کی جان اور ہدایت کا چراغ قرار دیا گیا ہے۔',
      });

      await txn.insert('verse_content', {
        'verse_id': verse1Id,
        'language_code': 'en',
        'verse_text':
            'Millions of blessings upon Mustafa, the soul of mercy\nMillions of blessings upon the lamp of the assembly of guidance',
        'translation':
            'O Muhammad Mustafa, who is the essence of mercy, millions of salutations upon you. Millions of salutations upon the lamp of the gathering of guidance.',
        'explanation':
            'This verse describes the greatness and mercy of Prophet Muhammad (peace be upon him). He is described as the soul of mercy and the lamp of guidance.',
      });

      await txn.insert('verse_content', {
        'verse_id': verse1Id,
        'language_code': 'bn',
        'verse_text':
            'মুস্তফা করুণার প্রাণ, লক্ষ সালাম\nহিদায়াতের সভার প্রদীপে লক্ষ সালাম',
        'translation':
            'হে মুহাম্মদ মুস্তফা, যিনি করুণার সারাংশ, আপনার প্রতি লক্ষ সালাম।',
        'explanation':
            'এই পদে নবী মুহাম্মদ (সা.) এর মহত্ত্ব এবং করুণা বর্ণনা করা হয়েছে।',
      });

      await txn.insert('verse_content', {
        'verse_id': verse1Id,
        'language_code': 'hi',
        'verse_text':
            'मुस्तफा दया के प्राण पर लाखों सलाम\nहिदायत की महफिल के दीपक पर लाखों सलाम',
        'translation':
            'हे मुहम्मद मुस्तफा, जो दया के सार हैं, आप पर लाखों सलाम।',
        'explanation':
            'इस पद में पैगंबर मुहम्मद (सल्ल.) की महानता और दया का वर्णन है।',
      });

      // Poem 1 - Verse 2
      final verse2Id = await txn.insert('verses', {
        'poem_id': poem1Id,
        'verse_order': 2,
      });

      await txn.insert('verse_content', {
        'verse_id': verse2Id,
        'language_code': 'ur',
        'verse_text':
            'میرے آقا کی آمد پہ قربان جہاں\nمیرے سرکار کی آمد پہ قربان جہاں',
        'translation': null,
        'explanation':
            'اس شعر میں حضور نبی کریم کی آمد پر دنیا کی قربانی کا ذکر ہے۔',
      });

      await txn.insert('verse_content', {
        'verse_id': verse2Id,
        'language_code': 'en',
        'verse_text':
            'The world is sacrificed upon the arrival of my master\nThe world is sacrificed upon the arrival of my leader',
        'translation': null,
        'explanation':
            'This verse expresses the sacrifice of the world upon the arrival of Prophet Muhammad.',
      });

      await txn.insert('verse_content', {
        'verse_id': verse2Id,
        'language_code': 'bn',
        'verse_text':
            'আমার প্রভুর আগমনে বিশ্ব উৎসর্গীকৃত\nআমার নেতার আগমনে বিশ্ব উৎসর্গীকৃত',
        'translation': null,
        'explanation':
            'এই পদে নবীজির আগমনে বিশ্বের আত্মত্যাগের কথা বলা হয়েছে।',
      });

      await txn.insert('verse_content', {
        'verse_id': verse2Id,
        'language_code': 'hi',
        'verse_text':
            'मेरे आका के आगमन पर दुनिया कुर्बान\nमेरे सरकार के आगमन पर दुनिया कुर्बान',
        'translation': null,
        'explanation':
            'इस पद में नबी के आगमन पर दुनिया के बलिदान का उल्लेख है।',
      });

      // ═══════════════════════════════════════════════════════════
      // POEM 2: Another Poem
      // ═══════════════════════════════════════════════════════════

      final poem2Id = await txn.insert('poems', {
        'book_id': book1Id,
        'sort_order': 2,
        'first_letter_urdu': 'ا',
        'last_letter_urdu': 'ن',
        'audio_url': null,
        'video_url': null,
        'is_audio_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      final verse3Id = await txn.insert('verses', {
        'poem_id': poem2Id,
        'verse_order': 1,
      });

      await txn.insert('verse_content', {
        'verse_id': verse3Id,
        'language_code': 'ur',
        'verse_text':
            'اُن کی محبت میں دل و جان فدا کر دیں\nہم نے تو اپنی زندگانی لٹا دی',
        'translation': 'ہم نے ان کی محبت میں اپنا سب کچھ قربان کر دیا',
        'explanation':
            'یہ شعر حضور نبی کریم کی محبت میں اپنی زندگی نچھاور کرنے کا اظہار ہے۔',
      });

      await txn.insert('verse_content', {
        'verse_id': verse3Id,
        'language_code': 'en',
        'verse_text':
            'We sacrificed heart and soul in their love\nWe spent our entire life in devotion',
        'translation': 'We sacrificed everything in their love',
        'explanation':
            'This verse expresses sacrificing one\'s life in the love of Prophet Muhammad.',
      });

      await txn.insert('verse_content', {
        'verse_id': verse3Id,
        'language_code': 'bn',
        'verse_text':
            'তাদের ভালোবাসায় হৃদয় এবং আত্মা উৎসর্গ করেছি\nআমরা আমাদের সমগ্র জীবন ব্যয় করেছি',
        'translation': null,
        'explanation': 'এই পদে নবীজির ভালোবাসায় জীবন উৎসর্গের কথা বলা হয়েছে।',
      });

      await txn.insert('verse_content', {
        'verse_id': verse3Id,
        'language_code': 'hi',
        'verse_text':
            'उनके प्यार में दिल और जान फेंक दिए\nहमने अपनी पूरी जिंदगी लुटा दी',
        'translation': null,
        'explanation':
            'यह पद नबी के प्यार में अपना जीवन न्योछावर करने की अभिव्यक्ति है।',
      });

      // ═══════════════════════════════════════════════════════════
      // BOOK 2: Salam-e-Raza
      // ═══════════════════════════════════════════════════════════

      final book2Id = await txn.insert('books', {
        'is_user_created': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      await txn.insert('book_translations', {
        'book_id': book2Id,
        'language_code': 'ur',
        'book_title': 'سلام رضا',
        'poet_name': 'اعلیٰ حضرت امام احمد رضا خان',
        'poet_intro': 'اعلیٰ حضرت کا یہ مجموعہ نعت شریف کا شاہکار ہے۔',
      });

      await txn.insert('book_translations', {
        'book_id': book2Id,
        'language_code': 'en',
        'book_title': 'Salam-e-Raza',
        'poet_name': 'Imam Ahmad Raza Khan',
        'poet_intro':
            'This collection is a masterpiece of Naat poetry by Imam Ahmad Raza Khan.',
      });

      await txn.insert('book_translations', {
        'book_id': book2Id,
        'language_code': 'bn',
        'poet_intro':
            'এই সংকলনটি ইমাম আহমাদ রেজা খানের নাত কবিতার এক মাস্টারপিস।',
      });

      await txn.insert('book_translations', {
        'book_id': book2Id,
        'language_code': 'hi',
        'poet_intro':
            'यह संग्रह इमाम अहमद रज़ा खान की नात कविता की एक उत्कृष्ट कृति है।',
      });
    });

    print('✅ Sample data loaded successfully!');
    print('📚 2 books, 2 poems, 3 verses created');
  }
}

/* 
═══════════════════════════════════════════════════════════════
HOW TO USE THIS:
═══════════════════════════════════════════════════════════════

1. Call this ONCE in main.dart after database initialization:
   
   await DatabaseHelper.instance.database;
   await SampleDataLoader.loadSampleData(); // Add this line
   
2. Run app - data will be inserted
3. App will skip if data already exists
4. You can now browse books, poems, and verses in UI!

TO ADD MORE DATA:
- Copy the poem/verse structure above
- Change Urdu text, translations, explanations
- Increment verse_order for each verse
- Don't forget all 4 languages (ur, en, bn, hi)

═══════════════════════════════════════════════════════════════
*/

// import 'package:sqflite/sqflite.dart';

// /// ═══════════════════════════════════════════════════════════════
// /// SAMPLE DATA INSERTION
// /// Call this once to add sample books, poems, and verses
// /// ═══════════════════════════════════════════════════════════════

// class SampleBooksData {
//   /// Insert sample book with poems and verses
//   static Future<void> insertSampleData(Database db) async {
//     await db.transaction((txn) async {
//       // ══════════════════════════════════════════════════════════
//       // BOOK 1: Hadaiq-e-Bakhshish
//       // ══════════════════════════════════════════════════════════

//       final book1Id = await txn.insert('books', {
//         'is_user_created': 0,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       // Book translations
//       await txn.insert('book_translations', {
//         'book_id': book1Id,
//         'language_code': 'ur',
//         'book_title': 'حدائق بخشش',
//         'poet_name': 'اعلیٰ حضرت امام احمد رضا خان',
//         'poet_intro':
//             'امام احمد رضا خان بریلوی رحمۃ اللہ علیہ ایک عظیم عالم دین، فقیہ اور شاعر تھے۔ آپ نے اسلام کی خدمت میں اپنی پوری زندگی وقف کر دی۔',
//       });

//       await txn.insert('book_translations', {
//         'book_id': book1Id,
//         'language_code': 'en',
//         'book_title': 'Hadaiq-e-Bakhshish',
//         'poet_name': 'Imam Ahmad Raza Khan',
//         'poet_intro':
//             'Imam Ahmad Raza Khan Barelvi was a great Islamic scholar, jurist and poet. He dedicated his entire life to the service of Islam.',
//       });

//       await txn.insert('book_translations', {
//         'book_id': book1Id,
//         'language_code': 'bn',
//         'book_title': null,
//         'poet_name': null,
//         'poet_intro':
//             'ইমাম আহমাদ রেজা খান বেরেলভি একজন মহান ইসলামী পণ্ডিত, আইনবিদ এবং কবি ছিলেন।',
//       });

//       await txn.insert('book_translations', {
//         'book_id': book1Id,
//         'language_code': 'hi',
//         'book_title': null,
//         'poet_name': null,
//         'poet_intro':
//             'इमाम अहमद रज़ा खान बरेलवी एक महान इस्लामी विद्वान, न्यायविद और कवि थे।',
//       });

//       // ──────────────────────────────────────────────────────────
//       // POEM 1 in Book 1
//       // ──────────────────────────────────────────────────────────

//       final poem1Id = await txn.insert('poems', {
//         'book_id': book1Id,
//         'sort_order': 1,
//         'first_letter_urdu': 'م',
//         'last_letter_urdu': 'م',
//         'audio_url': null,
//         'video_url': null,
//         'is_audio_downloaded': 0,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       // Verse 1 of Poem 1
//       final verse1Id = await txn.insert('verses', {
//         'poem_id': poem1Id,
//         'verse_order': 1,
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse1Id,
//         'language_code': 'ur',
//         'verse_text':
//             'مصطفیٰ جان رحمت پہ لاکھوں سلام\nشمع بزم ہدایت پہ لاکھوں سلام',
//         'translation': 'مصطفیٰ رحمت کی جان پر لاکھوں سلام ہوں',
//         'explanation':
//             'اس شعر میں حضور نبی کریم صلی اللہ علیہ وسلم کی رحمت کا ذکر ہے۔',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse1Id,
//         'language_code': 'en',
//         'verse_text':
//             'Millions of blessings upon Mustafa, the soul of mercy\nMillions of blessings upon the candle of the gathering of guidance',
//         'translation': 'May millions of blessings be upon the Prophet',
//         'explanation':
//             'This verse describes the mercy of Prophet Muhammad (peace be upon him).',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse1Id,
//         'language_code': 'bn',
//         'verse_text':
//             'মুস্তফা রহমতের প্রাণের উপর লক্ষ সালাম\nহেদায়েতের মজলিসের প্রদীপের উপর লক্ষ সালাম',
//         'translation': null,
//         'explanation': 'এই পদটি নবী মুহাম্মদ (সাঃ) এর করুণা বর্ণনা করে।',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse1Id,
//         'language_code': 'hi',
//         'verse_text':
//             'मुस्तफा रहमत की जान पर लाखों सलाम\nहिदायत की महफिल के दीपक पर लाखों सलाम',
//         'translation': null,
//         'explanation':
//             'यह पद पैगंबर मुहम्मद (सल्लल्लाहु अलैहि वसल्लम) की दया का वर्णन करता है।',
//       });

//       // Verse 2 of Poem 1
//       final verse2Id = await txn.insert('verses', {
//         'poem_id': poem1Id,
//         'verse_order': 2,
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse2Id,
//         'language_code': 'ur',
//         'verse_text':
//             'ماہ رُخ پہ جن کے پڑا سایہ تیرا\nسجدہ اُس پہ کرتے ہیں سُورج سلام',
//         'translation': 'جن کے چہرے پر آپ کا سایہ پڑا',
//         'explanation': 'اس شعر میں حضور کی عظمت کا بیان ہے۔',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse2Id,
//         'language_code': 'en',
//         'verse_text':
//             'On whose moon-like face fell your shadow\nThe sun bows in prostration, with salutations',
//         'translation': 'Those blessed by your shade',
//         'explanation': 'This verse describes the greatness of the Prophet.',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse2Id,
//         'language_code': 'bn',
//         'verse_text':
//             'যাদের চাঁদের মতো মুখের উপর আপনার ছায়া পড়েছে\nসূর্য সেজদা করে সালাম দিয়ে',
//         'translation': null,
//         'explanation': 'এই পদটি নবীর মহত্ত্ব বর্ণনা করে।',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse2Id,
//         'language_code': 'hi',
//         'verse_text':
//             'जिनके चाँद जैसे चेहरे पर आपकी छाया पड़ी\nसूरज सजदा करता है सलाम के साथ',
//         'translation': null,
//         'explanation': 'यह पद पैगंबर की महानता का वर्णन करता है।',
//       });

//       // ──────────────────────────────────────────────────────────
//       // POEM 2 in Book 1
//       // ──────────────────────────────────────────────────────────

//       final poem2Id = await txn.insert('poems', {
//         'book_id': book1Id,
//         'sort_order': 2,
//         'first_letter_urdu': 'و',
//         'last_letter_urdu': 'ا',
//         'audio_url': null,
//         'video_url': null,
//         'is_audio_downloaded': 0,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       // Verse 1 of Poem 2
//       final verse3Id = await txn.insert('verses', {
//         'poem_id': poem2Id,
//         'verse_order': 1,
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse3Id,
//         'language_code': 'ur',
//         'verse_text': 'وہ محمد والا جلوہ دکھلا کر\nلوٹ گیا رمضان المبارک',
//         'translation': null,
//         'explanation': 'اس شعر میں ماہ رمضان کی فضیلت کا بیان ہے۔',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse3Id,
//         'language_code': 'en',
//         'verse_text':
//             'Showing the glory of Muhammad\nThe blessed Ramadan has passed',
//         'translation': null,
//         'explanation':
//             'This verse describes the virtues of the month of Ramadan.',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse3Id,
//         'language_code': 'bn',
//         'verse_text': 'মুহাম্মদের মহিমা দেখিয়ে\nমোবারক রমজান চলে গেছে',
//         'translation': null,
//         'explanation': 'এই পদটি রমজান মাসের মর্যাদা বর্ণনা করে।',
//       });

//       await txn.insert('verse_content', {
//         'verse_id': verse3Id,
//         'language_code': 'hi',
//         'verse_text': 'मुहम्मद की महिमा दिखाकर\nमुबारक रमज़ान चला गया',
//         'translation': null,
//         'explanation': 'यह पद रमजान महीने के गुणों का वर्णन करता है।',
//       });

//       print('✅ Sample data inserted successfully!');
//       print('   - 1 Book (Hadaiq-e-Bakhshish)');
//       print('   - 2 Poems');
//       print('   - 3 Verses');
//       print('   - All in 4 languages');
//     });
//   }
// }

// /* 
// ═══════════════════════════════════════════════════════════════
// HOW TO USE THIS:
// ═══════════════════════════════════════════════════════════════

// 1. Call this function ONCE when database is created
// 2. Add this to database_helper.dart after creating tables
// 3. This will insert sample data that you can see in the app

// WHAT'S INCLUDED:
// ✅ 1 Complete Book (in Urdu & English)
// ✅ Poet introduction in all 4 languages
// ✅ 2 Poems with different starting letters
// ✅ 3 Verses total
// ✅ All verses translated in 4 languages
// ✅ Translations and explanations

// You can copy this pattern to add more books!

// ═══════════════════════════════════════════════════════════════
// */