import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_project/core/theme/app_themes.dart';
import 'package:flutter_local_notifications_project/core/utils/local_notification_service.dart';
import 'package:flutter_local_notifications_project/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initLocalNotificationPlugin();
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
