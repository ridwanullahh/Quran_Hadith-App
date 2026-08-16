import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Model ─────────────────────────────────────────────────────────

class Dua {
  final int id;
  final String arabicText;
  final String englishTranslation;
  final String source;
  final String category;
  final String categoryName;

  const Dua({
    required this.id,
    required this.arabicText,
    required this.englishTranslation,
    required this.source,
    required this.category,
    required this.categoryName,
  });
}

// ── Categories ────────────────────────────────────────────────────

const kDuaCategories = [
  ('morning', 'Morning Adhkar'),
  ('evening', 'Evening Adhkar'),
  ('sleep', 'Sleep Adhkar'),
  ('prayer', 'Prayer (Salah)'),
  ('eating', 'Eating & Drinking'),
  ('travel', 'Travel'),
  ('forgiveness', 'Forgiveness'),
];

// ── Hardcoded Du'a Data (25 du'as) ───────────────────────────────

const List<Dua> kAllDuas = [
  // ── Morning Adhkar ──────────────────────────────────────────
  Dua(
    id: 1,
    arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    englishTranslation:
        'We have reached the morning and at this very time all sovereignty belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah, alone, without partner.',
    source: 'Sahih Muslim 4/2088',
    category: 'morning',
    categoryName: 'Morning Adhkar',
  ),
  Dua(
    id: 2,
    arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    englishTranslation:
        'O Allah, by Your leave we have reached the morning, by Your leave we have reached the evening, by Your leave we live and die, and unto You is our resurrection.',
    source: 'Sunan at-Tirmidhi 3391',
    category: 'morning',
    categoryName: 'Morning Adhkar',
  ),
  Dua(
    id: 3,
    arabicText: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    englishTranslation:
        'O Allah, You are my Lord, none has the right to be worshipped except You. You created me and I am Your servant. I adhere to Your covenant and Your promise as much as I am able. I seek refuge in You from the evil I have done. I acknowledge before You Your blessing upon me, and I acknowledge my sin, so forgive me, for certainly none can forgive sins except You.',
    source: 'Sahih al-Bukhari 6307',
    category: 'morning',
    categoryName: 'Morning Adhkar',
  ),
  Dua(
    id: 4,
    arabicText: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    englishTranslation:
        'How perfect Allah is and I praise Him.',
    source: 'Sahih Muslim 2718',
    category: 'morning',
    categoryName: 'Morning Adhkar',
  ),

  // ── Evening Adhkar ─────────────────────────────────────────
  Dua(
    id: 5,
    arabicText: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    englishTranslation:
        'We have reached the evening and at this very time all sovereignty belongs to Allah. All praise is for Allah. None has the right to be worshipped except Allah, alone, without partner.',
    source: 'Sahih Muslim 4/2088',
    category: 'evening',
    categoryName: 'Evening Adhkar',
  ),
  Dua(
    id: 6,
    arabicText: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
    englishTranslation:
        'O Allah, by Your leave we have reached the evening, by Your leave we have reached the morning, by Your leave we live and die, and unto You is our return.',
    source: 'Sunan at-Tirmidhi 3391',
    category: 'evening',
    categoryName: 'Evening Adhkar',
  ),
  Dua(
    id: 7,
    arabicText: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    englishTranslation:
        'I take refuge in Allah\'s perfect words from the evil He has created.',
    source: 'Sahih Muslim 2727',
    category: 'evening',
    categoryName: 'Evening Adhkar',
  ),

  // ── Sleep Adhkar ─────────────────────────────────────────────
  Dua(
    id: 8,
    arabicText: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    englishTranslation:
        'In Your name O Allah, I live and die.',
    source: 'Sahih al-Bukhari 6954',
    category: 'sleep',
    categoryName: 'Sleep Adhkar',
  ),
  Dua(
    id: 9,
    arabicText: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    englishTranslation:
        'O Allah, protect me from Your punishment on the day You resurrect Your servants.',
    source: 'Sunan Abi Dawud 5046',
    category: 'sleep',
    categoryName: 'Sleep Adhkar',
  ),
  Dua(
    id: 10,
    arabicText: 'سُبْحَانَ اللَّهِ',
    englishTranslation:
        'How perfect Allah is. (Recite 33 times before sleeping)',
    source: 'Sahih al-Bukhari 6325',
    category: 'sleep',
    categoryName: 'Sleep Adhkar',
  ),
  Dua(
    id: 11,
    arabicText: 'اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَىٰ، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ',
    englishTranslation:
        'O Allah, Lord of the seven heavens and Lord of the Magnificent Throne. Our Lord and Lord of everything. Splitter of the seed and the date-stone, Revealer of the Torah, the Gospel, and the Furqan. I seek refuge in You from the evil of everything You are seizing by the forelock.',
    source: 'Sahih Muslim 2723',
    category: 'sleep',
    categoryName: 'Sleep Adhkar',
  ),

  // ── Prayer (Salah) ──────────────────────────────────────────
  Dua(
    id: 12,
    arabicText: 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ',
    englishTranslation:
        'O Allah, distance me from my sins as You have distanced the East from the West.',
    source: 'Sahih al-Bukhari 744',
    category: 'prayer',
    categoryName: 'Prayer (Salah)',
  ),
  Dua(
    id: 13,
    arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    englishTranslation:
        'Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire.',
    source: 'Sahih al-Bukhari 6389',
    category: 'prayer',
    categoryName: 'Prayer (Salah)',
  ),
  Dua(
    id: 14,
    arabicText: 'سُبْحَانَ ذِي الْمُلْكِ وَالْمَلَكُوتِ، سُبْحَانَ ذِي الْعِزَّةِ وَالْعَظَمَةِ وَالْهَيْبَةِ وَالْقُدْرَةِ وَالْكِبْرِيَاءِ وَالْجَبَرُوتِ',
    englishTranslation:
        'How perfect He is, the Possessor of the Kingdom and Dominion. How perfect He is, the Possessor of Majesty, Greatness, Awe, Power, Pride, and Authority.',
    source: 'Sunan an-Nasa\'i 1311',
    category: 'prayer',
    categoryName: 'Prayer (Salah)',
  ),

  // ── Eating & Drinking ────────────────────────────────────────
  Dua(
    id: 15,
    arabicText: 'بِسْمِ اللَّهِ وَبَرَكَةِ اللَّهِ',
    englishTranslation:
        'In the name of Allah and with the blessings of Allah.',
    source: 'Sunan Abi Dawud 3755',
    category: 'eating',
    categoryName: 'Eating & Drinking',
  ),
  Dua(
    id: 16,
    arabicText: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
    englishTranslation:
        'All praise is for Allah who fed us, gave us drink, and made us Muslims.',
    source: 'Sunan Abi Dawud 3850',
    category: 'eating',
    categoryName: 'Eating & Drinking',
  ),
  Dua(
    id: 17,
    arabicText: 'اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَزِدْنَا مِنْهُ',
    englishTranslation:
        'O Allah, bless it for us and provide us with more of it.',
    source: 'Sunan at-Tirmidhi 3455',
    category: 'eating',
    categoryName: 'Eating & Drinking',
  ),

  // ── Travel ──────────────────────────────────────────────────
  Dua(
    id: 18,
    arabicText: 'اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَىٰ، وَمِنَ الْعَمَلِ مَا تَرْضَىٰ',
    englishTranslation:
        'O Allah, we ask You for righteousness and piety on this journey of ours, and deeds that are pleasing to You.',
    source: 'Sahih Muslim 1342',
    category: 'travel',
    categoryName: 'Travel',
  ),
  Dua(
    id: 19,
    arabicText: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ',
    englishTranslation:
        'How perfect is He Who has placed this at our service, and we ourselves would not have been capable of it, and to our Lord is our destiny.',
    source: 'Surah Az-Zukhruf 43:13-14',
    category: 'travel',
    categoryName: 'Travel',
  ),
  Dua(
    id: 20,
    arabicText: 'اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَٰذَا وَاطْوِ عَنَّا بُعْدَهُ',
    englishTranslation:
        'O Allah, make this journey easy for us and shorten its distance.',
    source: 'Sahih Muslim 1342',
    category: 'travel',
    categoryName: 'Travel',
  ),

  // ── Forgiveness ─────────────────────────────────────────────
  Dua(
    id: 21,
    arabicText: 'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
    englishTranslation:
        'My Lord, forgive me and my parents and the believers the Day the account is established.',
    source: 'Surah Ibrahim 14:41',
    category: 'forgiveness',
    categoryName: 'Forgiveness',
  ),
  Dua(
    id: 22,
    arabicText: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
    englishTranslation:
        'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
    source: 'Surah Al-A\'raf 7:23',
    category: 'forgiveness',
    categoryName: 'Forgiveness',
  ),
  Dua(
    id: 23,
    arabicText: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
    englishTranslation:
        'I ask forgiveness of Allah, the Magnificent, besides Whom there is no deity, the Living, the Sustainer, and I repent to Him.',
    source: 'Sunan Abi Dawud 1516',
    category: 'forgiveness',
    categoryName: 'Forgiveness',
  ),
  Dua(
    id: 24,
    arabicText: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
    englishTranslation:
        'O Allah, I seek refuge in You from anxiety and sorrow, and I seek refuge in You from weakness and laziness.',
    source: 'Sahih al-Bukhari 6363',
    category: 'forgiveness',
    categoryName: 'Forgiveness',
  ),
  Dua(
    id: 25,
    arabicText: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    englishTranslation:
        'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
    source: 'Surah Al-Anbiya 21:87',
    category: 'forgiveness',
    categoryName: 'Forgiveness',
  ),
];

