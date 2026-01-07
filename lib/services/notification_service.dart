import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/inventory_item.dart';
import 'notification_settings_service.dart';
import 'pantry_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Timer? _debounce;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      // Web support for scheduled local notifications is limited.
      _initialized = true;
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iOSInit);

    await _plugin.initialize(initSettings);

    await _initTimeZone();
    await _requestPermissionsIfNeeded();

    // Listen for changes and keep schedules in sync.
    NotificationSettingsService.instance.settingsNotifier.addListener(_scheduleDebounced);
    PantryService.instance.itemsNotifier.addListener(_scheduleDebounced);

    _initialized = true;

    // Best-effort initial schedule.
    _scheduleDebounced();
  }

  Future<void> _initTimeZone() async {
    tz.initializeTimeZones();

    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Fallback: keep default local location.
    }
  }

  Future<void> _requestPermissionsIfNeeded() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        await ios.requestPermissions(alert: true, badge: true, sound: true);
      }

      final macos = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      if (macos != null) {
        await macos.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (_) {
      // Ignore permission errors; scheduling will still be attempted.
    }
  }

  void _scheduleDebounced() {
    if (!_initialized) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(rescheduleAll());
    });
  }

  Future<void> rescheduleAll() async {
    if (kIsWeb) return;
    if (!_initialized) return;

    final settings = NotificationSettingsService.instance.settings;

    // Clear existing schedules and rebuild.
    await _plugin.cancelAll();

    if (!settings.expiryAlerts) return;

    final items = PantryService.instance.items;
    final now = DateTime.now();

    int scheduledCount = 0;
    for (final item in items) {
      final scheduleAt = _computeScheduleTime(item: item, now: now, leadDays: settings.leadDays);
      if (scheduleAt == null) continue;

      final id = _notificationIdForItem(item);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_alerts',
          'Expiry Alerts',
          channelDescription: 'Alerts when items are close to expiring',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        id,
        'Item expiring soon',
        '${item.name} is expiring soon. Check your pantry.',
        tz.TZDateTime.from(scheduleAt, tz.local),
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      scheduledCount++;
    }

    debugPrint('NotificationService: scheduled $scheduledCount expiry alerts');
  }

  DateTime? _computeScheduleTime({
    required InventoryItem item,
    required DateTime now,
    required int leadDays,
  }) {
    final expiry = item.expiryDate;
    if (expiry == null) return null;

    // Skip expired items.
    if (expiry.isBefore(now)) return null;

    // Target time: expiry - leadDays at 09:00 local.
    final targetDay = DateTime(expiry.year, expiry.month, expiry.day)
        .subtract(Duration(days: leadDays));
    final target = DateTime(targetDay.year, targetDay.month, targetDay.day, 9);

    // If the target is already in the past but item is within the lead window,
    // fire soon (helps when user just enabled notifications).
    if (target.isBefore(now)) {
      final withinLead = expiry.difference(now).inDays <= leadDays;
      if (!withinLead) return null;
      return now.add(const Duration(seconds: 10));
    }

    return target;
  }

  int _notificationIdForItem(InventoryItem item) {
    // Stable-ish id across runs.
    final raw = item.id.hashCode;
    return (raw & 0x7fffffff) % 2000000000;
  }
}
