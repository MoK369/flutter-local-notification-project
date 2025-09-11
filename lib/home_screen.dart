import 'package:auto_start_permission/auto_start_permission.dart';
import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/core/utils/local_notification_service.dart';
import 'package:flutter_local_notifications_project/core/utils/native_local_notifications_service.dart';
import 'package:flutter_local_notifications_project/core/utils/notification_dialogs.dart';
import 'package:flutter_local_notifications_project/scheduled_notifications/scheduled_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    checkAndroidScheduleExactAlarmPermission().then((value) async {
      // var count = sharedPreferences.getInt(
      //   NotificationsConstants.autoStartPermissionCountKey,
      // );
      AutoStartPermissionState autoStartStatus = await AutoStartPermission
          .instance
          .checkAutoStartState();
      bool isAvailable = await AutoStartPermission.instance
          .isAutoStartPermissionAvailable();
      print("is autoStartPermission Available: ${isAvailable}");
      if (autoStartStatus == AutoStartPermissionState.disabled && isAvailable) {
        await AutoStartPermission.instance.requestAutoStartPermission();
        // await sharedPreferences.setInt(
        //   NotificationsConstants.autoStartPermissionCountKey,
        //   count ?? 0 + 1,
        // );
      }
      await checkBatteryOptimization();
    });
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    print('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      print('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      print(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.',
      );
    }
    // final ignoreBatteryStatus =
    //     await Permission.ignoreBatteryOptimizations.status;
    // if (ignoreBatteryStatus.isDenied) {
    //   final res = await Permission.ignoreBatteryOptimizations.request();
    //   print(
    //     'ignoreBatteryStatus permission ${res.isGranted ? '' : 'not'} granted.',
    //   );
    // }
  }

  Future<void> checkBatteryOptimization() async {
    bool isEnabled =
    await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
    print("Battery optimization is enabled: $isEnabled");
    if (isEnabled) {
      await BatteryOptimizationHelper.requestDisableBatteryOptimization();
      bool isEnabled =
      await BatteryOptimizationHelper.isBatteryOptimizationEnabled();
      print("Battery optimization is enabled: $isEnabled");
      // if (isEnabled)
      //   await BatteryOptimizationHelper.openBatteryOptimizationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Local Notifications 🔔"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScheduledNotifications(),
                ),
              );
            },
            icon: const Icon(Icons.stacked_bar_chart),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Notifications: ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                FilledButton(
                  onPressed: () async {
                    await LocalNotificationService.showBasicNotification(
                      title: "Buy Plant Food 💰️🌱",
                      body: "Don't forget to feed you plant",
                    );
                  },
                  child: Text("Basic"),
                ),
                FilledButton(
                  onPressed: () async {
                    var interval =
                        await NotificationDialogs.showRepeatedNotificationDialog(
                          context,
                        );
                    print(interval);
                    if (interval == null) return;
                    await LocalNotificationService.showRepeatedNotification(
                      title: "Water You Plant 💦",
                      body: "Don't forget to water your plant",
                      repeatedInterval: interval,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "notification created on ${NotificationsConstants.repeatedChannelId}",
                        ),
                      ),
                    );
                  },
                  child: Text("Repeated"),
                ),
                FilledButton(
                  onPressed: () async {
                    var selectedDateTime =
                        await NotificationDialogs.showScheduledNotificationDialogs(
                          context,
                        );
                    if (selectedDateTime == null) return;
                    await NativeLocalNotificationsService.scheduleExactAlarm(selectedDateTime);
                    // bool errorOccurred = false;
                    // await LocalNotificationService.showScheduledNotification(
                    //   title: "Prune Your Plant 🌿",
                    //   body: "Don't forget to make your plant looks good",
                    //   selectedDateTime: selectedDateTime,
                    // ).catchError((error) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text("Error: ${error.toString()}"),
                    //       duration: const Duration(seconds: 5),
                    //     ),
                    //   );
                    //   errorOccurred = true;
                    // });
                    // if (errorOccurred) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Notification Created on Scheduled Channel",
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  },
                  child: Text("Scheduled"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                await LocalNotificationService.cancelAll();
              },
              child: Text("❌Cancel All"),
            ),
          ],
        ),
      ),
    );
  }
}
