import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';

// ═══════════════════════════════════════════════════════════════════
// Update Data Models
// ═══════════════════════════════════════════════════════════════════

class GitHubRelease {
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final String publishedAt;
  final String? apkDownloadUrl;
  final int? apkSizeBytes;

  const GitHubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.publishedAt,
    this.apkDownloadUrl,
    this.apkSizeBytes,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    String? apkUrl;
    int? apkSize;
    final assets = json['assets'] as List<dynamic>? ?? [];
    for (final asset in assets) {
      final assetMap = asset as Map<String, dynamic>;
      final name = (assetMap['name'] as String? ?? '').toLowerCase();
      if (name.endsWith('.apk') || name.contains('release')) {
        apkUrl = assetMap['browser_download_url'] as String?;
        apkSize = assetMap['size'] as int?;
        break;
      }
    }
    // Fallback: use first asset if no APK found
    if (apkUrl == null && assets.isNotEmpty) {
      final first = assets.first as Map<String, dynamic>;
      apkUrl = first['browser_download_url'] as String?;
      apkSize = first['size'] as int?;
    }

    return GitHubRelease(
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? '',
      apkDownloadUrl: apkUrl,
      apkSizeBytes: apkSize,
    );
  }
}

class UpdateState {
  final bool isChecking;
  final bool hasUpdate;
  final GitHubRelease? latestRelease;
  final String currentVersion;
  final String? error;
  final bool isDownloading;
  final double downloadProgress;

  const UpdateState({
    this.isChecking = false,
    this.hasUpdate = false,
    this.latestRelease,
    this.currentVersion = '0.1.0',
    this.error,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
  });

  UpdateState copyWith({
    bool? isChecking,
    bool? hasUpdate,
    GitHubRelease? latestRelease,
    String? currentVersion,
    String? error,
    bool? isDownloading,
    double? downloadProgress,
  }) {
    return UpdateState(
      isChecking: isChecking ?? this.isChecking,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      latestRelease: latestRelease ?? this.latestRelease,
      currentVersion: currentVersion ?? this.currentVersion,
      error: error,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Update Provider
// ═══════════════════════════════════════════════════════════════════

final updateProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier();
});

class UpdateNotifier extends StateNotifier<UpdateState> {
  final Dio _dio;
  static const String _githubApiUrl =
      'https://api.github.com/repos/minhaajulhudaa/quran-hadith-app/releases/latest';

  UpdateNotifier() : _dio = Dio(), super(const UpdateState()) {
    _loadCurrentVersion();
  }

  void _loadCurrentVersion() {
    try {
      final box = Hive.box('settings');
      final savedVersion = box.get('current_version', defaultValue: '0.1.0') as String;
      state = state.copyWith(currentVersion: savedVersion);
    } catch (_) {}
  }

  /// Parse semantic version string to comparable list of integers
  List<int> _parseVersion(String version) {
    final clean = version.replaceAll(RegExp(r'[^0-9.]'), '');
    return clean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// Compare two versions: returns true if available > current
  bool _isNewer(String available, String current) {
    final availParts = _parseVersion(available);
    final currParts = _parseVersion(current);
    for (var i = 0; i < 3; i++) {
      final a = i < availParts.length ? availParts[i] : 0;
      final c = i < currParts.length ? currParts[i] : 0;
      if (a > c) return true;
      if (a < c) return false;
    }
    return false;
  }

  /// Check GitHub for the latest release
  Future<void> checkForUpdate() async {
    state = state.copyWith(isChecking: true, error: null);

    try {
      final box = Hive.box('settings');
      final githubToken = box.get('github_pat') as String?;

      final options = Options(
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          if (githubToken != null && githubToken.isNotEmpty)
            'Authorization': 'Bearer $githubToken',
        },
      );

      final response = await _dio.get(_githubApiUrl, options: options);

      if (response.statusCode == 200) {
        final release = GitHubRelease.fromJson(
          response.data as Map<String, dynamic>,
        );

        final hasUpdate = _isNewer(release.tagName, state.currentVersion);

        state = state.copyWith(
          isChecking: false,
          hasUpdate: hasUpdate,
          latestRelease: release,
          error: null,
        );
      } else {
        state = state.copyWith(
          isChecking: false,
          error: 'GitHub API returned status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: 'Network error: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }

  /// Auto-check on app start (called from main.dart or app.dart)
  Future<void> autoCheckOnStart() async {
    try {
      final box = Hive.box('settings');
      final lastCheckStr = box.get('last_update_check') as String?;
      final lastCheck = lastCheckStr != null ? DateTime.parse(lastCheckStr) : null;

      // Only check once every 24 hours
      if (lastCheck != null && DateTime.now().difference(lastCheck).inHours < 24) {
        return;
      }

      await checkForUpdate();
      await box.put('last_update_check', DateTime.now().toIso8601String());
    } catch (_) {}
  }

  /// Download the APK from the release
  Future<String?> downloadApk({String? savePath}) async {
    final release = state.latestRelease;
    if (release == null || release.apkDownloadUrl == null) return null;

    state = state.copyWith(isDownloading: true, downloadProgress: 0.0);

    try {
      final response = await _dio.download(
        release.apkDownloadUrl!,
        savePath ?? '/tmp/quran_hadith_update.apk',
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(
              downloadProgress: received / total,
            );
          }
        },
      );

      state = state.copyWith(
        isDownloading: false,
        downloadProgress: 1.0,
      );

      return response.data;
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: 'Download failed: ${e.toString()}',
      );
      return null;
    }
  }

  /// Dismiss the update notification
  void dismissUpdate() {
    state = state.copyWith(hasUpdate: false);
  }
}
