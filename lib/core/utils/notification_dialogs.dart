import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationDialogs {
  static Future<RepeatInterval?> showRepeatedNotificationDialog(
    BuildContext context,
  ) async {
    RepeatInterval? chosenInterval;
    await showDialog(
      context: context,
      builder: (context) {
        List<RepeatInterval> intervals = RepeatInterval.values;
        return AlertDialog(
          title: Text("Choose Repeating Interval"),
          content: Wrap(
            spacing: 2,
            runSpacing: 3,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: List.generate(intervals.length, (index) {
              return FilledButton(
                onPressed: () {
                  chosenInterval = intervals[index];
                  Navigator.pop(context);
                },
                child: Text(intervals[index].toString().split(".").last),
              );
            }),
          ),
        );
      },
    );
    return chosenInterval;
  }

  static Future<DateTime?> showScheduledNotificationDialogs(
    BuildContext context,
  ) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDateTime == null) return null;
    TimeOfDay? selectedTimeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now().replacing(
        hour: (TimeOfDay.now().minute + 2) >= 60
            ? TimeOfDay.now().hour + 1
            : TimeOfDay.now().hour,
        minute: (TimeOfDay.now().minute + 2 )% 60,
      ),
    );
    if (selectedTimeOfDay == null) return null;
    return DateTime(
      selectedDateTime.year,
      selectedDateTime.month,
      selectedDateTime.day,
      selectedTimeOfDay.hour,
      selectedTimeOfDay.minute,
    );
  }
}
