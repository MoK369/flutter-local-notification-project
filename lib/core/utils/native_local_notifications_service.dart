import 'package:flutter/services.dart';
abstract class NativeLocalNotificationsService{
  static const platform = MethodChannel("com.main369.flutter_local_notifications_project/alarm");
  static Future<void> scheduleExactAlarm(DateTime time) async {
    print("given dateTime $time");
    final millis = time.millisecondsSinceEpoch;
    await platform.invokeMethod('scheduleExactAlarm', {
      'time': millis,
    });
  }

}