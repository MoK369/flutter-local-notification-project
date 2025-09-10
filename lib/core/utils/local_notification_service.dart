import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/core/utils/unique_id_provider.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

abstract class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<bool?> initLocalNotificationPlugin() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("res_notification_logo"),
    );
    return _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  @pragma('vm:entry-point')
  static onNotificationTap(NotificationResponse notification) {}

  static Future<String> _copyAssetToFile(String assetPath) async {
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

  static AndroidNotificationDetails _channelDetails({
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
      styleInformation: filePath == null
          ? null
          : BigPictureStyleInformation(FilePathAndroidBitmap(filePath)),
    );
  }

  /// ======= Basic Notifications =======
  static Future<void> showBasicNotification({
    required String title,
    required String body,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: _channelDetails(
        filePath: await _copyAssetToFile("assets/images/on_the_map.jpg"),
        channelId: NotificationsConstants.basicChannelId,
        channelName: NotificationsConstants.basicChannelName,
        channelDescription: NotificationsConstants.basicChannelDescription,
        groupKey: NotificationsConstants.basicChannelGroupKey,
      ),
    );
    return _flutterLocalNotificationsPlugin.show(
      UniqueIdProvider.provide(),
      title,
      body,
      notificationDetails,
      payload: "${title} ${body}",
    );
  }

  /// =================================

  /// ====== Repeated Notification =========
  static Future<void> showRepeatedNotification({
    required String title,
    required String body,
    required RepeatInterval repeatedInterval,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: _channelDetails(
        channelId: NotificationsConstants.repeatedChannelId,
        channelName: NotificationsConstants.repeatedChannelName,
        channelDescription: NotificationsConstants.repeatedChannelDescription,
        groupKey: NotificationsConstants.repeatedChannelGroupKey,
        category: AndroidNotificationCategory.reminder,
      ),
    );
    return _flutterLocalNotificationsPlugin.periodicallyShow(
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
  static Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime selectedDateTime,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: _channelDetails(
        channelId: NotificationsConstants.scheduledChannelId,
        channelName: NotificationsConstants.scheduledChannelName,
        channelDescription: NotificationsConstants.scheduledChannelDescription,
        groupKey: NotificationsConstants.scheduledChannelGroupKey,
        category: AndroidNotificationCategory.call,
        customNotificationSound: RawResourceAndroidNotificationSound("custom_notification_sound")
      ),
    );
    initializeTimeZones();
    setLocalLocation(getLocation(await FlutterTimezone.getLocalTimezone()));
    print("after: ${local.name}");
    print("time: ${TZDateTime.now(local).hour}");
    print(selectedDateTime.toString());
    return _flutterLocalNotificationsPlugin.zonedSchedule(
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// ===================================

  static Future<void> cancelAll() {
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotification(int id) {
    return _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<List<PendingNotificationRequest>> getAllPendingNotifications() {
    return _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

// 1.Setup
// 2.Basic Notification
// 3.Repeated Notification
// 4.Scheduled Notification
