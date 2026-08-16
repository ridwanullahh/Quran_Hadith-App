import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ──────────────────────────────────────────────────────────

class CrossRefEntry {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String quranArabic;
  final String quranEnglish;
  final String hadithText;
  final String hadithSource;
  final String topic;

  const CrossRefEntry({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.quranArabic,
    required this.quranEnglish,
    required this.hadithText,
    required this.hadithSource,
    required this.topic,
  });

  String get quranRef => '$surahNumber:$ayahNumber';
}

// ════════════════════════════════════════════════════════════════════
// Hardcoded cross-references – 24 entries
// ════════════════════════════════════════════════════════════════════

final List<CrossRefEntry> kCrossReferences = [
  CrossRefEntry(
    id: 1,
    surahNumber: 2, ayahNumber: 255,
    quranArabic: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ',
    quranEnglish: 'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "Whoever recites Ayat al-Kursi at the end of every obligatory prayer, nothing will stand between him and entering Paradise except death."',
    hadithSource: 'Sunan an-Nasa\'i 9928',
    topic: 'Tawhid',
  ),
  CrossRefEntry(
    id: 2,
    surahNumber: 2, ayahNumber: 43,
    quranArabic: 'وَأَقِيمُوا۟ ٱلصَّلَوٰةَ وَءَاتُوا۟ ٱلزَّكَوٰةَ',
    quranEnglish: 'And establish prayer and give zakah.',
    hadithText: 'Ibn Umar (RA) reported: The Messenger of Allah (SAW) said, "Islam is built on five pillars: testifying that there is no god but Allah and Muhammad is His Messenger, establishing prayer, paying zakah, performing Hajj, and fasting Ramadan."',
    hadithSource: 'Sahih al-Bukhari 8',
    topic: 'Salah',
  ),
  CrossRefEntry(
    id: 3,
    surahNumber: 2, ayahNumber: 183,
    quranArabic: 'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ كُتِبَ عَلَيْكُمُ ٱلصِّيَامُ',
    quranEnglish: 'O you who have believed, fasting is prescribed for you as it was prescribed for those before you.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "Whoever fasts Ramadan with faith and seeking reward, his previous sins will be forgiven."',
    hadithSource: 'Sahih al-Bukhari 38',
    topic: 'Fasting',
  ),
  CrossRefEntry(
    id: 4,
    surahNumber: 9, ayahNumber: 103,
    quranArabic: 'خُذْ مِنْ أَمْوَٰلِهِمْ صَدَقَةً تُطَهِّرُهُمْ وَتُزَكِّيهِم بِهَا',
    quranEnglish: 'Take from their wealth charity to purify and cleanse them.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "Wealth is not diminished by giving charity."',
    hadithSource: 'Sahih Muslim 2588',
    topic: 'Zakat',
  ),
  CrossRefEntry(
    id: 5,
    surahNumber: 3, ayahNumber: 97,
    quranArabic: 'وَلِلَّهِ عَلَى ٱلنَّاسِ حِجُّ ٱلْبَيْتِ مَنِ ٱسْتَطَاعَ إِلَيْهِ سَبِيلًا',
    quranEnglish: 'And Hajj to the House is a duty that mankind owes to Allah, for those who can find a way.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) was asked, "Which deed is best?" He said, "Faith in Allah and His Messenger." "Then what?" He said, "Jihad in the way of Allah." "Then what?" He said, "An accepted Hajj."',
    hadithSource: 'Sahih al-Bukhari 26',
    topic: 'Hajj',
  ),
  CrossRefEntry(
    id: 6,
    surahNumber: 29, ayahNumber: 45,
    quranArabic: 'إِنَّ ٱلصَّلَوٰةَ تَنْهَىٰ عَنِ ٱلْفَحْشَآءِ وَٱلْمُنكَرِ',
    quranEnglish: 'Indeed, prayer prohibits immorality and wrongdoing.',
    hadithText: 'Uthman bin Affan (RA) reported: The Messenger of Allah (SAW) said, "If a person had a stream flowing at his door and he washed from it five times a day, would any dirt remain on him?" They said, "No dirt would remain." He said, "That is the five prayers through which Allah wipes out sins."',
    hadithSource: 'Sahih al-Bukhari 528',
    topic: 'Salah',
  ),
  CrossRefEntry(
    id: 7,
    surahNumber: 2, ayahNumber: 152,
    quranArabic: 'فَٱذْكُرُونِىٓ أَذْكُرْكُمْ',
    quranEnglish: 'Remember Me and I will remember you.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "Allah the Exalted says: I am as My servant thinks of Me. So let him think of Me as he wishes... If he draws near to Me a handspan, I draw near to him an arm\'s length."',
    hadithSource: 'Sahih al-Bukhari 7405; Sahih Muslim 2675',
    topic: 'Gratitude',
  ),
  CrossRefEntry(
    id: 8,
    surahNumber: 7, ayahNumber: 156,
    quranArabic: 'وَرَحْمَتِى وَسِعَتْ كُلَّ شَىْءٍ',
    quranEnglish: 'My mercy encompasses all things.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "When Allah created the creation, He wrote in a book which is with Him above the Throne: My mercy prevails over My wrath."',
    hadithSource: 'Sahih al-Bukhari 3194; Sahih Muslim 2751',
    topic: 'Mercy',
  ),
  CrossRefEntry(
    id: 9,
    surahNumber: 4, ayahNumber: 135,
    quranArabic: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ كُونُوا۟ قَوَّٰمِينَ بِٱلْقِسْطِ',
    quranEnglish: 'O you who believe, be persistently standing firm in justice.',
    hadithText: 'An-Nu\'man bin Bashir (RA) reported: The Messenger of Allah (SAW) said, "The parable of the believers in their affection, mercy, and compassion for each other is that of a body. When any limb aches, the whole body responds with sleeplessness and fever."',
    hadithSource: 'Sahih al-Bukhari 6011; Sahih Muslim 2586',
    topic: 'Justice',
  ),
  CrossRefEntry(
    id: 10,
    surahNumber: 2, ayahNumber: 155,
    quranArabic: 'وَلَنَبْلُوَنَّكُم بِشَىْءٍ مِّنَ ٱلْخَوْفِ وَٱلْجُوعِ',
    quranEnglish: 'We will surely test you with something of fear and hunger.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "The strong believer is better and more beloved to Allah than the weak believer, while there is good in both. Be eager for what benefits you, seek help from Allah, and do not be frustrated. If something befalls you, do not say: \"If only I had done such and such.\" Rather say: \"Allah has decreed and what He wills, He does.\""',
    hadithSource: 'Sahih Muslim 2664',
    topic: 'Patience',
  ),
  CrossRefEntry(
    id: 11,
    surahNumber: 33, ayahNumber: 21,
    quranArabic: 'لَّقَدْ كَانَ لَكُمْ فِى رَسُولِ ٱللَّهِ أُسْوَةٌ حَسَنَةٌ',
    quranEnglish: 'There has certainly been for you in the Messenger of Allah an excellent pattern.',
    hadithText: 'Anas (RA) reported: The Messenger of Allah (SAW) said, "None of you truly believes until I am more beloved to him than his father, his child, and all of mankind."',
    hadithSource: 'Sahih al-Bukhari 15',
    topic: 'Prophets',
  ),
  CrossRefEntry(
    id: 12,
    surahNumber: 39, ayahNumber: 53,
    quranArabic: 'لَا تَقْنَطُوا۟ مِن رَّحْمَةِ ٱللَّهِ',
    quranEnglish: 'Do not despair of the mercy of Allah.',
    hadithText: 'Abu Sa\'id al-Khudri (RA) reported: The Prophet of Allah (SAW) said, "Among those who came before you there was a man who killed ninety-nine people. He asked who was the most knowledgeable person on earth and was directed to a monk. He killed him too, completing one hundred. Then he asked who was the most knowledgeable person and was told about a scholar. He went to him and said he had killed one hundred people — was there any repentance for him? The scholar said yes... He turned toward Allah and He accepted his repentance."',
    hadithSource: 'Sahih al-Bukhari 3470; Sahih Muslim 2766',
    topic: 'Mercy',
  ),
  CrossRefEntry(
    id: 13,
    surahNumber: 17, ayahNumber: 23,
    quranArabic: 'وَبِٱلْوَٰلِدَيْنِ إِحْسَـٰنًا',
    quranEnglish: 'And be good to parents.',
    hadithText: 'Abdullah bin Mas\'ud (RA) reported: I asked the Prophet (SAW), "Which deed is most beloved to Allah?" He said, "Prayer at its proper time." I asked, "Then what?" He said, "Being good to parents."',
    hadithSource: 'Sahih al-Bukhari 527',
    topic: 'Family',
  ),
  CrossRefEntry(
    id: 14,
    surahNumber: 2, ayahNumber: 261,
    quranArabic: 'مَّثَلُ ٱلَّذِينَ يُنفِقُونَ أَمْوَٰلَهُمْ فِى سَبِيلِ ٱللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ',
    quranEnglish: 'The example of those who spend in the way of Allah is like a seed that produces seven ears.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "Every day two angels descend, and one of them says: O Allah, compensate the one who spends. The other says: O Allah, bring destruction to the one who withholds."',
    hadithSource: 'Sahih al-Bukhari 1442',
    topic: 'Charity',
  ),
  CrossRefEntry(
    id: 15,
    surahNumber: 96, ayahNumber: 1,
    quranArabic: 'ٱقْرَأْ بِٱسْمِ رَبِّكَ ٱلَّذِى خَلَقَ',
    quranEnglish: 'Read in the name of your Lord who created.',
    hadithText: 'Aisha (RA) reported: The beginning of revelation to the Messenger of Allah (SAW) was true dreams during sleep. He never saw a dream except that it came true like bright dawn. Then solitude was made dear to him, and he used to seclude himself in the cave of Hira, worshipping there for many nights before returning to his family. Then the Truth came to him while he was in the cave of Hira. The angel came to him and said, "Read!" He said, "I cannot read."',
    hadithSource: 'Sahih al-Bukhari 3',
    topic: 'Knowledge',
  ),
  CrossRefEntry(
    id: 16,
    surahNumber: 112, ayahNumber: 1,
    quranArabic: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
    quranEnglish: 'Say: He is Allah, the One.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "Say: He is Allah, the One — it is equivalent to one-third of the Quran."',
    hadithSource: 'Sahih al-Bukhari 5015',
    topic: 'Tawhid',
  ),
  CrossRefEntry(
    id: 17,
    surahNumber: 30, ayahNumber: 21,
    quranArabic: 'وَمِنْ ءَayَـٰتِهِۦٓ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَٰجًا',
    quranEnglish: 'And among His signs is that He created for you mates from among yourselves.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "A woman is married for four things: her wealth, her lineage, her beauty, and her religion. So marry the religious woman, you will be blessed."',
    hadithSource: 'Sahih al-Bukhari 5090',
    topic: 'Family',
  ),
  CrossRefEntry(
    id: 18,
    surahNumber: 14, ayahNumber: 7,
    quranArabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    quranEnglish: 'If you are grateful, I will surely give you more.',
    hadithText: 'Suhaib (RA) reported: The Messenger of Allah (SAW) said, "How wonderful is the affair of the believer, for his affair is all good. If something good happens to him, he is grateful for it and that is good for him. If something bad happens to him, he bears it with patience and that is good for him."',
    hadithSource: 'Sahih Muslim 2999',
    topic: 'Gratitude',
  ),
  CrossRefEntry(
    id: 19,
    surahNumber: 3, ayahNumber: 133,
    quranArabic: 'وَسَارِعُوٓا۟ إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا ٱلسَّمَـٰوَٰتُ وَٱلْأَرْضُ',
    quranEnglish: 'Race toward forgiveness from your Lord and a Paradise as wide as the heavens and earth.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "A space in Paradise equal to the distance between a bow and its string is better than all that the sun rises upon."',
    hadithSource: 'Sahih al-Bukhari 3250; Sahih Muslim 2818',
    topic: 'Paradise',
  ),
  CrossRefEntry(
    id: 20,
    surahNumber: 104, ayahNumber: 5,
    quranArabic: 'وَمَآ أَدْرَىٰكَ مَا حُطَمَةٌ',
    quranEnglish: 'And what can make you know what the Crushing Fire is?',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "The Fire of Hell has seventy thousand tongues, each of which has seventy thousand custodians." And he (SAW) said about the verse \"It does not leave alone anyone\" that it spares no one."',
    hadithSource: 'Muwatta Malik 1439',
    topic: 'Hellfire',
  ),
  CrossRefEntry(
    id: 21,
    surahNumber: 5, ayahNumber: 8,
    quranArabic: 'وَلَا يَجْرِمَنَّكُمْ شَنَـَٔانُ قَوْمٍ عَلَىٰٓ أَلَّا تَعْدِلُوا۟',
    quranEnglish: 'And do not let the hatred of a people prevent you from being just.',
    hadithText: 'Abdullah bin Amr (RA) reported: The Messenger of Allah (SAW) said, "The just will be with Allah on thrones of light on the Day of Resurrection — those who are just in their rulings, their families, and in all that they are given authority over."',
    hadithSource: 'Sahih Muslim 1827',
    topic: 'Justice',
  ),
  CrossRefEntry(
    id: 22,
    surahNumber: 21, ayahNumber: 107,
    quranArabic: 'وَمَآ أَرْسَلْنَـٰكَ إِلَّا رَحْمَةً لِّلْعَـٰلَمِينَ',
    quranEnglish: 'And We have not sent you except as a mercy to the worlds.',
    hadithText: 'Abu Hurairah (RA) reported: The Messenger of Allah (SAW) said, "I was sent only as a mercy." When they asked about a difficult matter, he said, "Wait until I seek Allah\'s judgment."',
    hadithSource: 'Musnad Ahmad 8808',
    topic: 'Mercy',
  ),
  CrossRefEntry(
    id: 23,
    surahNumber: 39, ayahNumber: 9,
    quranArabic: 'قُلْ هَلْ يَسْتَوِى ٱلَّذِينَ يَعْلَمُونَ وَٱلَّذِينَ لَا يَعْلَمُونَ',
    quranEnglish: 'Say: Are those who know equal to those who do not know?',
    hadithText: 'Muawiyah (RA) reported: The Messenger of Allah (SAW) said, "When Allah wishes good for someone, He grants him understanding of the religion."',
    hadithSource: 'Sahih al-Bukhari 71; Sahih Muslim 1037',
    topic: 'Knowledge',
  ),
  CrossRefEntry(
    id: 24,
    surahNumber: 2, ayahNumber: 177,
    quranArabic: 'لَيْسَ ٱلْبِرَّ أَن تُوَلُّوا۟ وُجُوهَكُمْ قِبَلَ ٱلْمَشْرِقِ وَٱلْمَغْرِبِ',
    quranEnglish: 'Righteousness is not that you turn your faces toward the east or the west.',
    hadithText: 'An-Nu\'man bin Bashir (RA) reported: The Messenger of Allah (SAW) said, "The believers in their mutual kindness, compassion, and sympathy are just like one body. When one of the limbs suffers, the whole body responds to it with wakefulness and fever."',
    hadithSource: 'Sahih al-Bukhari 6011',
    topic: 'Charity',
  ),
];