// ── State & Notifier ───────────────────────────────────────────────

class DuaState {
  final String searchQuery;
  final String? selectedCategory;
  final Set<int> favoriteIds;

  const DuaState({
    this.searchQuery = '',
    this.selectedCategory,
    this.favoriteIds = const {},
  });

  DuaState copyWith({
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    Set<int>? favoriteIds,
  }) {
    return DuaState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

class DuaNotifier extends StateNotifier<DuaState> {
  DuaNotifier() : super(const DuaState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category, clearCategory: category == null);
  }

  void toggleFavorite(int id) {
    final updated = Set<int>.from(state.favoriteIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = state.copyWith(favoriteIds: updated);
  }

  void clearFilters() {
    state = DuaState(favoriteIds: state.favoriteIds);
  }
}

// ── Providers ──────────────────────────────────────────────────────

final duaProvider = StateNotifierProvider<DuaNotifier, DuaState>((ref) => DuaNotifier());

final filteredDuasProvider = Provider<List<Dua>>((ref) {
  final duaState = ref.watch(duaProvider);
  var duas = kAllDuas;

  if (duaState.selectedCategory != null) {
    duas = duas.where((d) => d.category == duaState.selectedCategory).toList();
  }

  if (duaState.searchQuery.isNotEmpty) {
    final q = duaState.searchQuery.toLowerCase();
    duas = duas.where((d) {
      return d.arabicText.contains(q) ||
          d.englishTranslation.toLowerCase().contains(q) ||
          d.categoryName.toLowerCase().contains(q);
    }).toList();
  }

  return duas;
});

final favoriteDuasProvider = Provider<List<Dua>>((ref) {
  final state = ref.watch(duaProvider);
  return kAllDuas.where((d) => state.favoriteIds.contains(d.id)).toList();
});
