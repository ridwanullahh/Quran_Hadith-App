# Minhaajulhudaa App — TODO Tracker

> بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ

## Status Legend
- [ ] Pending | [~] In Progress | [x] Done | [!] Blocked

---

## M1: Foundation (v0.1.0)

### 1.0 Project Setup
- [x] 1.0.1 Create Flutter project structure
- [x] 1.0.2 Configure pubspec.yaml with all dependencies
- [ ] 1.0.3 Set up project directory structure (lib/app, lib/core, lib/data, lib/features)
- [ ] 1.0.4 Configure app theme (light/dark, typography, colors)
- [ ] 1.0.5 Set up Riverpod providers structure
- [ ] 1.0.6 Configure go_router with all routes
- [ ] 1.0.7 Set up Drift database with all tables
- [ ] 1.0.8 Create app entry point and initialization

### 1.1 Navigation & Shell
- [ ] 1.1.1 Design and implement bottom navigation shell
- [ ] 1.1.2 Implement main tabs: Qur'an, Hifdh, Hadith, More
- [ ] 1.1.3 Add smooth page transition animations
- [ ] 1.1.4 Implement RTL layout support
- [ ] 1.1.5 Add splash screen with branding

### 1.2 Qur'an Core
- [ ] 1.2.1 Prepare and bundle Qur'an Uthmanic text JSON data
- [ ] 1.2.2 Create Surah metadata model (name, number, ayah count, type, juz)
- [ ] 1.2.3 Build Surah list screen with search and filtering
- [ ] 1.2.4 Build Juz list screen
- [ ] 1.2.5 Implement Uthmanic text rendering widget (Arabic, RTL)
- [ ] 1.2.6 Build Surah reading screen (Learning mode)
- [ ] 1.2.7 Implement ayah numbering and juz/hizb markers
- [ ] 1.2.8 Add reading history tracking (last read position)

### 1.3 Data & Storage
- [ ] 1.3.1 Implement Drift database migrations
- [ ] 1.3.2 Create bookmark model and storage
- [ ] 1.3.3 Build bookmark UI (add, remove, list, folders)
- [ ] 1.3.4 Create notes model and storage
- [ ] 1.3.5 Build notes UI (create, edit, delete)
- [ ] 1.3.6 Implement last-read position persistence

### 1.4 CI/CD
- [ ] 1.4.1 Create GitHub Actions workflow for Flutter APK build
- [ ] 1.4.2 Configure keystore generation in workflow
- [ ] 1.4.3 Set up GitHub Secrets for signing
- [ ] 1.4.4 Configure release upload to GitHub Releases
- [ ] 1.4.5 Test end-to-end build and release on tag push

---

## M2: Study Features (v0.2.0)

### 2.0 Word-by-Word Analysis
- [ ] 2.0.1 Prepare and bundle word-by-word JSON data
- [ ] 2.0.2 Create word analysis data model
- [ ] 2.0.3 Build word tap detection on Qur'an text
- [ ] 2.0.4 Design and build word detail bottom sheet
  - [ ] Arabic word display
  - [ ] Transliteration
  - [ ] Root letters
  - [ ] Part of speech
  - [ ] Morphological info
  - [ ] Translation
- [ ] 2.0.5 Implement root exploration (same-root word list)
- [ ] 2.0.6 Add word occurrence count and navigation

### 2.1 Translations
- [ ] 2.1.1 Prepare and bundle translation JSON data (3+ languages)
- [ ] 2.1.2 Build translation display alongside Arabic text
- [ ] 2.1.3 Implement translation toggle (on/off)
- [ ] 2.1.4 Add language selection in settings
- [ ] 2.1.5 Implement stacked/side-by-side translation views

### 2.2 Tafseer
- [ ] 2.2.1 Prepare and bundle Tafseer Ibn Kathir JSON data
- [ ] 2.2.2 Build tafseer display panel (per-ayah, per-surah)
- [ ] 2.2.3 Implement tafseer source selector
- [ ] 2.2.4 Add inline tafseer view option
- [ ] 2.2.5 Bundle and integrate additional tafseer sources

### 2.3 Audio System
- [ ] 2.3.1 Prepare audio file list and segment data
- [ ] 2.3.2 Implement audio download manager with progress
- [ ] 2.3.3 Build audio player service (play, pause, next, prev)
- [ ] 2.3.4 Implement audio caching (auto-cache on first play)
- [ ] 2.3.5 Build audio player UI bar (mini player + full screen)
- [ ] 2.3.6 Implement ayah-by-ayah audio highlighting
- [ ] 2.3.7 Implement word-by-word audio sync (for segmented recitations)
- [ ] 2.3.8 Add playback speed control (0.5x - 2x)
- [ ] 2.3.9 Implement repeat functionality (ayah, range, surah)
- [ ] 2.3.10 Implement background audio playback (audio_service)
- [ ] 2.3.11 Add reciter selection UI
- [ ] 2.3.12 Add download manager screen with per-surah downloads

