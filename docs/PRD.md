# Minhaajulhudaa Qur'an & Hadith App — Product Requirements Document (PRD)

## 1. Overview

### 1.1 Product Vision
Minhaajulhudaa is a premium, fully offline, feature-rich Qur'an and Hadith mobile application built with Flutter. It aims to be the most comprehensive Islamic knowledge companion, combining world-class Qur'an reading, study, memorization, and Hadith exploration in a single frictionless experience — all working entirely without internet connectivity after initial install.

### 1.2 Target Users
- Huffadh (Qur'an memorizers) at all levels
- Students of Islamic knowledge
- Arabic language learners
- Scholars and teachers
- General Muslims seeking a premium Qur'an/Hadith app

### 1.3 Core Principles
- **100% Offline**: All data bundled — no internet required after install
- **Premium UI/UX**: Modern, prograde, frictionless design
- **Comprehensive**: Every Qur'an and Hadith science integrated seamlessly
- **Production Grade**: No mocks, stubs, or prototypes
- **Open Source**: Public repo, freely accessible

---

## 2. Feature Specifications

### 2.1 Qur'an Module

#### 2.1.1 Mushaf Reading Mode
- Exact Madani Mushaf-style page layout rendering
- Uthmanic script with proper page boundaries
- Surah headers with Makki/Madani classification
- Juz and Hizb markers
- Sajdah and pause marks (waqf)
- Page number navigation matching printed Mushaf
- Pinch-to-zoom with crisp rendering
- Night mode with eye-friendly colors

#### 2.1.2 Learning/Reading Mode
- Clean, line-by-line Arabic text display
- Color-coded tajweed rules (optional overlay)
- Adjustable font size
- Word spacing optimization for readability
- Verse highlighting on tap
- Continuous scroll or page-by-page navigation

#### 2.1.3 Word-by-Word Analysis
- Tap any word to reveal a detailed popup/bottom sheet:
  - Arabic word in Uthmanic script
  - Transliteration (Latin script)
  - Root letters (with clickable root exploration)
  - Part of speech (noun, verb, particle, etc.)
  - Morphological parsing (form, tense, gender, number)
  - Word translation in selected language
  - Occurrences in the Qur'an (count and list of verses)
  - Related words from the same root

#### 2.1.4 Translations
- Multiple translations per ayah (side-by-side or stacked)
- 20+ languages supported (bundled offline)
- Toggle translations on/off
- Per-ayah translation selection
- Translation comparison mode

#### 2.1.5 Tafseer & Sharh
- Multiple tafseer sources bundled:
  - Tafseer Ibn Kathir (English)
  - Tafseer As-Sa'di
  - Tafseer Al-Muyassar
  - Tafseer Al-Jalalayn
  - Additional tafseer as data permits
- Tafseer viewable per ayah, per surah, or full surah
- Tafseer linked from word analysis
- Inline tafseer display option

#### 2.1.6 Audio System
- Multiple reciters bundled or downloadable:
  - Sheikh Mishary Rashid Alafasy
  - Sheikh Abdul Basit (Mujawwad & Murattal)
  - Sheikh Hudhaify
  - Sheikh Sudais
  - Sheikh Minshawi
  - Additional reciters as space permits
- Audio playback controls (play/pause, next/previous ayah)
- Ayah-by-ayah highlighting synchronized with audio
- Word-by-word audio highlighting (for segmented recitations)
- Auto-download on first play (background download)
- Caching system for offline playback
- Download manager with progress tracking
- Repeat ayah/surah/range functionality
- Playback speed control (0.5x to 2x)
- Background playback (audio service)

#### 2.1.7 Search
- Full-text Arabic search across the Qur'an
- Search in translations
- Root-based search
- Search results with context (surah name, ayah number, surrounding text)
- Search history
- Advanced filters (by surah, juz, topic)

### 2.2 Hifdh (Memorization) Module

#### 2.2.1 Memorization Progress Tracker
- Track memorization by surah, juz, page, or custom range
- Visual progress indicators (percentage, color-coded)
- Streak tracking (daily review)
- Memorization timeline/history

#### 2.2.2 Revision Scheduling
- Spaced repetition system (SRS) for review
- Configurable review intervals
- Overdue revision alerts
- Daily revision queue
- Revision statistics

#### 2.2.3 Memorization Tools
- **Hide/Reveal Mode**: Gradually hide words, ayahs, or pages for self-testing
- **Test Mode**: Quiz on memorized portions
  - Listen mode (hear ayah, recite from memory)
  - Read mode (read partial ayah, complete from memory)
  - Write mode (type the ayah — optional)
- **Mistake Tracking**: Log mistakes, mark weak areas
- **Repeat Counter**: Track repetition count per ayah/surah
- **Voice Recording**: Record and compare recitation (future enhancement)

#### 2.2.4 Hifdh Dashboard
- Daily/weekly/monthly progress charts
- Memorization statistics (total ayahs, juz completed)
- Weak areas heatmap
- Goals setting (daily, weekly, monthly targets)
- Achievement/badge system

### 2.3 Hadith Module

#### 2.3.1 Hadith Collections
- Six major Hadith books (Kutub al-Sittah):
  - Sahih al-Bukhari
  - Sahih Muslim
  - Sunan Abu Dawud
  - Sunan al-Tirmidhi
  - Sunan al-Nasa'i
  - Sunan Ibn Majah
- Additional collections as data permits

#### 2.3.2 Hadith Reading
- Browse by book, chapter (kitab), and hadith number
- Arabic text (matn) with proper formatting
- Translation in multiple languages
- Hadith grading (sahih, hasan, da'if)
- Narrator chain (isnad) display
- Cross-references to Qur'anic verses

#### 2.3.3 Hadith Search
- Full-text search across all collections
- Search by narrator/companion
- Search by topic/theme
- Filter by collection, grading, book
- Search results with context

#### 2.3.4 Hadith Bookmarks & Notes
- Bookmark individual hadith
- Add personal notes to hadith
- Organize bookmarks by collection/topic
- Export/share bookmarks

### 2.4 Common Features

#### 2.4.1 Bookmarks
- Bookmark any ayah, page, or hadith
- Organize bookmarks in folders
- Add notes to bookmarks
- Sync-free (all local)

#### 2.4.2 Notes
- Rich text notes attached to any ayah, surah, or hadith
- Note management (create, edit, delete, search)
- Notes linked to content

#### 2.4.3 Settings
- Theme (Light, Dark, Auto)
- Arabic font selection and size
- Translation language selection
- Reciter selection
- Audio download preferences (Wi-Fi only, quality)
- Reading mode preference (Mushaf/Learning)
- Backup/restore data

#### 2.4.4 Navigation
- Bottom navigation bar (Qur'an, Hifdh, Hadith, More)
- Surah list with search
- Juz list
- Quick jump to last read position
- Breadcrumb navigation
- Smooth page transitions

---

## 3. Technical Architecture

### 3.1 Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (type-safe, testable, scalable)
- **Local Database**: Drift (SQLite) — type-safe, reactive
- **Audio**: just_audio + audio_service (background playback)
- **Routing**: go_router (declarative routing)
- **UI Components**: Custom premium components + Flutter Animate
- **Storage**: hive (key-value) + file system (audio files, images)
- **Dependency Injection**: get_it + injectable

### 3.2 Data Architecture

#### 3.2.1 Bundled Data (Assets)
- Qur'an Uthmanic text (JSON)
- Translations (JSON, multiple languages)
- Tafseer data (JSON)
- Word-by-word data (JSON)
- Hadith collections (JSON)
- Mushaf layout metadata (JSON)
- Audio segment timing data (JSON)

#### 3.2.2 Local Database (Drift/SQLite)
- Bookmarks table
- Notes table
- Memorization progress table
- Revision schedule table
- Mistake log table
- User preferences table
- Reading history table
- Search history table

#### 3.2.3 File System
- Downloaded audio files (MP3)
- Cached audio files
- User backups

### 3.3 Project Structure
```
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── core/
│   ├── constants/
│   ├── extensions/
│   ├── utils/
│   └── services/
├── data/
│   ├── local/
│   └── models/
├── features/
│   ├── quran/
│   ├── hifdh/
│   ├── hadith/
│   └── settings/
└── main.dart
```

### 3.4 Data Sources

#### 3.4.1 Qur'an Data
- **QUL (qul.tarteel.ai)**: Primary source for:
  - Uthmanic & IndoPak scripts
  - 204+ translations
  - 115+ tafseer
  - 73+ unsegmented + 58+ segmented audio
  - 20+ Mushaf layouts
  - Word-by-word data
  - Fonts

#### 3.4.2 Hadith Data
- **Open-Hadith-Data (github.com/mhashim6)**: 9 books with elaborations
- **hadith pub.dev package**: Bukhari, Muslim, Abu Dawud, Tirmidhi, Nasa'i, Ibn Majah

#### 3.4.3 Audio Data
- Audio files from QUL or public sources (MP3 format)
- Segment timing data for word-by-word sync

### 3.5 UI/UX Design System

#### 3.5.1 Design Principles
- Clean, minimal, premium feel
- Dark and light themes with smooth transitions
- RTL-first design (Arabic content primary)
- Generous whitespace
- Consistent typography scale
- Subtle animations and micro-interactions
- Haptic feedback on key actions

#### 3.5.2 Color Palette
- **Primary**: Deep teal/emerald (Islamic aesthetic)
- **Secondary**: Gold/amber accent
- **Background**: Warm white (light) / Deep navy (dark)
- **Text**: Rich black (light) / Soft white (dark)
- **Arabic Text**: Distinct serif-style rendering

#### 3.5.3 Typography
- Arabic: Noto Naskh Arabic / Amiri / Scheherazade New
- Latin: Inter / Poppins
- Monospace (for references): JetBrains Mono

---

## 4. CI/CD & Release

### 4.1 GitHub Actions Workflow
- Triggered on version tags (v*) and manual dispatch
- Build signed release APK
- Auto-publish to GitHub Releases
- Keystore generated and managed via GitHub Secrets
- PAT stored as GitHub Secret (never in codebase)

### 4.2 Signing
- Release keystore with dedicated alias
- Signing credentials in GitHub Secrets:
  - KEYSTORE_BASE64
  - KEYSTORE_PASSWORD
  - KEY_ALIAS
  - KEY_PASSWORD

### 4.3 Release Process
1. Developer pushes version tag (e.g., `v0.1.0`)
2. GitHub Actions builds APK
3. APK signed with release keystore
4. Published to GitHub Releases page
5. Users download directly from GitHub

---

## 5. Non-Functional Requirements

### 5.1 Performance
- App cold start < 2 seconds
- Surah loading < 500ms
- Search results < 200ms
- Smooth 60fps scrolling
- Audio playback start < 300ms

### 5.2 Storage
- Base APK size target: < 50MB (without audio)
- Audio files: Downloadable on demand
- Total with all audio: ~2-4GB

### 5.3 Compatibility
- Minimum Android SDK: 21 (Android 5.0)
- Target Android SDK: 34
- Supports ARM64 and ARMv7 architectures

---

## 6. Milestones

### M1: Foundation (v0.1.0)
- Project setup, architecture, navigation
- Qur'an text display (Uthmanic)
- Surah list with search
- Basic bookmarks
- GitHub Actions workflow

### M2: Study Features (v0.2.0)
- Word-by-word analysis
- Translations (English + 2 others)
- Tafseer (Ibn Kathir)
- Audio playback with download/cache

### M3: Hifdh Module (v0.3.0)
- Memorization progress tracker
- Hide/Reveal mode
- Revision scheduling (SRS)
- Hifzh dashboard

### M4: Hadith Module (v0.4.0)
- Hadith collections (Bukhari, Muslim)
- Browse by book/chapter
- Hadith search
- Bookmarks & notes

### M5: Polish & Expand (v0.5.0)
- Additional tafseer and translations
- More reciters
- Advanced Hifdh tools
- UI/UX refinement
- More hadith collections
