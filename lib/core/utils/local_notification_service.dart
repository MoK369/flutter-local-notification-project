import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/core/utils/unique_id_provider.dart';
import 'package:flutter_local_notifications_project/main.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
import "package:flutter/material.dart";

abstract class LocalNotificationService {
  @pragma('vm:entry-point')
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @pragma('vm:entry-point')
  static SendPort? uiSendPort;

  @pragma('vm:entry-point')
  static Future<bool?> initLocalNotificationPlugin() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("res_notification_logo"),
    );
    return flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  @pragma('vm:entry-point')
  static onNotificationTap(NotificationResponse notification) {}

  @pragma('vm:entry-point')
  static Future<String> copyAssetToFile(String assetPath) async {
    final String fileName = assetPath
        .split('/')
        .last
        .replaceAll(RegExp(r'\.\w+'), "");

    final String filePath =
        '${(await getApplicationDocumentsDirectory()).path}/$fileName';
    final File file = File(filePath);

    if (await file.exists()) {
      return file.path;
    }

    final byteData = await rootBundle.load(assetPath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  @pragma('vm:entry-point')
  static AndroidNotificationDetails channelDetails({
    String? filePath,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String groupKey,
    AndroidNotificationSound? customNotificationSound,
    AndroidNotificationCategory category = AndroidNotificationCategory.message,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      channelShowBadge: true,
      importance: Importance.max,
      priority: Priority.max,
      category: category,
      groupKey: groupKey,
      sound: customNotificationSound,
      colorized: true,
      color: Colors.teal,
      styleInformation: filePath == null
          ? null
          : BigPictureStyleInformation(FilePathAndroidBitmap(filePath)),
    );
  }

  /// ======= Basic Notifications =======
  @pragma('vm:entry-point')
  static Future<void> showBasicNotification({
    required String title,
    required String body,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: channelDetails(
        filePath: await copyAssetToFile("assets/images/on_the_map.jpg"),
        channelId: NotificationsConstants.basicChannelId,
        channelName: NotificationsConstants.basicChannelName,
        channelDescription: NotificationsConstants.basicChannelDescription,
        groupKey: NotificationsConstants.basicChannelGroupKey,
      ),
    );
    return flutterLocalNotificationsPlugin.show(
      UniqueIdProvider.provide(),
      title,
      body,
      notificationDetails,
      payload: "${title} ${body}",
    );
  }

  /// =================================

  /// ====== Repeated Notification =========
  @pragma('vm:entry-point')
  static Future<void> showRepeatedNotification({
    required String title,
    required String body,
    required RepeatInterval repeatedInterval,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: channelDetails(
        channelId: NotificationsConstants.repeatedChannelId,
        channelName: NotificationsConstants.repeatedChannelName,
        channelDescription: NotificationsConstants.repeatedChannelDescription,
        groupKey: NotificationsConstants.repeatedChannelGroupKey,
        category: AndroidNotificationCategory.reminder,
      ),
    );
    return flutterLocalNotificationsPlugin.periodicallyShow(
      NotificationsConstants.repeatedNotificationId,
      title,
      body,
      repeatedInterval,
      notificationDetails,
      payload: "${title} ${body} Repeat: ${repeatedInterval}",
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// ===================================

  /// ======= Scheduled Notifications ========
  @pragma('vm:entry-point')
  static Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime selectedDateTime,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: channelDetails(
        channelId: NotificationsConstants.scheduledChannelId,
        channelName: NotificationsConstants.scheduledChannelName,
        channelDescription: NotificationsConstants.scheduledChannelDescription,
        groupKey: NotificationsConstants.scheduledChannelGroupKey,
        category: AndroidNotificationCategory.alarm,
        customNotificationSound: RawResourceAndroidNotificationSound(
          "custom_notification_sound",
        ),
      ),
    );
    initializeTimeZones();
    setLocalLocation(getLocation(await FlutterTimezone.getLocalTimezone()));
    print("after: ${local.name}");
    print("time: ${TZDateTime.now(local).hour}");
    print(selectedDateTime.toString());
    return flutterLocalNotificationsPlugin.zonedSchedule(
      UniqueIdProvider.provide(),
      title,
      body,
      payload: "${title} ${body} Schedule: ${selectedDateTime}",
      TZDateTime(
        local,
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
        selectedDateTime.hour,
        selectedDateTime.minute,
      ),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> showScheduledNotificationWithAndroidAlarmManager({
    required String title,
    required String body,
    required DateTime selectedDateTime,
  }) async {
    final uniqueId = UniqueIdProvider.provide();
    var result = await sharedPreferences.getStringList(
      NotificationsConstants.scheduledNotificationListKey,
    );

    print("Scheduling at: ${selectedDateTime}");
    var isAlarmSet = await AndroidAlarmManager.oneShotAt(
      selectedDateTime,
      uniqueId,
      androidManagerCallBack,
      allowWhileIdle: true,
      alarmClock: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    if (result == null) {
      print("result equal null");
      await sharedPreferences.setStringList(
        NotificationsConstants.scheduledNotificationListKey,
        ["$uniqueId~$title~$body~$selectedDateTime"],
      );
    } else {
      result.add("$uniqueId~$title~$body~$selectedDateTime");
      print("result equal ${result}");
      await sharedPreferences.setStringList(
        NotificationsConstants.scheduledNotificationListKey,
        result,
      );
    }
    return isAlarmSet;
  }

  /// ===================================

  static Future<void> cancelAll() {
    return flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> cancelAllScheduledAndroidAlarmNotification() async {
    var notifications =
        await sharedPreferences.getStringList(
          NotificationsConstants.scheduledNotificationListKey,
        ) ??
        [];

    notifications.forEach((notification) async {
      int id = int.tryParse(notification.split("~").first) ?? 0;
      await AndroidAlarmManager.cancel(id);
    });
    await sharedPreferences.clear();
  }

  static Future<void> cancelNotification(int id) {
    return flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<List<PendingNotificationRequest>> getAllPendingNotifications() {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

// 1.Setup
// 2.Basic Notification
// 3.Repeated Notification
// 4.Scheduled Notification
@pragma('vm:entry-point')
void androidManagerCallBack() async {
  await LocalNotificationService.initLocalNotificationPlugin();
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  var result = await prefs.getStringList(
    NotificationsConstants.scheduledNotificationListKey,
  );
  print("before: $result");
  if (result == null) {
    LocalNotificationService.uiSendPort ??= IsolateNameServer.lookupPortByName(
      NotificationsConstants.uiMainIsolateName,
    );
    LocalNotificationService.uiSendPort?.send("done");
    return;
  }
  print("${result.first}");
  var notificationParts = result.first.split("~");
  print("triggering notification ---------");
  NotificationDetails notificationDetails = NotificationDetails(
    android: LocalNotificationService.channelDetails(
      channelId: NotificationsConstants.scheduledChannelId,
      channelName: NotificationsConstants.scheduledChannelName,
      channelDescription: NotificationsConstants.scheduledChannelDescription,
      groupKey: NotificationsConstants.scheduledChannelGroupKey,
      category: AndroidNotificationCategory.alarm,
      customNotificationSound: RawResourceAndroidNotificationSound(
        "custom_notification_sound",
      ),
    ),
  );
  await LocalNotificationService.flutterLocalNotificationsPlugin.show(
    UniqueIdProvider.provide(),
    notificationParts[1],
    notificationParts[2] + notificationParts[3],
    notificationDetails,
    payload: "${notificationParts[0]} ${notificationParts[1]}",
  );
  await prefs.remove(NotificationsConstants.scheduledNotificationListKey);
  result.removeAt(0);
  print("after remove: $result");
  if (result.isNotEmpty) {
    await prefs.setStringList(
      NotificationsConstants.scheduledNotificationListKey,
      result,
    );
  }
  LocalNotificationService.uiSendPort ??= IsolateNameServer.lookupPortByName(
    NotificationsConstants.uiMainIsolateName,
  );
  LocalNotificationService.uiSendPort?.send("done");
}
