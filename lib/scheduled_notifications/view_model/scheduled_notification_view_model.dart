import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_project/core/base_view_state/base_view_state.dart';
import 'package:flutter_local_notifications_project/core/utils/local_notification_service.dart';

class ScheduledNotificationViewModel extends ChangeNotifier {
  List<PendingNotificationRequest> _scheduledNotifications = [];
  BaseViewState<List<PendingNotificationRequest>> getScheduledNotificationResult =
      IdleState();

  CancelScheduledNotificationData cancelScheduledNotificationData =
      CancelScheduledNotificationData(status: IdleState());

  void getScheduledNotifications() async {
    try {
      getScheduledNotificationResult = LoadingState();
      notifyListeners();
      _scheduledNotifications = await LocalNotificationService.getAllPendingNotifications();
      getScheduledNotificationResult = SuccessState<List<PendingNotificationRequest>>(
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
      await LocalNotificationService.cancelNotification(notificationId);
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
    getScheduledNotificationResult = SuccessState<List<PendingNotificationRequest>>(
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
