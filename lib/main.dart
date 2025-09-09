import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_project/core/constants/notifications_constants/notification_constants.dart';
import 'package:flutter_local_notifications_project/core/theme/app_themes.dart';
import 'package:flutter_local_notifications_project/core/utils/local_notification_service.dart';
import 'package:flutter_local_notifications_project/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;
ReceivePort uiMainPort = ReceivePort();
bool isAndroidAlarmInitialized = false;
late ValueNotifier<bool> androidAlarmNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initLocalNotificationPlugin();
  bool isAndroidAlarmInitialized = await AndroidAlarmManager.initialize();
  androidAlarmNotifier = ValueNotifier(isAndroidAlarmInitialized);
  print("result of init android alarm manager: $isAndroidAlarmInitialized");
  IsolateNameServer.registerPortWithName(
    uiMainPort.sendPort,
    NotificationsConstants.uiMainIsolateName,
  );

  sharedPreferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Local Notifications Project',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      home: const HomeScreen(),
    );
  }
}
