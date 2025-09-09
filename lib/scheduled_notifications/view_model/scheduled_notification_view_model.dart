import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_project/core/base_view_state/base_view_state.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/main.dart';

class ScheduledNotificationViewModel extends ChangeNotifier {
  List<PendingNotification> _scheduledNotifications = [];
  BaseViewState<List<PendingNotification>> getScheduledNotificationResult =
      IdleState();

  CancelScheduledNotificationData cancelScheduledNotificationData =
      CancelScheduledNotificationData(status: IdleState());

  void getScheduledNotifications() async {
    try {
      getScheduledNotificationResult = LoadingState();
      notifyListeners();

      var notifications =
          await sharedPreferences.getStringList(
            NotificationsConstants.scheduledNotificationListKey,
          ) ??
          [];

      _scheduledNotifications = notifications.map((e) {
        var parts = e.split("~");
        return PendingNotification(
          id: int.tryParse(parts[0]) ?? 0,
          title: parts[1],
          body: parts[2],
          dataTime: parts[3],
        );
      }).toList();
      getScheduledNotificationResult = SuccessState<List<PendingNotification>>(
        data: _scheduledNotifications,
      );
    } catch (e) {
      getScheduledNotificationResult = ErrorState(error: e);
    }
    notifyListeners();
  }

  void deleteScheduledNotification(int notificationId) async {
    try {
      cancelScheduledNotificationData.id = notificationId;
      cancelScheduledNotificationData.status = LoadingState();
      notifyListeners();
      await AndroidAlarmManager.cancel(notificationId);
      await sharedPreferences.remove(NotificationsConstants.scheduledNotificationListKey);
      var list =
          await sharedPreferences.getStringList(
            NotificationsConstants.scheduledNotificationListKey,
          ) ??
          [];
      list.removeWhere((element) {
        return element.split("~")[0] == "$notificationId";
      });
      print(list);
      if(list.isNotEmpty){
        await sharedPreferences.setStringList(NotificationsConstants.scheduledNotificationListKey, list);
      }
      cancelScheduledNotificationData.status = SuccessState(data: null);
    } catch (e) {
      cancelScheduledNotificationData.status = ErrorState(error: e);
    }
    notifyListeners();

    _scheduledNotifications.removeAt(
      _scheduledNotifications.indexWhere(
        (element) => element.id == cancelScheduledNotificationData.id,
      ),
    );
    getScheduledNotificationResult = SuccessState<List<PendingNotification>>(
      data: _scheduledNotifications,
    );
    notifyListeners();
    cancelScheduledNotificationData.id = null;
    cancelScheduledNotificationData.status = IdleState();
  }
}

class CancelScheduledNotificationData {
  int? id;
  BaseViewState<void> status;
  CancelScheduledNotificationData({this.id, required this.status});
}

class PendingNotification {
  int id;
  String title;
  String body;
  String dataTime;
  PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.dataTime,
  });
}
