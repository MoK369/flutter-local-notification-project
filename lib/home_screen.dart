import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/core/utils/local_notification_service.dart';
import 'package:flutter_local_notifications_project/core/utils/notification_dialogs.dart';
import 'package:flutter_local_notifications_project/scheduled_notifications/scheduled_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
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
                    await LocalNotificationService.showScheduledNotification(
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
              },
              child: Text("❌Cancel All"),
            ),
          ],
        ),
      ),
    );
  }
}
