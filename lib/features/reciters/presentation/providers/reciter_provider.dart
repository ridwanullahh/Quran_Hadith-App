import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

// ── Models ──────────────────────────────────────────────────────────

class Reciter {
 final String id;
 final String arabicName;
 final String englishName;
 final String style; // Murattal or Mujawwad
 final bool hasMurattal;
 final bool hasMujawwad;

 const Reciter({
  required this.id,
  required this.arabicName,
  required this.englishName,
  required this.style,
  required this.hasMurattal,
  required this.hasMujawwad,
 });
}

// ── Extended reciter list with Arabic names and style details ─────

const List<Reciter> kReciters = [
 Reciter(
  id: 'mishary',
  arabicName: 'مشاري راشد العفاسي',
  englishName: 'Mishary Rashid Alafasy',
  style: 'Mujawwad',
  hasMurattal: false,
  hasMujawwad: true,
 ),
 Reciter(
  id: 'abdulbasit',
  arabicName: 'عبد الباسط عبد الصمد',
  englishName: 'Abdul Basit',
  style: 'Mujawwad',
  hasMurattal: false,
  hasMujawwad: true,
 ),
 Reciter(
  id: 'husary',
  arabicName: 'محمود خليل الحصري',
  englishName: 'Mahmoud Khalil Al-Husary',
  style: 'Mujawwad',
  hasMurattal: true,
  hasMujawwad: true,
 ),
 Reciter(
  id: 'minshawi',
  arabicName: 'محمد صديق المنشاوي',
  englishName: 'Mohamed Siddiq El-Minshawi',
  style: 'Mujawwad',
  hasMurattal: true,
  hasMujawwad: true,
 ),
 Reciter(
  id: 'abdurrahman',
  arabicName: 'عبد الرحمن السديس',
  englishName: 'Abdur-Rahman As-Sudais',
  style: 'Mujawwad',
  hasMurattal: false,
  hasMujawwad: true,
 ),
 Reciter(
  id: 'maqbool',
  arabicName: 'مأمول مقبول',
  englishName: 'Mahmoud Ali El-Banna',
  style: 'Murattal',
  hasMurattal: true,
  hasMujawwad: false,
 ),
 Reciter(
  id: 'ghamidi',
  arabicName: 'سعد الغامدي',
  englishName: 'Saad Al-Ghamdi',
  style: 'Murattal',
  hasMurattal: true,
  hasMujawwad: false,
 ),
 Reciter(
  id: 'banna',
  arabicName: 'محمود علي البنا',
  englishName: 'Mahmoud Ali El-Banna',
  style: 'Murattal',
  hasMurattal: true,
  hasMujawwad: false,
 ),
 Reciter(
  id: 'aishe',
  arabicName: 'ماهر المعيقلي',
  englishName: "Mahir Al-Mu'aiqly",
  style: 'Mujawwad',
  hasMurattal: false,
  hasMujawwad: true,
 ),
 Reciter(
  id: 'shuraim',
  arabicName: 'سعود الشريم',
  englishName: 'Abdulrahman As-Sudais & Saud Ash-Shuraim',
  style: 'Mujawwad',
  hasMurattal: false,
  hasMujawwad: true,
 ),
];

// ── Download status per reciter ───────────────────────────────────

enum ReciterDownloadStatus { notStarted, downloading, downloaded, error }

class ReciterDownloadInfo {
 final String reciterId;
 final ReciterDownloadStatus status;
 final int downloadedSurahs;
 final int totalSurahs;
 final double storageUsedMb;
 final double totalSizeMb;

 const ReciterDownloadInfo({
  required this.reciterId,
  this.status = ReciterDownloadStatus.notStarted,
  this.downloadedSurahs = 0,
  this.totalSurahs = 114,
  this.storageUsedMb = 0,
  this.totalSizeMb = 0,
 });

 double get progress => totalSurahs > 0 ? downloadedSurahs / totalSurahs : 0;
 bool get isFullyDownloaded => downloadedSurahs >= totalSurahs;
}

// ── State ──────────────────────────────────────────────────────────

class ReciterState {
 final String defaultReciterId;
 final Set<String> favoriteIds;
 final Map<String, ReciterDownloadInfo> downloadInfo;

