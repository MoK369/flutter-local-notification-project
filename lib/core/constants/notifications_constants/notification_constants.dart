abstract class NotificationsConstants {
  /// Basic Channel
  static const String basicChannelId = "basic_channel";
  static const String basicChannelName = "Basic Channel";
  static const String basicChannelDescription =
      "This is the channel for Basic Notifications";
  static const String basicChannelGroupKey =
      "com.main369.flutter_local_notifications_project.Basic_Notifications";

  /// Repeated Channel
  static const String repeatedChannelId = "repeated_channel";
  static const String repeatedChannelName = "Repeated Channel";
  static const String repeatedChannelDescription =
      "This is the channel for Repeated Notifications";
  static const String repeatedChannelGroupKey =
      "com.main369.flutter_local_notifications_project.Repeated_Notifications";
  static const int repeatedNotificationId = 1;

  /// Scheduled Channel
  static const String scheduledChannelId = "scheduled_channel";
  static const String scheduledChannelName = "Scheduled Channel";
  static const String scheduledChannelDescription =
      "This is the channel for Scheduled Notifications";
  static const String scheduledChannelGroupKey =
      "com.main369.flutter_local_notifications_project.Scheduled_Notifications";

  static const String scheduledNotificationListKey = "scheduled_notification_list";

  /// The name associated with the UI isolate's [SendPort].
  static const String uiMainIsolateName = 'isolate';
}
