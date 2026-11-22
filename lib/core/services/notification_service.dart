import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// User reminder preferences (stored as JSON in AppPreferences `reminders_config`).
class ReminderConfig {
  final bool water;
  final int waterEveryHours;
  final int waterStartHour;
  final int waterEndHour;
  final bool meals;
  final int breakfastHour;
  final int lunchHour;
  final int dinnerHour;
  final bool workout;
  final List<int> workoutWeekdays; // 1 = Monday … 7 = Sunday
  final int workoutHour;
  final int workoutMinute;
  final bool weighIn;
  final int weighInHour;

  const ReminderConfig({
    this.water = false,
    this.waterEveryHours = 2,
    this.waterStartHour = 9,
    this.waterEndHour = 21,
    this.meals = false,
    this.breakfastHour = 8,
    this.lunchHour = 13,
    this.dinnerHour = 20,
    this.workout = false,
    this.workoutWeekdays = const [1, 3, 5],
    this.workoutHour = 18,
    this.workoutMinute = 0,
    this.weighIn = false,
    this.weighInHour = 8,
  });

  ReminderConfig copyWith({
    bool? water,
    int? waterEveryHours,
    int? waterStartHour,
    int? waterEndHour,
    bool? meals,
    int? breakfastHour,
    int? lunchHour,
    int? dinnerHour,
    bool? workout,
    List<int>? workoutWeekdays,
    int? workoutHour,
    int? workoutMinute,
    bool? weighIn,
    int? weighInHour,
  }) =>
      ReminderConfig(
        water: water ?? this.water,
        waterEveryHours: waterEveryHours ?? this.waterEveryHours,
        waterStartHour: waterStartHour ?? this.waterStartHour,
        waterEndHour: waterEndHour ?? this.waterEndHour,
        meals: meals ?? this.meals,
        breakfastHour: breakfastHour ?? this.breakfastHour,
        lunchHour: lunchHour ?? this.lunchHour,
        dinnerHour: dinnerHour ?? this.dinnerHour,
        workout: workout ?? this.workout,
        workoutWeekdays: workoutWeekdays ?? this.workoutWeekdays,
        workoutHour: workoutHour ?? this.workoutHour,
        workoutMinute: workoutMinute ?? this.workoutMinute,
        weighIn: weighIn ?? this.weighIn,
        weighInHour: weighInHour ?? this.weighInHour,
      );

  Map<String, dynamic> toJson() => {
        'water': water,
        'waterEveryHours': waterEveryHours,
        'waterStartHour': waterStartHour,
        'waterEndHour': waterEndHour,
        'meals': meals,
        'breakfastHour': breakfastHour,
        'lunchHour': lunchHour,
        'dinnerHour': dinnerHour,
        'workout': workout,
        'workoutWeekdays': workoutWeekdays,
        'workoutHour': workoutHour,
        'workoutMinute': workoutMinute,
        'weighIn': weighIn,
        'weighInHour': weighInHour,
      };

  factory ReminderConfig.fromJson(Map<String, dynamic> j) {
    const d = ReminderConfig();
    return ReminderConfig(
      water: j['water'] as bool? ?? d.water,
      waterEveryHours: j['waterEveryHours'] as int? ?? d.waterEveryHours,
      waterStartHour: j['waterStartHour'] as int? ?? d.waterStartHour,
      waterEndHour: j['waterEndHour'] as int? ?? d.waterEndHour,
      meals: j['meals'] as bool? ?? d.meals,
      breakfastHour: j['breakfastHour'] as int? ?? d.breakfastHour,
      lunchHour: j['lunchHour'] as int? ?? d.lunchHour,
      dinnerHour: j['dinnerHour'] as int? ?? d.dinnerHour,
      workout: j['workout'] as bool? ?? d.workout,
      workoutWeekdays: (j['workoutWeekdays'] as List?)?.cast<int>() ?? d.workoutWeekdays,
      workoutHour: j['workoutHour'] as int? ?? d.workoutHour,
      workoutMinute: j['workoutMinute'] as int? ?? d.workoutMinute,
      weighIn: j['weighIn'] as bool? ?? d.weighIn,
      weighInHour: j['weighInHour'] as int? ?? d.weighInHour,
    );
  }

  static ReminderConfig decode(String? raw) {
    if (raw == null || raw.isEmpty) return const ReminderConfig();
    try {
      return ReminderConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ReminderConfig();
    }
  }

  String encode() => jsonEncode(toJson());

  /// Hours (inclusive range) at which a water reminder fires.
  List<int> waterHours() {
    final hours = <int>[];
    for (int h = waterStartHour; h <= waterEndHour; h += waterEveryHours.clamp(1, 12)) {
      hours.add(h);
    }
    return hours;
  }
}

/// Localised texts passed in from the UI (the service has no BuildContext).
class ReminderTexts {
  final String waterTitle, waterBody, mealTitle, breakfast, lunch, dinner, workoutTitle, workoutBody, weighTitle, weighBody;
  const ReminderTexts({
    required this.waterTitle,
    required this.waterBody,
    required this.mealTitle,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.workoutTitle,
    required this.workoutBody,
    required this.weighTitle,
    required this.weighBody,
  });
}

/// Abstraction so widget tests never touch the native plugin.
abstract class NotificationService {
  Future<void> init();
  Future<bool> requestPermission();
  Future<void> applyReminders(ReminderConfig config, ReminderTexts texts);

  /// Live countdown (mirrors to paired smartwatches) + alert when it ends.
  Future<void> showRestTimer({required DateTime endsAt, required String title, required String endTitle, required String endBody});
  Future<void> cancelRestTimer();
}

class NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> applyReminders(ReminderConfig config, ReminderTexts texts) async {}
  @override
  Future<void> showRestTimer({required DateTime endsAt, required String title, required String endTitle, required String endBody}) async {}
  @override
  Future<void> cancelRestTimer() async {}
}

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _restLiveId = 1;
  static const _restEndId = 2;
  // Reminder id ranges
  static const _waterBase = 100, _mealBase = 200, _workoutBase = 300, _weighId = 400;

  static const _restChannel = AndroidNotificationDetails(
    'rest_timer',
    'Rest timer',
    channelDescription: 'Live rest countdown during workouts',
    importance: Importance.low,
    priority: Priority.low,
    onlyAlertOnce: true,
    ongoing: true,
    usesChronometer: true,
    chronometerCountDown: true,
    category: AndroidNotificationCategory.stopwatch,
    visibility: NotificationVisibility.public,
  );

  static const _alertChannel = AndroidNotificationDetails(
    'rest_done',
    'Rest finished',
    channelDescription: 'Alerts when a rest period ends',
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.alarm,
    visibility: NotificationVisibility.public,
  );

  static const _reminderChannel = AndroidNotificationDetails(
    'reminders',
    'Reminders',
    channelDescription: 'Water, meal, workout and weigh-in reminders',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  @override
  Future<void> init() async {
    if (_ready || kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> requestPermission() async {
    await init();
    if (!_ready) return false;
    return await _android?.requestNotificationsPermission() ?? false;
  }

  Future<AndroidScheduleMode> _mode() async {
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    return exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  tz.TZDateTime _nextAt(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (weekday != null) {
      while (t.weekday != weekday) {
        t = t.add(const Duration(days: 1));
      }
    }
    if (!t.isAfter(now)) t = t.add(Duration(days: weekday != null ? 7 : 1));
    return t;
  }

  @override
  Future<void> applyReminders(ReminderConfig c, ReminderTexts x) async {
    await init();
    if (!_ready) return;
    // Clear all reminder ids, then re-schedule what is enabled.
    for (int i = 0; i < 24; i++) {
      await _plugin.cancel(id: _waterBase + i);
    }
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(id: _mealBase + i);
    }
    for (int i = 1; i <= 7; i++) {
      await _plugin.cancel(id: _workoutBase + i);
    }
    await _plugin.cancel(id: _weighId);

    const details = NotificationDetails(android: _reminderChannel);
    const mode = AndroidScheduleMode.inexactAllowWhileIdle; // reminders don't need exact alarms

    if (c.water) {
      final hours = c.waterHours();
      for (int i = 0; i < hours.length && i < 24; i++) {
        await _plugin.zonedSchedule(
          id: _waterBase + i,
          title: x.waterTitle,
          body: x.waterBody,
          scheduledDate: _nextAt(hours[i], 0),
          notificationDetails: details,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
    if (c.meals) {
      final meals = [(c.breakfastHour, x.breakfast), (c.lunchHour, x.lunch), (c.dinnerHour, x.dinner)];
      for (int i = 0; i < meals.length; i++) {
        await _plugin.zonedSchedule(
          id: _mealBase + i,
          title: x.mealTitle,
          body: meals[i].$2,
          scheduledDate: _nextAt(meals[i].$1, 0),
          notificationDetails: details,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
    if (c.workout) {
      for (final d in c.workoutWeekdays) {
        await _plugin.zonedSchedule(
          id: _workoutBase + d,
          title: x.workoutTitle,
          body: x.workoutBody,
          scheduledDate: _nextAt(c.workoutHour, c.workoutMinute, weekday: d),
          notificationDetails: details,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
    if (c.weighIn) {
      await _plugin.zonedSchedule(
        id: _weighId,
        title: x.weighTitle,
        body: x.weighBody,
        scheduledDate: _nextAt(c.weighInHour, 0),
        notificationDetails: details,
        androidScheduleMode: mode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> showRestTimer({
    required DateTime endsAt,
    required String title,
    required String endTitle,
    required String endBody,
  }) async {
    await init();
    if (!_ready) return;
    final remaining = endsAt.difference(DateTime.now());
    if (remaining.isNegative) return;
    await _plugin.show(
      id: _restLiveId,
      title: title,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _restChannel.channelId,
          _restChannel.channelName,
          channelDescription: _restChannel.channelDescription,
          importance: _restChannel.importance,
          priority: _restChannel.priority,
          onlyAlertOnce: true,
          ongoing: true,
          usesChronometer: true,
          chronometerCountDown: true,
          when: endsAt.millisecondsSinceEpoch,
          timeoutAfter: remaining.inMilliseconds,
          category: AndroidNotificationCategory.stopwatch,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
    await _plugin.cancel(id: _restEndId);
    await _plugin.zonedSchedule(
      id: _restEndId,
      title: endTitle,
      body: endBody,
      scheduledDate: tz.TZDateTime.from(endsAt, tz.local),
      notificationDetails: const NotificationDetails(android: _alertChannel),
      androidScheduleMode: await _mode(),
    );
  }

  @override
  Future<void> cancelRestTimer() async {
    if (!_ready) return;
    await _plugin.cancel(id: _restLiveId);
    await _plugin.cancel(id: _restEndId);
  }
}

/// Overridden with [LocalNotificationService] in main.dart; tests keep the no-op.
final notificationServiceProvider = Provider<NotificationService>((ref) => NoopNotificationService());