// ── Available topic filters ────────────────────────────────────────

final List<String> kCrossRefTopics = [
  'Tawhid',
  'Salah',
  'Fasting',
  'Zakat',
  'Hajj',
  'Paradise',
  'Hellfire',
  'Patience',
  'Gratitude',
  'Knowledge',
  'Family',
  'Justice',
  'Mercy',
  'Prophets',
  'Charity',
];

// ── State ──────────────────────────────────────────────────────────

class CrossRefState {
  final String searchQuery;
  final String? selectedTopic;

  const CrossRefState({
    this.searchQuery = '',
    this.selectedTopic,
  });

  CrossRefState copyWith({
    String? searchQuery,
    String? selectedTopic,
    bool clearTopic = false,
  }) {
    return CrossRefState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTopic: clearTopic ? null : (selectedTopic ?? this.selectedTopic),
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────

class CrossRefNotifier extends StateNotifier<CrossRefState> {
  CrossRefNotifier() : super(const CrossRefState());

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTopic(String? topic) {
    state = state.copyWith(selectedTopic: topic == state.selectedTopic ? null : topic);
  }

  void clearFilters() {
    state = const CrossRefState();
  }
}

// ── Providers ──────────────────────────────────────────────────────

final crossRefProvider = StateNotifierProvider<CrossRefNotifier, CrossRefState>(
  (ref) => CrossRefNotifier(),
);

final filteredCrossRefsProvider = Provider<List<CrossRefEntry>>((ref) {
  final state = ref.watch(crossRefProvider);
  final query = state.searchQuery.toLowerCase().trim();
  final topic = state.selectedTopic;

  return kCrossReferences.where((entry) {
    final matchesTopic = topic == null || entry.topic == topic;
    if (query.isEmpty) return matchesTopic;

    final matchesQuery =
        entry.quranEnglish.toLowerCase().contains(query) ||
        entry.quranArabic.contains(query) ||
        entry.hadithText.toLowerCase().contains(query) ||
        entry.hadithSource.toLowerCase().contains(query) ||
        entry.quranRef.contains(query) ||
        entry.topic.toLowerCase().contains(query);
    return matchesTopic && matchesQuery;
  }).toList();
});
