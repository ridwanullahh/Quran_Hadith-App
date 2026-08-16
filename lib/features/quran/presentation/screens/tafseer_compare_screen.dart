import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

// ═══════════════════════════════════════════════════════════════════
// Hardcoded Tafseer Dataset (Al-Fatiha + Al-Baqarah first 20 ayahs)
// ═══════════════════════════════════════════════════════════════════

const Map<String, Map<int, Map<String, String>>> kHardcodedTafseer = {
  '1': {
    1: {
      'Ibn Kathir': 'This is the beginning of Surah Al-Fatiha. The Prophet (peace be upon him) said that "Al-Fatiha is the greatest Surah in the Quran." It is called Umm al-Quran (the Mother of the Quran) because it contains the essence of the entire Quran. The verse starts with بِسْمِ ٱللَّهِ which is a command to begin every significant act in the name of Allah, seeking His blessing.',
      'As-Sa\'di': 'The Basmalah is one of the signs of this Ummah, distinguishing it from previous nations. It is the key to every good deed, and nothing is accomplished without it. It contains three of Allah\'s names: Allah (the divinity), Al-Rahman (the One whose mercy is vast), and Al-Rahim (the One whose mercy is perfect and reaches the believers).',
    },
    2: {
      'Ibn Kathir': 'Al-Hamd (all praise) is directed to Allah alone, the Lord of all that exists. The word "Hamd" is more general than "Shukr" (thanks) because Hamd can be for attributes and actions, while Shukr is only for blessings. Allah is described as "Rabb al-\'Alamin" — the Lord of all worlds, including humans, jinn, angels, and all creation.',
      'As-Sa\'di': 'Allah instructs His servants to say "Alhamdulillah" — all praise belongs to Allah alone. This is because He is the Creator, Sustainer, and Provider of all blessings. "Rabb al-\'Alamin" means He is the Lord who nurtures and manages all of creation, bringing them from non-existence to existence and sustaining them.',
    },
    3: {
      'Ibn Kathir': '"Ar-Rahman, Ar-Rahim" — these two names are derived from Ar-Rahmah (mercy). Ar-Rahman is a name that is specific to Allah alone and indicates the vastness of His mercy. Ar-Rahim indicates that His mercy reaches His believing servants. The scholars differed regarding the Basmalah: is it the first ayah of Al-Fatiha or a separate verse?',
      'As-Sa\'di': 'Ar-Rahman (the Most Merciful) — His mercy encompasses all of creation. Ar-Rahim (the Especially Merciful) — His special mercy is reserved for the believers. These two names demonstrate that mercy is one of Allah\'s primary attributes, encouraging His servants to hope in His mercy and fear His punishment.',
    },
    4: {
      'Ibn Kathir': '"MalikYawm ad-Din" — The King of the Day of Judgment. Some reciters read it as "Malik" (Owner) and others as "Malik" (King). Both are correct. On the Day of Judgment, no one will have any authority except Allah. All creation will be brought to account before Him, and He will judge between them with perfect justice.',
      'As-Sa\'di': 'Allah is the sole Owner and King of the Day of Recompense, the Day when people will be recompensed for their deeds. On that day, the true sovereignty will become apparent to all — no king, ruler, or authority will remain except His. This reminds the servant to prepare for that day.',
    },
    5: {
      'Ibn Kathir': '"Iyyaka na\'budu wa iyyaka nasta\'in" — You alone we worship, and You alone we ask for help. This verse establishes the core of Tawheed: directing all worship to Allah alone. Worship (\'Ibadah) is a comprehensive term that includes prayer, supplication, hope, fear, and all acts of obedience. The verse then follows with seeking help, because worship requires Allah\'s assistance.',
      'As-Sa\'di': 'This verse is the most important verse in the Quran after the testimony of faith. "You alone we worship" means we single You out in all forms of worship, not worshiping anything besides You. "And You alone we ask for help" means we rely on You alone in all our affairs, seeking Your assistance in worship and in worldly matters.',
    },
    6: {
      'Ibn Kathir': '"Ihdinas-Siratal Mustaqim" — Guide us to the straight path. The straight path is the clear path that leads to Allah and to Paradise — it is Islam, the religion that Allah is pleased with. The Prophet explained that the straight path is the path of those whom Allah has blessed: the Prophets, the truthful, the martyrs, and the righteous.',
      'As-Sa\'di': '"Guide us to the straight path" — this is the most comprehensive supplication, the most beneficial request. The straight path is the clear, straight road that has no crookedness — it is the path of knowledge, truth, and guidance. The servant asks Allah to guide them, keep them firm, and increase them in guidance.',
    },
    7: {
      'Ibn Kathir': '"Siratalladhina an\'amta \'alayhim, ghayril-magh\'du\'bi \'alayhim wa lad-dallin" — The path of those upon whom You have bestowed favor, not of those who have earned anger or of those who are astray. Those who earned anger are the Jews, and those who are astray are the Christians, as authentic Hadith confirm. The servant asks to be guided to the path of the blessed, not the path of the condemned.',
      'As-Sa\'di': 'Allah describes the straight path as the path of those upon whom He has bestowed His grace: the Prophets, the truthful ones, the martyrs, and the righteous. They are excluded from two groups: those who know the truth but abandon it (earning anger), and those who act without knowledge (going astray).',
    },
  },
  '2': {
    1: {
      'Ibn Kathir': '"Alif-Lam-Mim" — These are the Huruf Muqatta\'at (disjointed letters) that appear at the beginning of some Surahs. The exact meaning is known only to Allah, though scholars have suggested various interpretations. Their primary purpose is to demonstrate the miraculous nature of the Quran, which is composed of letters that the Arabs know, yet they cannot produce anything like it.',
      'As-Sa\'di': 'The letters at the beginning of the Surahs are from the mutashabih (ambiguous) verses whose precise meaning Allah has kept to Himself. They point to the inimitability of the Quran, made up of the very letters of the Arabic language that the Arabs were masters of, yet they could not produce anything comparable.',
    },
    2: {
      'Ibn Kathir': '"Dhalikal-Kitabu la rayba fih, hudan lil-muttaqin" — This is the Book about which there is no doubt, a guidance for those conscious of Allah. The Quran is described as having no doubt in it — it is absolutely true and authentic. It is a guidance for the Muttaqin (those who have Taqwa — consciousness and fear of Allah). Taqwa is achieved by fulfilling obligations and avoiding prohibitions.',
      'As-Sa\'di': 'This Book — the Quran — is the definitive, unambiguous book, free from any doubt, uncertainty, or contradiction. It is guidance in both belief and practice. However, this guidance only benefits those who have Taqwa: they believe in the unseen, establish prayer, spend from what Allah has provided, believe in what was revealed before, and have certainty about the Hereafter.',
    },
    3: {
      'Ibn Kathir': '"Alladhina yu\'minuna bil-ghaybi wa yuqimunas-salata wa mimma razaqnahum yunfiqun" — Those who believe in the unseen, establish prayer, and spend out of what We have provided for them. These are the characteristics of the Muttaqin: (1) Belief in the unseen — things beyond human perception like Allah, angels, the Last Day, (2) Establishing prayer — performing it properly with all its conditions, (3) Spending in charity — from the provisions Allah has given them.',
      'As-Sa\'di': 'The first quality of the Muttaqin is believing in the unseen — that which is hidden from human senses but established by revelation, such as Allah, His angels, His books, His messengers, the Last Day, and divine decree. The second is establishing prayer properly and consistently. The third is spending from the wealth Allah has bestowed upon them, recognizing it as a trust from Him.',
    },
    4: {
      'Ibn Kathir': '"Walladhina yu\'minuna bima unzila ilayka wa ma unzila min qablika, wa bil-akhirati hum yuqinun" — And those who believe in what has been revealed to you and what was revealed before you, and of the Hereafter they are certain. This verse completes the description of the Muttaqin: they believe in all revelations — the Quran sent to Muhammad and previous scriptures sent to earlier prophets. They have absolute certainty (Yaqin) about the Hereafter.',
      'As-Sa\'di': 'The believers believe in all that Allah has revealed: the Quran to Muhammad and the previous scriptures to the prophets before him. They do not differentiate between the messengers, believing in all of them. Their belief in the Hereafter is not mere hope or speculation but firm, unwavering certainty that leaves no room for doubt.',
    },
    5: {
      'Ibn Kathir': '"Ula-ika \'ala hudan min rabbihim, wa ula-ika humul-muflihun" — Those are upon guidance from their Lord, and it is those who are the successful. These people who possess the described qualities are the ones upon true guidance from their Lord. They are the truly successful ones — not those who accumulate worldly wealth but those who attain salvation and Allah\'s pleasure.',
      'As-Sa\'di': 'Those who possess these noble qualities are upon clear guidance from their Lord in all their affairs — in knowledge, action, and methodology. They are the true achievers of success (Falah) — the complete and comprehensive success that includes salvation from all evils and attainment of all good in this world and the Hereafter.',
    },
    6: {
      'Ibn Kathir': '"Inna alladhina kafaru sawa-un \'alayhim a-anzartahum am lam tunzirhum la yu\'minun" — Indeed, those who disbelieve — it is all the same for them whether you warn them or do not warn them — they will not believe. Allah informs that the disbelievers have sealed their hearts. No warning will benefit them because they have chosen to reject the truth. This is not a deficiency in the message or the messenger, but in the recipients.',
      'As-Sa\'di': 'As for those who persist in disbelief, it makes no difference whether you warn them or remain silent — they will not believe. Their hearts are sealed, their hearing is impaired, and their sight is veiled. They chose disbelief, and as a consequence, Allah placed a seal upon their hearts as a just punishment matching their deed.',
    },
    7: {
      'Ibn Kathir': '"Khatamallahu \'ala qulubihim wa \'ala sam\'ihim wa \'ala absarihim ghashiyatun, wa lahum \'adhabun \'azim" — Allah has set a seal upon their hearts and upon their hearing, and over their vision is a veil. And for them is a great punishment. The seal on their hearts means they cannot comprehend the truth. The covering over their eyes means they cannot see the signs of Allah. The great punishment in the Hereafter awaits them.',
      'As-Sa\'di': 'Because they persisted in disbelief, Allah sealed their hearts so no truth can enter, blocked their hearing so no guidance reaches them, and placed a veil over their eyes so they cannot see the proofs. This is a fair recompense for their rejection. For them is a tremendous punishment — a punishment fitting the magnitude of their crime of disbelieving in Allah\'s signs.',
    },
    8: {
      'Ibn Kathir': '"Wa minan-nasi man yaqulu amanna billahi wa bil-yaumil-akhiri wa ma hum bi-mu\'minin" — And of the people are some who say, "We believe in Allah and the Last Day," but they are not believers. This refers to the Munafiqun (hypocrites) who outwardly declare faith but inwardly harbor disbelief. They try to deceive Allah and the believers, but they only deceive themselves without realizing it.',
      'As-Sa\'di': 'Among people are those who claim to believe in Allah and the Last Day, but their claim is false — they have no share of true faith in their hearts. They are the hypocrites who combine the statement of the tongue with the disbelief of the heart. They thought their deception was successful, but in reality they only deceived themselves.',
    },
    9: {
      'Ibn Kathir': '"Yukhadi\'unallaha walladhina amanu wa ma yakhda\'una illa anfusahum wa ma yash\'urun" — They try to deceive Allah and those who believe, but they deceive not except themselves and perceive it not. The hypocrites think they are clever by hiding their true intentions, but Allah knows what is in their hearts. They are truly ignorant of the gravity of their actions and the punishment that awaits them.',
      'As-Sa\'di': 'They attempt to deceive Allah — the Knower of the unseen and the seen — and the believers. But they only deceive themselves while being completely unaware. They think their hypocrisy brings them worldly benefit, but it actually brings them loss in both this world and the Hereafter.',
    },
    10: {
      'Ibn Kathir': '"Fi qulubihim maradun, fazadahumullahu maradaan, wa lahum \"adhabun almun bi-ma kanu yakdhibun" — In their hearts is disease, so Allah has increased their disease; and for them is a painful punishment because they used to lie. The "disease" in their hearts refers to doubt, hypocrisy, and desire. Allah increased their disease as a punishment — their doubts multiplied. Their punishment is severe because they habitually lied.',
      'As-Sa\'di': 'There is a sickness in their hearts — the sickness of doubt, hypocrisy, and corrupted desires. Because they chose this path, Allah increased them in sickness. Every time they sink deeper into hypocrisy, Allah allows them to fall further. They deserve a painful punishment because they persistently lied — against Allah, against the truth, and against the believers.',
    },
    11: {
      'Ibn Kathir': '"Wa idha qila lahum la tufsidu fil-ardi qalu innama nahnu muslihun" — And when it is said to them, "Do not cause corruption on the earth," they say, "We are but reformers." The hypocrites are told not to spread corruption through disbelief, sin, and disobedience, but they claim they are actually doing good. This is a hallmark of hypocrisy: calling evil by the name of good.',
      'As-Sa\'di': 'When the hypocrites are told not to spread corruption through their disbelief, sinful actions, and misleading statements, they respond by claiming to be reformers and peacemakers. This is because every wrongdoer justifies their actions. They consider their corruption to be righteousness, which is the height of their misguidance.',
    },
    12: {
      'Ibn Kathir': '"Ala innahum humul-mufsiduna walakin la yash\'urun" — Unquestionably, it is they who are the corrupters, but they perceive it not. Allah confirms that despite their claims of being reformers, they are the true corrupters. They spread disbelief, hypocrisy, and sin, yet they are completely oblivious to the harm they cause to themselves and others.',
      'As-Sa\'di': 'Allah declares — with absolute certainty — that they are the ones spreading corruption, not reform. Corruption includes every form of disbelief, sin, and disobedience that harms individuals and society. But these people lack awareness and insight; they are so deeply entrenched in their misguidance that they cannot see their own corruption.',
    },
    13: {
      'Ibn Kathir': '"Wa ida qila lahum aminu kama amanan-nasu yaguluna a-nu\'minu kama amanas-sufaha-u, ala innahum humus-sufaha-u walakin la ya\'lamun" — And when it is said to them, "Believe as the people have believed," they say, "Should we believe as the foolish have believed?" Unquestionably, it is they who are the foolish, but they know it not. The hypocrites mock the believers for their simple, complete faith.',
      'As-Sa\'di': 'When told to believe with true, complete faith like the believers, the hypocrites respond with mockery, calling the believers "foolish." In reality, true foolishness belongs to those who trade the eternal for the temporary, who prefer misguidance over guidance. The believers are the truly wise ones, for they have attained the ultimate success.',
    },
    14: {
      'Ibn Kathir': '"Wa ida laqu alladhina amanu qalu amanna, wa ida khalau ila shayatinihim qalu inna ma\'akum, innama nahnu mustahzi-un" — And when they meet those who believe, they say, "We believe"; but when they are alone with their evil associates, they say, "Indeed, we are with you; we were only mocking." The hypocrites display a double face: believing in front of Muslims and mocking behind their backs.',
      'As-Sa\'di': 'When they encounter the believers, they pretend to share their faith, saying "we believe." But when they return to their leaders and associates among the disbelievers and hypocrites, they reassure them: "We are with you, we were only mocking the believers." They alternate between hypocrisy and mockery.',
    },
    15: {
      'Ibn Kathir': '"Allahu yastahzi-u bihim wa yamudduhum fi tughyanihim ya\'mahun" — Allah mocks them and prolongs them in their transgression while they blindly wander. Allah responds to their mockery with His own — He allows them to continue in their disbelief, giving them rope to sink deeper, all while His punishment is being prepared for them. They wander in their confusion, not realizing their fate.',
      'As-Sa\'di': 'Allah mocks them by requiting their mockery — allowing them to continue in their disbelief while planning their humiliation. He grants them respite, not out of negligence, but as part of a wise plan. They wander blindly in their transgression, increasing in their misguidance with each passing day.',
    },
    16: {
      'Ibn Kathir': '"Ula-ikalladhinashtara-wud-dalalata bil-huda fama rabihat tijaratuhum wa ma kanu muhtadin" — Those are the ones who have purchased error in exchange for guidance, so their transaction has brought no profit, nor have they been guided. The hypocrites "bought" misguidance and sold guidance — the worst trade imaginable. They gained nothing and lost everything.',
      'As-Sa\'di': 'These are the people who exchanged guidance for misguidance, truth for falsehood, and certainty for doubt. Their trade brought them no profit — indeed, it brought them total loss. They did not attain guidance, nor did they achieve their worldly objectives. This is the ultimate example of a losing bargain.',
    },
    17: {
      'Ibn Kathir': '"Mashalahum bi-mathalil-ladhistawqada naran, falamma adaa-at ma hawlahu dhahaballahu bi-nurihim wa tarakahum fi zulumat-in la yub-sirun" — Their example is that of one who kindled a fire, but when it illuminated what was around him, Allah took away their light and left them in darkness so they could not see. The fire represents the light of faith they briefly experienced, which Allah then removed due to their hypocrisy.',
      'As-Sa\'di': 'Their condition is like someone who lit a fire that illuminated their surroundings, but just as they began to see, Allah extinguished their light, leaving them in complete darkness. They had a glimpse of guidance and the truth, but then it was taken away — they cannot see, hear, or understand. This is because they rejected the truth after recognizing it.',
    },
    18: {
      'Ibn Kathir': '"Summun bukmun \"umyun fahum la yarji\"un" — Deaf, dumb and blind — so they will not return to the right path. After describing the hypocrites, Allah summarizes their condition: they are deaf to the truth, dumb in speaking it, and blind to its signs. Because of this complete sensory and spiritual deprivation, they cannot return to the straight path.',
      'As-Sa\'di': 'They are deaf to the truth — they do not listen to it with acceptance. They are dumb — they do not speak the truth. They are blind — they do not see the path of guidance. With these three afflictions, it is impossible for them to return to the truth and the right path. They have locked themselves out of guidance.',
    },
    19: {
      'Ibn Kathir': '"Aw kasayyibin minas-sama-i fihim zulumatun wa ra\'dun wa barqun, yaj\'aluna asabi\"ahum fi azanihim minas-sawa\'iqi hazramal-mawt, wallahu muhitun bil-kafirin" — Or like a rainstorm from the sky within which is darkness, thunder, and lightning. They put their fingers in their ears against the thunderclaps in dread of death. But Allah is encompassing of the disbelievers. This second parable shows hypocrites caught in storms of doubt and trials.',
      'As-Sa\'di': 'Another example of their condition: they are like people caught in a dark rainstorm with thunder and lightning. Every time lightning flashes, they walk in its light, but when darkness returns, they stand still. If Allah willed, He could take away their hearing and sight — He has power over all things, and nothing can escape His knowledge and will.',
    },
    20: {
      'Ibn Kathir': '"Ay-kadayuhimu kullama adaa lahum ma-yashtahiu madada lahuma, wa la-in absartahum la-farrawwa munkar." Almost the lightning would snatch away their sight. Every time it lights for them, they walk therein; but when darkness comes over them, they stand still. And if Allah had willed, He could have taken away their hearing and their sight.',
      'As-Sa\'di': 'The lightning nearly takes away their sight — the truth and its proofs are so overwhelming that they almost cannot bear it. When the truth is clear to them, they reluctantly follow it, but as soon as doubt or trial comes, they stop. They cannot bear the light of truth consistently, because their hearts are diseased and their faith is not genuine.',
    },
  },
};

