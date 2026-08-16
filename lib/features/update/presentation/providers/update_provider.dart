import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  // IMPORTANT: this URL must match the actual GitHub repository slug.
  // The repo is github.com/ridwanullahh/Quran_Hadith-App — note the
  // capital Q, H, A and the underscore. The previous URL
  // (minhaajulhudaa/quran-hadith-app) returned 404, which silently broke
  // the auto-update check on every app launch.
  static const String _githubApiUrl =
      'https://api.github.com/repos/ridwanullahh/Quran_Hadith-App/releases/latest';

  UpdateNotifier() : _dio = Dio(), super(const UpdateState()) {
    _loadCurrentVersion();
  }

  /// Read the actual installed app version from the OS via [PackageInfo].
  ///
  /// This is the authoritative source — it reflects exactly what the user
  /// installed from the APK's pubspec version. We previously read a
  /// Hive-stored string with default '0.1.0', which was wrong because:
  ///   1. It never matched the actual installed version after an update.
  ///   2. The default '0.1.0' was higher than the v0.0.1 release tag,
  ///      causing the update check to think the installed version was
  ///      newer than the available release.
  Future<void> _loadCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = '${info.version}+${info.buildNumber}';
      // Strip the build number for the comparison — we compare against
      // GitHub tag names like "v0.0.1" which don't include build numbers.
      final cleanVersion = info.version;
      state = state.copyWith(currentVersion: cleanVersion);

      // Persist to Hive for debugging / fast access (but never read it
      // back as the source of truth — always re-read from PackageInfo).
      final box = Hive.box('settings');
      await box.put('current_version', version);
    } catch (e) {
      debugPrint('[UpdateNotifier] _loadCurrentVersion failed: $e');
      // Fall back to a safe default that is older than any real release
      // so the update check still offers the latest release.
      state = state.copyWith(currentVersion: '0.0.0');
    }
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

  /// Download the APK from the release to a writable app-private
  /// directory and trigger the Android package installer intent.
  ///
  /// Returns a human-readable status message suitable for a SnackBar.
  /// On success, the system Package Installer UI is launched — the user
  /// confirms the install and Android replaces the existing app.
  Future<String> downloadAndInstallApk() async {
    final release = state.latestRelease;
    if (release == null || release.apkDownloadUrl == null) {
      return 'No update available to download.';
    }

    state = state.copyWith(isDownloading: true, downloadProgress: 0.0, error: null);

    String? savedPath;
    try {
      // Use getApplicationDocumentsDirectory() — app-private, always
      // writable, no storage permission needed on Android 10+.
      final dir = await getApplicationDocumentsDirectory();
      final fileName = release.apkDownloadUrl!.split('/').last;
      final downloadPath = p.join(dir.path, 'updates', fileName);
      // Ensure the 'updates' subdirectory exists.
      await Directory(p.dirname(downloadPath)).create(recursive: true);

      await _dio.download(
        release.apkDownloadUrl!,
        downloadPath,
        options: Options(
          headers: const {'Accept': 'application/octet-stream'},
          followRedirects: true,
          maxRedirects: 5,
          receiveTimeout: const Duration(minutes: 10),
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(
              downloadProgress: received / total,
            );
          }
        },
      );

      savedPath = downloadPath;
      state = state.copyWith(
        isDownloading: false,
        downloadProgress: 1.0,
      );

      // Verify the file was actually written and is non-empty.
      final file = File(savedPath);
      if (!await file.exists() || await file.length() == 0) {
        return 'Download failed: APK file is empty or missing.';
      }

      // Trigger the Android package installer via open_filex. This
      // launches the system "Install / Update app" dialog. The user
      // must confirm; we cannot silently install.
      final result = await OpenFilex.open(savedPath, type: 'application/vnd.android.package-archive');
      if (result.type != ResultType.done) {
        return 'Could not launch installer: ${result.message}';
      }
      return 'Update downloaded. Confirm the install in the system dialog.';
    } on DioException catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: 'Network error: ${e.message}',
      );
      return 'Download failed (network): ${e.message}';
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: 'Error: ${e.toString()}',
      );
      return 'Download failed: $e';
    }
  }

  /// Legacy alias kept for backward compatibility with any caller that
  /// still uses the old [downloadApk] name. Delegates to
  /// [downloadAndInstallApk].
  Future<String?> downloadApk({String? savePath}) async {
    return downloadAndInstallApk();
  }

  /// Dismiss the update notification
  void dismissUpdate() {
    state = state.copyWith(hasUpdate: false);
  }
}