---

## M3: Hifdh Module (v0.3.0)

### 3.0 Progress Tracking
- [ ] 3.0.1 Create memorization progress data model
- [ ] 3.0.2 Build progress entry UI (select surah/juz/page/range)
- [ ] 3.0.3 Implement progress visualization (percentage bars, color coding)
- [ ] 3.0.4 Build memorization overview screen (total, by juz, by surah)
- [ ] 3.0.5 Track and display memorization streak

### 3.1 Revision Scheduling
- [ ] 3.1.1 Implement spaced repetition algorithm (SRS)
- [ ] 3.1.2 Build daily revision queue
- [ ] 3.1.3 Create revision notification system
- [ ] 3.1.4 Build revision history and statistics
- [ ] 3.1.5 Implement configurable review intervals

### 3.2 Memorization Tools
- [ ] 3.2.1 Build Hide/Reveal mode
  - [ ] Hide words progressively
  - [ ] Hide ayahs
  - [ ] Hide pages
  - [ ] Tap to reveal
- [ ] 3.2.2 Build Test Mode
  - [ ] Listen mode (audio prompt, recite from memory)
  - [ ] Read mode (partial text, complete from memory)
- [ ] 3.2.3 Implement mistake tracking and logging
- [ ] 3.2.4 Build weak areas visualization
- [ ] 3.2.5 Add repeat counter per ayah/surah

### 3.3 Hifdh Dashboard
- [ ] 3.3.1 Build dashboard with progress charts
- [ ] 3.3.2 Add daily/weekly/monthly statistics
- [ ] 3.3.3 Build weak areas heatmap
- [ ] 3.3.4 Implement goal setting (daily, weekly, monthly)
- [ ] 3.3.5 Add achievement/badge system

---

## M4: Hadith Module (v0.4.0)

### 4.0 Hadith Data & Collections
- [ ] 4.0.1 Prepare and bundle Bukhari JSON data
- [ ] 4.0.2 Prepare and bundle Muslim JSON data
- [ ] 4.0.3 Create hadith data models (collection, book, hadith)
- [ ] 4.0.4 Build hadith collections list screen
- [ ] 4.0.5 Build book (kitab) list screen per collection

### 4.1 Hadith Reading
- [ ] 4.1.1 Build hadith text display (Arabic + translation)
- [ ] 4.1.2 Implement hadith grading display
- [ ] 4.1.3 Build narrator chain (isnad) display
- [ ] 4.1.4 Add cross-references to Qur'anic verses
- [ ] 4.1.5 Implement chapter (kitab) browsing
- [ ] 4.1.6 Build hadith detail screen

### 4.2 Hadith Search
- [ ] 4.2.1 Implement full-text Arabic search
- [ ] 4.2.2 Add search by narrator/companion
- [ ] 4.2.3 Add search by topic/theme
- [ ] 4.2.4 Build search results with context
- [ ] 4.2.5 Add search filters (collection, grading, book)
- [ ] 4.2.6 Implement search history

### 4.3 Hadith Features
- [ ] 4.3.1 Add hadith bookmarks (reuse bookmark system)
- [ ] 4.3.2 Add hadith notes (reuse notes system)
- [ ] 4.3.3 Bundle additional hadith collections (Abu Dawud, etc.)

---

## M5: Polish & Expand (v0.5.0)

### 5.0 UI/UX Polish
- [ ] 5.0.1 Refine all animations and transitions
- [ ] 5.0.2 Add haptic feedback on key actions
- [ ] 5.0.3 Optimize scrolling performance for large lists
- [ ] 5.0.4 Implement adaptive UI for different screen sizes
- [ ] 5.0.5 Add onboarding flow for first-time users

### 5.1 Additional Content
- [ ] 5.1.1 Bundle more tafseer sources
- [ ] 5.1.2 Bundle more translation languages
- [ ] 5.1.3 Add more reciters
- [ ] 5.1.4 Add tajweed color-coded overlay
- [ ] 5.1.5 Bundle remaining hadith collections

### 5.2 Advanced Hifdh
- [ ] 5.2.1 Implement voice recording and comparison
- [ ] 5.2.2 Add advanced SRS customization
- [ ] 5.2.3 Build teacher/monitoring mode

### 5.3 Settings & Data
- [ ] 5.3.1 Implement full settings screen
- [ ] 5.3.2 Add backup/restore functionality
- [ ] 5.3.3 Add data export feature

---

## Summary

| Milestone | Tasks | Status |
|-----------|-------|--------|
| M1: Foundation | 30 | In Progress |
| M2: Study Features | 30 | Pending |
| M3: Hifdh Module | 22 | Pending |
| M4: Hadith Module | 18 | Pending |
| M5: Polish & Expand | 18 | Pending |
| **Total** | **118** | |
