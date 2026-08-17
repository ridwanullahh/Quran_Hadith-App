import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// ═══════════════════════════════════════════════════════════════════
// Notification Data
// ═══════════════════════════════════════════════════════════════════

class NotificationSettings {
  final bool morningEnabled;
  final bool eveningEnabled;
  final bool fridayEnabled;
  final TimeOfDay morningTime;
  final TimeOfDay eveningTime;
  final bool permissionsGranted;

  const NotificationSettings({
    this.morningEnabled = true,
    this.eveningEnabled = true,
    this.fridayEnabled = true,
    this.morningTime = const TimeOfDay(hour: 7, minute: 0),
    this.eveningTime = const TimeOfDay(hour: 19, minute: 0),
    this.permissionsGranted = false,
  });

  NotificationSettings copyWith({
    bool? morningEnabled,
    bool? eveningEnabled,
    bool? fridayEnabled,
    TimeOfDay? morningTime,
    TimeOfDay? eveningTime,
    bool? permissionsGranted,
  }) {
    return NotificationSettings(
      morningEnabled: morningEnabled ?? this.morningEnabled,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      fridayEnabled: fridayEnabled ?? this.fridayEnabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Ayah of the Day Collection
// ═══════════════════════════════════════════════════════════════════

const List<Map<String, String>> _ayahOfTheDayCollection = [
  {'arabic': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ', 'english': 'In the name of Allah, the Most Gracious, the Most Merciful.', 'ref': 'Al-Fatiha 1:1'},
  {'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'english': 'All praise is due to Allah, Lord of the worlds.', 'ref': 'Al-Fatiha 1:2'},
  {'arabic': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ', 'english': 'Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence.', 'ref': 'Al-Baqarah 2:255'},
  {'arabic': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا', 'english': 'And whoever fears Allah — He will make for him a way out.', 'ref': 'At-Talaq 65:2'},
  {'arabic': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'english': 'And whoever relies upon Allah — then He is sufficient for him.', 'ref': 'At-Talaq 65:3'},
  {'arabic': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'english': 'Indeed, with hardship comes ease.', 'ref': 'Ash-Sharh 94:6'},
  {'arabic': 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَى', 'english': 'And your Lord is going to give you, and you will be satisfied.', 'ref': 'Ad-Duha 93:5'},
  {'arabic': 'وَقُل رَّبِّ زِدْنِي عِلْمًا', 'english': 'And say: My Lord, increase me in knowledge.', 'ref': 'Ta-Ha 20:114'},
  {'arabic': 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ', 'english': 'Do not lose heart or grieve, for you will have the upper hand, if you are believers.', 'ref': 'Al-Imran 3:139'},
  {'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي', 'english': 'My Lord, expand for me my breast and ease for me my task.', 'ref': 'Ta-Ha 20:25-26'},
];

// ═══════════════════════════════════════════════════════════════════
// Notification Provider
// ═══════════════════════════════════════════════════════════════════

/// Lazily-initialized, shared plugin instance. Initialized on first access
/// (rather than in a Riverpod provider) because [NotificationSettingsNotifier]
/// is constructed outside of a ProviderScope in some flows (e.g. main.dart
/// startup hooks use a fresh ProviderContainer).
FlutterLocalNotificationsPlugin? _sharedPlugin;
bool _pluginInitAttempted = false;

/// Get the shared, initialized [FlutterLocalNotificationsPlugin] instance.
/// On first call, creates and initializes the plugin. If initialization
/// fails, returns the uninitialized instance (scheduling calls will be
/// no-ops on platforms that don't support notifications).
FlutterLocalNotificationsPlugin getSharedNotificationsPlugin() {
  if (_sharedPlugin != null) return _sharedPlugin!;
  if (_pluginInitAttempted) return _sharedPlugin ?? FlutterLocalNotificationsPlugin();
  _pluginInitAttempted = true;
  _sharedPlugin = FlutterLocalNotificationsPlugin();
  _sharedPlugin!.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );
  return _sharedPlugin!;
}

final flutterLocalNotificationsPlugin = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return getSharedNotificationsPlugin();
});

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    try {
      final box = Hive.box('settings');
      final mEnabled = box.get('notif_morning_enabled', defaultValue: true) as bool;
      final eEnabled = box.get('notif_evening_enabled', defaultValue: true) as bool;
      final fEnabled = box.get('notif_friday_enabled', defaultValue: true) as bool;
      final mHour = box.get('notif_morning_hour', defaultValue: 7) as int;
      final mMin = box.get('notif_morning_min', defaultValue: 0) as int;
      final eHour = box.get('notif_evening_hour', defaultValue: 19) as int;
      final eMin = box.get('notif_evening_min', defaultValue: 0) as int;
      final perm = box.get('notif_permissions', defaultValue: false) as bool;

      state = NotificationSettings(
        morningEnabled: mEnabled,
        eveningEnabled: eEnabled,
        fridayEnabled: fEnabled,
        morningTime: TimeOfDay(hour: mHour, minute: mMin),
        eveningTime: TimeOfDay(hour: eHour, minute: eMin),
        permissionsGranted: perm,
      );
    } catch (_) {}
  }

  Future<void> _saveSettings() async {
    final box = Hive.box('settings');
    await box.put('notif_morning_enabled', state.morningEnabled);
    await box.put('notif_evening_enabled', state.eveningEnabled);
    await box.put('notif_friday_enabled', state.fridayEnabled);
    await box.put('notif_morning_hour', state.morningTime.hour);
    await box.put('notif_morning_min', state.morningTime.minute);
    await box.put('notif_evening_hour', state.eveningTime.hour);
    await box.put('notif_evening_min', state.eveningTime.minute);
    await box.put('notif_permissions', state.permissionsGranted);
  }

  Future<bool> requestPermissions() async {
    final plugin = getSharedNotificationsPlugin();
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission() ?? false;
      state = state.copyWith(permissionsGranted: granted);
      await _saveSettings();
      return granted;
    }
    return true;
  }

  Future<void> toggleMorning(bool enabled) async {
    state = state.copyWith(morningEnabled: enabled);
    await _saveSettings();
    if (enabled) {
      await scheduleMorningNotification();
    } else {
      await cancelNotification(0);
    }
  }

  Future<void> toggleEvening(bool enabled) async {
    state = state.copyWith(eveningEnabled: enabled);
    await _saveSettings();
    if (enabled) {
      await scheduleEveningNotification();
    } else {
      await cancelNotification(1);
    }
  }

  Future<void> toggleFriday(bool enabled) async {
    state = state.copyWith(fridayEnabled: enabled);
    await _saveSettings();
    if (enabled) {
      await scheduleFridayNotification();
    } else {
      await cancelNotification(2);
    }
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    state = state.copyWith(morningTime: time);
    await _saveSettings();
    if (state.morningEnabled) {
      await scheduleMorningNotification();
    }
  }

  Future<void> setEveningTime(TimeOfDay time) async {
    state = state.copyWith(eveningTime: time);
    await _saveSettings();
    if (state.eveningEnabled) {
      await scheduleEveningNotification();
    }
  }

  Future<void> scheduleMorningNotification() async {
    final plugin = getSharedNotificationsPlugin();
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day,
      state.morningTime.hour, state.morningTime.minute,
    );
    final scheduledTime = scheduled.isAfter(now) ? scheduled : scheduled.add(const Duration(days: 1));

    final ayah = _ayahOfTheDayCollection[now.day % _ayahOfTheDayCollection.length];

    await plugin.zonedSchedule(
      0,
      'Ayah of the Day',
      '${ayah['english']}\n\n${ayah['arabic']}\n- ${ayah['ref']}',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_channel',
          'Morning Ayah',
          channelDescription: 'Daily Quran verse notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleEveningNotification() async {
    final plugin = getSharedNotificationsPlugin();
    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day,
      state.eveningTime.hour, state.eveningTime.minute,
    );
    final scheduledTime = scheduled.isAfter(now) ? scheduled : scheduled.add(const Duration(days: 1));

    await plugin.zonedSchedule(
      1,
      'Hadith of the Day',
      'Read today\'s authentic hadith and increase your knowledge.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'evening_channel',
          'Evening Hadith',
          channelDescription: 'Daily hadith notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleFridayNotification() async {
    final plugin = getSharedNotificationsPlugin();
    final now = tz.TZDateTime.now(tz.local);
    var nextFriday = tz.TZDateTime(tz.local, now.year, now.month, now.day);
    while (nextFriday.weekday != DateTime.friday || nextFriday.isBefore(now)) {
      nextFriday = nextFriday.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      2,
      'Friday Reminder - Surah Al-Kahf',
      'Read Surah Al-Kahf today for its immense blessings.',
      nextFriday,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'friday_channel',
          'Friday Reminder',
          channelDescription: 'Weekly Friday Surah Al-Kahf reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    final plugin = getSharedNotificationsPlugin();
    await plugin.cancel(id);
  }

  Future<void> scheduleAll() async {
    if (state.morningEnabled) await scheduleMorningNotification();
    if (state.eveningEnabled) await scheduleEveningNotification();
    if (state.fridayEnabled) await scheduleFridayNotification();
  }
}