 const ReciterState({
  this.defaultReciterId = 'mishary',
  this.favoriteIds = const {},
  this.downloadInfo = const {},
 });

 ReciterState copyWith({
  String? defaultReciterId,
  Set<String>? favoriteIds,
  Map<String, ReciterDownloadInfo>? downloadInfo,
 }) {
  return ReciterState(
   defaultReciterId: defaultReciterId ?? this.defaultReciterId,
   favoriteIds: favoriteIds ?? this.favoriteIds,
   downloadInfo: downloadInfo ?? this.downloadInfo,
  );
 }

 bool isFavorite(String id) => favoriteIds.contains(id);
 bool isDefault(String id) => defaultReciterId == id;
 ReciterDownloadInfo? getDownloadInfo(String id) => downloadInfo[id];
}

// ── Notifier ───────────────────────────────────────────────────────

class ReciterNotifier extends StateNotifier<ReciterState> {
 ReciterNotifier() : super(const ReciterState());

 void toggleFavorite(String id) {
  final current = Set<String>.from(state.favoriteIds);
  if (current.contains(id)) {
   current.remove(id);
  } else {
   current.add(id);
  }
  state = state.copyWith(favoriteIds: current);
 }

 void setDefault(String id) {
  state = state.copyWith(defaultReciterId: id);
 }

 void startDownload(String id) {
  final info = state.downloadInfo[id] ?? ReciterDownloadInfo(reciterId: id);
  state = state.copyWith(
   downloadInfo: {
    ...state.downloadInfo,
    id: ReciterDownloadInfo(
     reciterId: id,
     status: ReciterDownloadStatus.downloading,
     downloadedSurahs: info.downloadedSurahs,
     totalSurahs: 114,
     storageUsedMb: info.storageUsedMb,
     totalSizeMb: 720.0,
    ),
   },
  );
 }

 void updateDownloadProgress(String id, int downloaded, double storageMb) {
  final info = state.downloadInfo[id] ?? ReciterDownloadInfo(reciterId: id);
  state = state.copyWith(
   downloadInfo: {
    ...state.downloadInfo,
    id: ReciterDownloadInfo(
     reciterId: id,
     status: ReciterDownloadStatus.downloading,
     downloadedSurahs: downloaded,
     totalSurahs: 114,
     storageUsedMb: storageMb,
     totalSizeMb: 720.0,
    ),
   },
  );
 }

 void completeDownload(String id) {
  final info = state.downloadInfo[id] ?? ReciterDownloadInfo(reciterId: id);
  state = state.copyWith(
   downloadInfo: {
    ...state.downloadInfo,
    id: ReciterDownloadInfo(
     reciterId: id,
     status: ReciterDownloadStatus.downloaded,
     downloadedSurahs: 114,
     totalSurahs: 114,
     storageUsedMb: 720.0,
     totalSizeMb: 720.0,
    ),
   },
  );
 }

 void cancelDownload(String id) {
  final info = state.downloadInfo[id];
  if (info != null) {
   state = state.copyWith(
    downloadInfo: {
     ...state.downloadInfo,
     id: ReciterDownloadInfo(
      reciterId: id,
      status: info.downloadedSurahs > 0 ? ReciterDownloadStatus.notStarted : ReciterDownloadStatus.notStarted,
      downloadedSurahs: info.downloadedSurahs,
      totalSurahs: 114,
      storageUsedMb: info.storageUsedMb,
      totalSizeMb: 720.0,
     ),
    },
   );
  }
 }
}

// ── Providers ──────────────────────────────────────────────────────

final reciterProvider = StateNotifierProvider<ReciterNotifier, ReciterState>(
 (ref) => ReciterNotifier(),
);

final recitersListProvider = Provider<List<Reciter>>((ref) => kReciters);

final favoriteRecitersProvider = Provider<List<Reciter>>((ref) {
 final state = ref.watch(reciterProvider);
 return kReciters.where((r) => state.isFavorite(r.id)).toList();
});

final defaultReciterProvider = Provider<Reciter?>((ref) {
 final state = ref.watch(reciterProvider);
 return kReciters.where((r) => r.id == state.defaultReciterId).firstOrNull;
});
