import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/core/utils/local_notification_service.dart';
import 'package:flutter_local_notifications_project/core/utils/notification_dialogs.dart';
import 'package:flutter_local_notifications_project/main.dart';
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
    print("valueNotifier: ${androidAlarmNotifier.value}");
    _checkExactAlarmPermission();
    uiMainPort.listen((message) async {
      await sharedPreferences.reload();
    });
  }

  void _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    if (currentStatus.isDenied) {
      await Permission.scheduleExactAlarm.request();
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
                    bool errorOccurred = false;
                    await LocalNotificationService.showScheduledNotificationWithAndroidAlarmManager(
                      title: "Prune Your Plant 🌿",
                      body: "Don't forget to make your plant looks good",
                      selectedDateTime: selectedDateTime,
                    ).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: ${error.toString()}"),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                      errorOccurred = true;
                      return false;
                    });
                    if (errorOccurred) return;
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
                await LocalNotificationService.cancelAllScheduledAndroidAlarmNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("All Notifications are canceled"),
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
              child: Text("❌Cancel All"),
            ),
            ValueListenableBuilder(
              valueListenable: androidAlarmNotifier,
              builder: (context, value, child) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      value
                          ? const SizedBox()
                          : const Text(
                              "Android Alarm Manager is NOT Initialized",
                            ),
                      FilledButton(
                        onPressed: value
                            ? null
                            : () async {
                                isAndroidAlarmInitialized =
                                    await AndroidAlarmManager.initialize();
                                print(isAndroidAlarmInitialized);
                                if (androidAlarmNotifier.value !=
                                    isAndroidAlarmInitialized) {
                                  androidAlarmNotifier.value = isAndroidAlarmInitialized;
                                  print(androidAlarmNotifier.value);
                                }
                              },
                        child: Text("Init it Again"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
