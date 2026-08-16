import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'popup_widget.dart';

// ═══════════════════════════════════════════════════════════════════
// Data Models
// ═══════════════════════════════════════════════════════════════════

class PopupQuranVerse {
  final String arabic;
  final String english;
  final String reference;

  const PopupQuranVerse({
    required this.arabic,
    required this.english,
    required this.reference,
  });
}

class PopupHadith {
  final String text;
  final String narrator;
  final String collection;

  const PopupHadith({
    required this.text,
    required this.narrator,
    required this.collection,
  });
}

enum PopupContentType { quran, hadith, both }

// ═══════════════════════════════════════════════════════════════════
// Hardcoded Collections – Qur'an Verses (25)
// ═══════════════════════════════════════════════════════════════════

const List<PopupQuranVerse> _quranVerses = [
  PopupQuranVerse(
    arabic: '\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0652\u0645\u064E\u0646\u0650 \u0627\u0644\u0631\u0651\u064E\u062D\u0650\u064A\u0645\u0650',
    english: 'In the name of Allah, the Most Gracious, the Most Merciful.',
    reference: 'Al-Fatiha 1:1',
  ),
  PopupQuranVerse(
    arabic: '\u0627\u0644\u0644\u0651\u064E\u0647\u064F \u0644\u064E\u0627 \u0625\u0650\u0644\u064E\u0670\u0647\u064E \u0625\u0650\u0644\u0651\u064E\u0627 \u0647\u064F\u0648\u064E \u0627\u0644\u062D\u064E\u064A\u0651\u064F \u0627\u0644\u0652\u0642\u064E\u064A\u0651\u064F\u0645\u064F',
    english:
        'Allah \u2014 there is no deity except Him, the Ever-Living, the Sustainer of [all] existence.',
    reference: 'Al-Baqarah 2:255',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0645\u064E\u0646 \u064A\u064E\u062A\u0651\u064E\u0642\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u064E \u064A\u064E\u062C\u0652\u0639\u064E\u0644 \u0644\u0651\u064E\u0647\u064F \u0645\u064E\u062E\u0652\u0631\u064E\u062C\u064B\u0627',
    english: 'And whoever fears Allah \u2014 He will make for him a way out.',
    reference: 'At-Talaq 65:2',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0645\u064E\u0646 \u064A\u064E\u062A\u064E\u0648\u064E\u0643\u0651\u064E\u0644\u0652 \u0639\u064E\u0644\u064E\u0649 \u0627\u0644\u0644\u0651\u064E\u0647\u0650 \u0641\u064E\u0647\u064F\u0648\u064E \u062D\u064E\u0633\u0652\u0628\u064F\u0647\u064F',
    english: 'And whoever relies upon Allah \u2014 then He is sufficient for him.',
    reference: 'At-Talaq 65:3',
  ),
  PopupQuranVerse(
    arabic: '\u0641\u064E\u0625\u0650\u0646\u0651\u064E \u0645\u064E\u0639\u064E \u0627\u0644\u0652\u0639\u064F\u0633\u0652\u0631\u0650 \u064A\u064F\u0633\u0652\u0631\u064B\u0627',
    english: 'Indeed, with hardship comes ease.',
    reference: 'Ash-Sharh 94:6',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0644\u064E\u0633\u064E\u0648\u0652\u0641\u064E \u064A\u064F\u0639\u0652\u0637\u0650\u064A\u0643\u064E \u0631\u064E\u0628\u0651\u064F\u0643\u064E \u0641\u064E\u062A\u064E\u0631\u0652\u0636\u064E\u0649\u0670',
    english: 'And your Lord is going to give you, and you will be satisfied.',
    reference: 'Ad-Duha 93:5',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0642\u064F\u0644 \u0631\u0651\u064E\u0628\u0651\u0650 \u0632\u0650\u062F\u0652\u0646\u0650\u064A \u0639\u0650\u0644\u0652\u0645\u064B\u0627',
    english: 'And say: "My Lord, increase me in knowledge."',
    reference: 'Ta-Ha 20:114',
  ),
  PopupQuranVerse(
    arabic:
        '\u0631\u064E\u0628\u0651\u0650 \u0627\u0634\u0652\u0631\u064E\u062D\u0652 \u0644\u0650\u064A \u0635\u064E\u062F\u0652\u0631\u0650\u064A \u0648\u064E\u064A\u064E\u0633\u0651\u0650\u0631\u0652 \u0644\u0650\u064A \u0623\u064E\u0645\u0652\u0631\u0650\u064A',
    english:
        'My Lord, expand for me my breast [with assurance] and ease for me my task.',
    reference: 'Ta-Ha 20:25-26',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0644\u064E\u0627 \u062A\u064E\u0647\u0650\u0646\u064F\u0648\u0627 \u0648\u064E\u0644\u064E\u0627 \u062A\u064E\u062D\u0652\u0632\u064E\u0646\u064F\u0648\u0627 \u0648\u064E\u0623\u064E\u0646\u062A\u064F\u0645\u064F \u0627\u0644\u0652\u0623\u064E\u0639\u0652\u0644\u064E\u0648\u0652\u0646\u064E \u0625\u0650\u0646 \u0643\u064F\u0646\u062A\u064F\u0645 \u0645\u064F\u0624\u0652\u0645\u0650\u0646\u0650\u064A\u0646\u064E',
    english:
        'Do not lose heart or grieve, for you will have the upper hand, if you are believers.',
    reference: 'Al-Imran 3:139',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0623\u064E\u062D\u0652\u0633\u0650\u0646\u064F\u0648\u0627 \u0625\u0650\u0646\u0651\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u064E \u0645\u064E\u0639\u064E \u0627\u0644\u0652\u0645\u064F\u062D\u0652\u0633\u0650\u0646\u0650\u064A\u0646\u064E',
    english: 'And do good; indeed, Allah loves the doers of good.',
    reference: 'Al-Baqarah 2:195',
  ),
  PopupQuranVerse(
    arabic: '\u0625\u0650\u0646\u0651\u064E \u0645\u064E\u0639\u064E \u0627\u0644\u0652\u0639\u064F\u0633\u0652\u0631\u0650 \u064A\u064F\u0633\u0652\u0631\u064B\u0627',
    english: 'Indeed, with hardship [will be] ease.',
    reference: 'Ash-Sharh 94:5',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0645\u064E\u0627 \u062A\u064F\u0642\u064E\u062F\u0651\u0650\u0645\u064F\u0648\u0627 \u0644\u0650\u0623\u064E\u0646\u0641\u064F\u0633\u0650\u0643\u064F\u0645 \u0645\u0650\u0646\u0652 \u062E\u064E\u064A\u0652\u0631\u064D \u062A\u064E\u062C\u0650\u062F\u064F\u0648\u0647\u064F \u0639\u0650\u0646\u062F\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650',
    english:
        'Whatever good you send forth for yourselves, you will find it with Allah.',
    reference: 'Al-Baqarah 2:110',
  ),
  PopupQuranVerse(
    arabic:
        '\u0648\u064E\u0644\u064E\u0630\u0650\u0643\u064E\u0631\u0652 \u0627\u0633\u0645\u064E \u0631\u064E\u0628\u0651\u0650\u0643\u064E \u0648\u064E\u062A\u064E\u0628\u064E\u0651\u062A\u0652 \u0644\u064E\u0647\u064F',
    english:
        'And remember the name of your Lord and devote yourself to Him with [complete] devotion.',
    reference: 'Al-Muzzammil 73:8',
  ),
  PopupQuranVerse(
    arabic: '\u0627\u0644\u0651\u064E\u0630\u0650\u064A\u0646\u064E \u0622\u0645\u064E\u0646\u064F\u0648\u0627 \u0648\u064E\u062A\u064E\u0637\u064E\u0645\u064E\u0626\u0650\u0646\u0652 \u0642\u064F\u0644\u064F\u0648\u0628\u064F\u0647\u064F\u0645 \u0628\u0650\u0630\u0650\u0643\u0652\u0631\u0650 \u0627\u0644\u0644\u0651\u064E\u0647\u0650',
    english:
        'Those who have believed and whose hearts find rest in the remembrance of Allah.',
    reference: 'Ar-Ra\'d 13:28',
  ),
  PopupQuranVerse(
    arabic:
        '\u0648\u064E\u0627\u0633\u0652\u062A\u064E\u063A\u0652\u0641\u0650\u0631\u064F\u0648\u0627 \u0631\u064E\u0628\u0651\u064E\u0643\u064F\u0645\u0652 \u0625\u0650\u0646\u0651\u064E \u0647\u064F \u0643\u064E\u0627\u0646\u064E \u063A\u064E\u0641\u064F\u0648\u0631\u064B\u0627',
    english:
        'And seek forgiveness of your Lord. Indeed, He is ever a Perpetual Forgiver.',
    reference: 'Nuh 71:10',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0645\u064E\u0627 \u0628\u0650\u0643\u064F\u0645 \u0645\u0650\u0646\u0652 \u0646\u0650\u0639\u0652\u0645\u064E\u0629\u064D \u0641\u064E\u0645\u0650\u0646\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u0650',
    english: 'And whatever you have of blessing \u2014 it is from Allah.',
    reference: 'An-Nahl 16:53',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0642\u064E\u0627\u0644\u064E \u0631\u064E\u0628\u0651\u064F\u0643\u064F\u0645\u064F \u0627\u062F\u0652\u0639\u064F\u0648\u0646\u0650\u064A \u0623\u064E\u0633\u0652\u062A\u064E\u062C\u0650\u0628\u0652 \u0644\u064E\u0643\u064F\u0645\u0652',
    english:
        'And your Lord says, "Call upon Me; I will respond to you."',
    reference: 'Ghafir 40:60',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0644\u064E\u0642\u064E\u062F\u0652 \u064A\u064E\u0633\u0651\u064E\u0631\u0652\u0646\u064E\u0627 \u0627\u0644\u0652\u0642\u064F\u0631\u0652\u0622\u0646\u064E \u0644\u0650\u0644\u0630\u0650\u0643\u0652\u0631\u0650 \u0647\u064E\u0644\u0652 \u0645\u0650\u0646 \u0645\u064F\u062F\u0651\u064E\u0643\u0650\u0631\u064D',
    english:
        'And We have certainly made the Qur\'an easy for remembrance, so is there any who will remember?',
    reference: 'Al-Qamar 54:17',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0644\u064E\u0627 \u062A\u064E\u064A\u0626\u064E\u0633\u064F\u0648\u0627 \u0648\u064E\u0644\u064E\u0627 \u062A\u064E\u062D\u0652\u0632\u064E\u0646\u064F\u0648\u0627 \u0648\u064E\u0623\u064E\u0646\u062A\u064F\u0645\u064F \u0627\u0644\u0652\u0623\u064E\u0639\u0652\u0644\u064E\u0648\u0652\u0646\u064E',
    english: 'Do not grieve; indeed, Allah is with us.',
    reference: 'At-Tawbah 9:40',
  ),
  PopupQuranVerse(
    arabic: '\u0643\u064F\u0644\u0651\u064E \u0646\u064E\u0641\u0652\u0633\u064D \u0630\u064E\u0627\u0626\u0650\u0642\u064E\u0629\u064F \u0627\u0644\u0652\u0645\u064E\u0648\u0652\u062A\u0650',
    english: 'Every soul will taste death.',
    reference: 'Al-Imran 3:185',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0644\u064E\u0635\u064E\u0628\u0652\u0631\u064C\u0627 \u0641\u064E\u0625\u0650\u0646\u0651\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u064E \u0644\u064E\u0627 \u064A\u064F\u0636\u0650\u064A\u0639\u064F \u0623\u064E\u062C\u0652\u0631\u064E \u0627\u0644\u0652\u0645\u064F\u062D\u0652\u0633\u0650\u0646\u0650\u064A\u0646\u064E',
    english:
        'And be patient, for indeed, Allah does not allow to be lost the reward of those who do good.',
    reference: 'Hud 11:115',
  ),
  PopupQuranVerse(
    arabic: '\u0642\u064F\u0644\u0652 \u0647\u064F\u0648\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u064F \u0623\u064E\u062D\u064E\u062F\u064C',
    english: 'Say, "He is Allah, [who is] One."',
    reference: 'Al-Ikhlas 112:1',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0646\u064E\u0641\u0652\u0633\u064D \u0648\u064E\u0645\u064E\u0627 \u0633\u064E\u0648\u0651\u064E\u0627\u0647\u064E\u0627 \u0644\u064E\u0647\u064E\u0627',
    english: 'And a soul and [the] One who proportioned it.',
    reference: 'Ash-Shams 91:7',
  ),
  PopupQuranVerse(
    arabic: '\u0641\u064E\u0623\u064E\u0644\u0652\u0647\u064E\u0645\u0652 \u062A\u064E\u0639\u0652\u0644\u064E\u0645\u064F\u0648\u0646\u064E \u0623\u064E\u0646\u0651\u064E \u0627\u0644\u0644\u0651\u064E\u0647\u064E \u0647\u064F\u0648\u064E \u0627\u0644\u0652\u062D\u064E\u0642\u0651\u064F \u0627\u0644\u0652\u0645\u064F\u0628\u0650\u064A\u0646\u064F',
    english:
        'So know [O Muhammad] that there is no deity except Allah and ask forgiveness for your sin.',
    reference: 'Muhammad 47:19',
  ),
  PopupQuranVerse(
    arabic: '\u0648\u064E\u0627\u0644\u0652\u0645\u064F\u0624\u0652\u0645\u0650\u0646\u064F\u0648\u0646\u064E \u0648\u064E\u0627\u0644\u0652\u0645\u064F\u0624\u0652\u0645\u0650\u0646\u064E\u0627\u062A\u064F \u0628\u064E\u0639\u0652\u0636\u064F\u0647\u064F\u0645\u0652 \u0623\u064E\u0648\u0652\u0644\u0650\u064A\u064E\u0627\u0621\u064F \u0628\u064E\u0639\u0652\u0636\u064D',
    english: 'The believing men and believing women are allies of one another.',
    reference: 'At-Tawbah 9:71',
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Hardcoded Collections – Hadiths (25)
// ═══════════════════════════════════════════════════════════════════

const List<PopupHadith> _hadiths = [
  PopupHadith(
    text: 'None of you truly believes until he loves for his brother what he loves for himself.',
    narrator: 'Anas ibn Malik',
    collection: 'Sahih al-Bukhari 13',
  ),
  PopupHadith(
    text:
        'The strong man is not the one who can overpower others. The strong man is the one who controls himself when he is angry.',
    narrator: 'Abu Hurairah',
    collection: 'Sahih al-Bukhari 6114',
  ),
  PopupHadith(
    text: 'The best among you are those who have the best manners and character.',
    narrator: 'Abdullah ibn Amr',
    collection: 'Sahih al-Bukhari 6035',
  ),
  PopupHadith(
    text:
        'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
    narrator: 'Abu Hurairah',
    collection: 'Sahih al-Bukhari 6018',
  ),
  PopupHadith(
    text:
        'Make things easy and do not make them difficult. Give glad tidings and do not drive people away.',
    narrator: 'Anas ibn Malik',
    collection: 'Sahih al-Bukhari 69',
  ),
  PopupHadith(
    text:
        'The example of a believer is that of a fresh tender plant; from whichever direction the wind blows, it bends it. But when the wind dies down, it straightens up again.',
    narrator: 'Abu Hurairah',
    collection: 'Sahih al-Bukhari 5622',
  ),
  PopupHadith(
    text:
        'A Muslim is the one from whose tongue and hands other Muslims are safe.',
    narrator: 'Abdullah ibn Amr',
    collection: 'Sahih al-Bukhari 10',
  ),
  PopupHadith(
    text: 'The world is a prison for a believer and a paradise for a disbeliever.',
    narrator: 'Abu Hurairah',
    collection: 'Sahih Muslim 2956',
  ),
  PopupHadith(
    text:
        'Actions are judged by intentions, and every person will get the reward according to what they intended.',
    narrator: 'Umar ibn al-Khattab',
    collection: 'Sahih al-Bukhari 1',
  ),
  PopupHadith(
    text:
        'Whoever is grateful, his gratitude is only for the benefit of his own soul, and whoever is ungrateful, then surely my Lord is Self-Sufficient, Generous.',
    narrator: 'Abu Hurairah',
    collection: 'Sahih Muslim 2743',
  ),
  PopupHadith(
    text:
        'Take advantage of five before five: your youth before your old age, your health before your sickness, your wealth before your poverty, your free time before your busyness, and your life before your death.',
    narrator: 'Abdullah ibn Abbas',
    collection: 'Musnad Ahmad 5/87',
  ),
  PopupHadith(
    text:
        'The most complete of the believers in faith, is the one with the best character. And the best of you are those who are best to their women.',
    narrator: 'Abu Hurairah',
    collection: 'Sunan at-Tirmidhi 1162',
  ),
  PopupHadith(
    text: 'A person will be with those whom he loves.',
    narrator: 'Anas ibn Malik',
    collection: 'Sahih al-Bukhari 6168',
  ),
  PopupHadith(
    text:
        'None of you truly believes until I am more beloved to him than his father, his child, and all of mankind.',
    narrator: 'Anas ibn Malik',
    collection: 'Sahih al-Bukhari 15',
  ),
  PopupHadith(
    text:
        'If Allah loves a person, He calls Gabriel, saying: "Allah loves so-and-so; O Gabriel, love him." So Gabriel loves him and then calls out in the heavens, "Allah loves so-and-so."',
    narrator: 'Abu Hurairah',
    collection: 'Sahih al-Bukhari 3209',
  ),
  PopupHadith(
    text: 'Patience is a light.',
    narrator: 'Abu Malik al-Ash\'ari',
    collection: 'Sahih Muslim 223',
  ),
  PopupHadith(
    text:
        'Whoever treads a path in search of knowledge, Allah will make easy for him the path to Paradise.',
    narrator: 'Abu Hurairah',
    collection: 'Sahih Muslim 2699',
  ),
  PopupHadith(
    text: 'The best of people are those who are most beneficial to others.',
    narrator: 'Abdullah ibn Amr',
    collection: 'Musnad Ahmad 16/115',
  ),
  PopupHadith(
    text:
        'Leave that which makes you doubt for that which does not make you doubt.',
    narrator: 'An-Nu\'man ibn Bashir',
    collection: 'Sunan at-Tirmidhi 2518',
  ),
  PopupHadith(
    text:
        'The heart of an old man remains young in two respects: his love for the world and his long hopes.',
    narrator: 'Anas ibn Malik',
    collection: 'Sahih al-Bukhari 6419',
  ),
  PopupHadith(
    text: 'Knowledge is a treasure house, and the key to it is questioning.',
    narrator: 'Ali ibn Abi Talib',
    collection: 'Mustadrak al-Hakim 1/93',
  ),
  PopupHadith(
    text:
        'A servant of Allah will remain standing on the Day of Judgment until he is questioned about four things: his life and how he spent it, his youth and how he used it, his wealth and how he earned it, and how he spent it.',
    narrator: 'Mu\'adh ibn Jabal',
    collection: 'Sunan at-Tirmidhi 2417',
  ),
  PopupHadith(
    text:
        'Do not despise any good deed, even meeting your brother with a cheerful face.',
    narrator: 'Abu Dharr',
    collection: 'Sahih Muslim 2636',
  ),
  PopupHadith(
    text:
        'The most beloved deeds to Allah are those done consistently, even if they are small.',
    narrator: 'Aisha',
    collection: 'Sahih al-Bukhari 6464',
  ),
  PopupHadith(
    text:
        'The one who is not grateful to people is not grateful to Allah.',
    narrator: 'Abu Hurairah',
    collection: 'Musnad Ahmad 2/327',
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Popup Service
// ═══════════════════════════════════════════════════════════════════

class PopupService {
  PopupService._();

  static final PopupService instance = PopupService._();
  static final _random = Random();

  // ── Hive Keys ─────────────────────────────────────────────────

  static const _keyEnabled = 'popup_enabled';
  static const _keyInterval = 'popup_interval_minutes';
  static const _keyLastShown = 'last_popup_time';
  static const _keySnoozeUntil = 'popup_snooze_until';
  static const _keyContentType = 'popup_content_type';

  // ── Defaults ──────────────────────────────────────────────────

  static const int defaultIntervalMinutes = 30;
  static const PopupContentType defaultContentType = PopupContentType.both;

  // ── Getters ───────────────────────────────────────────────────

  bool get isEnabled {
    try {
      final box = Hive.box('settings');
      return box.get(_keyEnabled, defaultValue: true) as bool;
    } catch (_) {
      return true;
    }
  }

  int get intervalMinutes {
    try {
      final box = Hive.box('settings');
      return box.get(_keyInterval, defaultValue: defaultIntervalMinutes) as int;
    } catch (_) {
      return defaultIntervalMinutes;
    }
  }

  DateTime? get lastShownTime {
    try {
      final box = Hive.box('settings');
      final ms = box.get(_keyLastShown) as int?;
      if (ms == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      return null;
    }
  }

  DateTime? get snoozeUntil {
    try {
      final box = Hive.box('settings');
      final ms = box.get(_keySnoozeUntil) as int?;
      if (ms == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (_) {
      return null;
    }
  }

  PopupContentType get contentType {
    try {
      final box = Hive.box('settings');
      final idx = box.get(_keyContentType, defaultValue: 2) as int;
      return PopupContentType.values[idx.clamp(0, 2)];
    } catch (_) {
      return defaultContentType;
    }
  }

  // ── Setters ───────────────────────────────────────────────────

  Future<void> setEnabled(bool enabled) async {
    final box = Hive.box('settings');
    await box.put(_keyEnabled, enabled);
  }

  Future<void> setIntervalMinutes(int minutes) async {
    final box = Hive.box('settings');
    await box.put(_keyInterval, minutes);
  }

  Future<void> setContentType(PopupContentType type) async {
    final box = Hive.box('settings');
    await box.put(_keyContentType, type.index);
  }

  Future<void> snoozeFor(Duration duration) async {
    final box = Hive.box('settings');
    await box.put(
      _keySnoozeUntil,
      DateTime.now().add(duration).millisecondsSinceEpoch,
    );
  }

  // ── Content Generation ────────────────────────────────────────

  /// Returns either a [PopupQuranVerse] or a [PopupHadith] based on
  /// the user's content type preference and random selection.
  dynamic getRandomContent() {
    final type = contentType;

    if (type == PopupContentType.quran) {
      return _quranVerses[_random.nextInt(_quranVerses.length)];
    } else if (type == PopupContentType.hadith) {
      return _hadiths[_random.nextInt(_hadiths.length)];
    }

    // Both: 50/50 random selection.
    if (_random.nextBool()) {
      return _quranVerses[_random.nextInt(_quranVerses.length)];
    } else {
      return _hadiths[_random.nextInt(_hadiths.length)];
    }
  }

  /// Returns true if the content is a Quran verse.
  bool isQuranVerse(dynamic content) => content is PopupQuranVerse;

  // ── Timing Logic ──────────────────────────────────────────────

  /// Checks if enough time has elapsed since the last popup was shown.
  bool _shouldShowPopup() {
    if (!isEnabled) return false;

    // Check snooze.
    final snooze = snoozeUntil;
    if (snooze != null && DateTime.now().isBefore(snooze)) {
      return false;
    }

    final last = lastShownTime;
    if (last == null) return true;

    final elapsed = DateTime.now().difference(last);
    return elapsed.inMinutes >= intervalMinutes;
  }

  /// Checks if enough time has elapsed and shows popup if due.
  void checkAndShowPopup(BuildContext context) {
    if (_shouldShowPopup()) {
      showPopup(context);
    }
  }

  /// Shows the popup dialog immediately and records the time.
  void showPopup(BuildContext context) {
    // Record the time first.
    _recordShownTime();

    final content = getRandomContent();
    final isQuran = isQuranVerse(content);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      useSafeArea: true,
      builder: (_) => PopupDialog(
        content: content,
        isQuran: isQuran,
        onSnooze: () async {
          Navigator.of(context).pop();
          await snoozeFor(const Duration(hours: 1));
        },
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _recordShownTime() async {
    final box = Hive.box('settings');
    await box.put(_keyLastShown, DateTime.now().millisecondsSinceEpoch);
    // Clear snooze if active.
    if (snoozeUntil != null) {
      await box.delete(_keySnoozeUntil);
    }
  }

  /// Resets the last shown time (for testing purposes).
  Future<void> resetLastShownTime() async {
    final box = Hive.box('settings');
    await box.delete(_keyLastShown);
    await box.delete(_keySnoozeUntil);
  }
}