// ═══════════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════════

class TafseerCompareScreen extends ConsumerStatefulWidget {
  const TafseerCompareScreen({super.key});

  @override
  ConsumerState<TafseerCompareScreen> createState() => _TafseerCompareScreenState();
}

class _TafseerCompareScreenState extends ConsumerState<TafseerCompareScreen> {
  int _selectedSurah = 1;
  String _selectedSource1 = 'Ibn Kathir';
  String _selectedSource2 = 'As-Sa\'di';
  int _selectedAyah = 1;
  final _scrollController1 = ScrollController();
  final _scrollController2 = ScrollController();
  bool _isSyncing = false;

  List<String> get _availableSources {
    final surahData = kHardcodedTafseer['$_selectedSurah'];
    if (surahData == null) return [];
    final firstAyah = surahData.values.first;
    return firstAyah.keys.toList();
  }

  List<int> get _availableAyahs {
    final surahData = kHardcodedTafseer['$_selectedSurah'];
    if (surahData == null) return [];
    return surahData.keys.toList()..sort();
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  void _syncScroll(ScrollController source, ScrollController target) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      target.jumpTo(source.offset);
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahData = kHardcodedTafseer['$_selectedSurah'];
    final ayahData = surahData?[_selectedAyah];
    final tafseer1 = ayahData?[_selectedSource1] ?? '';
    final tafseer2 = ayahData?[_selectedSource2] ?? '';
    final uthmaniAsync = ref.watch(_uthmaniProvider);

    final surahNames = {1: 'Al-Fatiha', 2: 'Al-Baqarah'};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tafsir Comparison'),
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
            child: Column(
              children: [
                // Surah selector
                Row(
                  children: [
                    Text('Surah:', style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 1, label: Text('Al-Fatiha')),
                          ButtonSegment(value: 2, label: Text('Al-Baqarah')),
                        ],
                        selected: {_selectedSurah},
                        onSelectionChanged: (v) {
                          setState(() {
                            _selectedSurah = v.first;
                            _selectedAyah = 1;
                          });
                        },
                        style: ButtonStyle(
                          textStyle: WidgetStatePropertyAll(TextStyle(
                            fontFamily: AppTheme.latinFontFamily, fontSize: 12,
                          )),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Ayah selector
                Row(
                  children: [
                    Text('Ayah:', style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _availableAyahs.map((a) {
                            final isSelected = a == _selectedAyah;
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ChoiceChip(
                                label: Text('$a', style: const TextStyle(fontSize: 12)),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedAyah = a),
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Source selectors
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSource1,
                        decoration: const InputDecoration(
                          labelText: 'Source 1',
                          isDense: true,
                          prefixIcon: Icon(Icons.book_rounded, size: 18),
                        ),
                        items: _availableSources.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedSource1 = v); },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSource2,
                        decoration: const InputDecoration(
                          labelText: 'Source 2',
                          isDense: true,
                          prefixIcon: Icon(Icons.book_rounded, size: 18),
                        ),
                        items: _availableSources.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedSource2 = v); },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Comparison content
          Expanded(
            child: ayahData == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_rounded, size: 48, color: AppColors.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No tafseer data for this selection',
                            style: TextStyle(
                              fontFamily: AppTheme.latinFontFamily,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            )),
                      ],
                    ),
                  )
                : uthmaniAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    data: (uthmani) {
                      final surahAyahs = uthmani['$_selectedSurah'] as List<dynamic>?;
                      final arabicText = surahAyahs != null && _selectedAyah <= surahAyahs.length
                          ? surahAyahs[_selectedAyah - 1] as String
                          : '';

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          // Arabic ayah
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${surahNames[_selectedSurah] ?? "Surah $_selectedSurah"} : $_selectedAyah',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.latinFontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  arabicText,
                                  style: TextStyle(
                                    fontFamily: AppTheme.arabicFontFamily,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    height: 2.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 16),
                          // Split view
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Source 1
                              Expanded(
                                child: _TafseerCard(
                                  title: _selectedSource1,
                                  text: tafseer1,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Source 2
                              Expanded(
                                child: _TafseerCard(
                                  title: _selectedSource2,
                                  text: tafseer2,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    error: (_, __) => const SizedBox.shrink(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tafseer Card
// ═══════════════════════════════════════════════════════════════════

class _TafseerCard extends StatelessWidget {
  final String title;
  final String text;
  final Color color;

  const _TafseerCard({
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 13,
                height: 1.7,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Provider for uthmani text
// ═══════════════════════════════════════════════════════════════════

final _uthmaniProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final jsonString = await rootBundle.loadString(AppConstants.quranUthmaniAssetPath);
  return json.decode(jsonString) as Map<String, dynamic>;
});
