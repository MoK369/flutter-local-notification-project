import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_project/core/base_view_state/base_view_state.dart';
import 'package:flutter_local_notifications_project/scheduled_notifications/view_model/scheduled_notification_view_model.dart';
import 'package:provider/provider.dart';

class ScheduledNotifications extends StatefulWidget {
  const ScheduledNotifications({super.key});

  @override
  State<ScheduledNotifications> createState() => _ScheduledNotificationsState();
}

class _ScheduledNotificationsState extends State<ScheduledNotifications> {
  final ScheduledNotificationViewModel scheduledNotificationViewModel =
      ScheduledNotificationViewModel();
  @override
  void initState() {
    super.initState();
    scheduledNotificationViewModel.getScheduledNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => scheduledNotificationViewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text("Scheduled Notifications")),
        body: Center(
          child: Consumer<ScheduledNotificationViewModel>(
            builder: (context, viewModel, child) {
              switch (viewModel.getScheduledNotificationResult) {
                case IdleState<List<PendingNotificationRequest>>():
                case LoadingState<List<PendingNotificationRequest>>():
                  return const CircularProgressIndicator();
                case SuccessState<List<PendingNotificationRequest>>():
                  var notifications =
                      (viewModel.getScheduledNotificationResult
                              as SuccessState<List<PendingNotificationRequest>>)
                          .data;
                  return notifications.isEmpty
                      ? const Text(
                          "No Scheduled Notifications",
                          style: TextStyle(fontSize: 20),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              var notification = notifications[index];
                              var notificationPayloadParts =
                                  notification.payload?.split(" ") ?? [];
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title ?? "",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Text(
                                            //   ("${schedule.hour.toString()}:${schedule.minute.toString()}")
                                            //       .convert24HoursTo12HoursFormat(),
                                            // ),
                                            // Text(
                                            //   "locked: ${notifications[index].content?.locked ?? ""}",
                                            // ),
                                            notification.payload!.contains(
                                                  "Repeat",
                                                )
                                                ? Text(
                                                    "repeats: ${notificationPayloadParts.last.split(".").last}",
                                                  )
                                                : Text(
                                                    "scheduled: ${notificationPayloadParts[notificationPayloadParts.length - 2]} ${notificationPayloadParts[notificationPayloadParts.length - 1]}",
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Selector<
                                    ScheduledNotificationViewModel,
                                    CancelScheduledNotificationData
                                  >(
                                    selector: (context, viewModel) => viewModel
                                        .cancelScheduledNotificationData,
                                    builder: (context, value, child) {
                                      if (value.id != null &&
                                          value.id != notifications[index].id) {
                                        return IconButton(
                                          onPressed: () {
                                            viewModel
                                                .deleteScheduledNotification(
                                                  notifications[index].id,
                                                );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        );
                                      }
                                      switch (value.status) {
                                        case IdleState<void>():
                                          return IconButton(
                                            onPressed: () {
                                              viewModel
                                                  .deleteScheduledNotification(
                                                    notifications[index].id,
                                                  );
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          );
                                        case LoadingState<void>():
                                        case SuccessState<void>():
                                          return const CircularProgressIndicator();
                                        case ErrorState<void>():
                                          String error =
                                              (viewModel
                                                          .cancelScheduledNotificationData
                                                          .status
                                                      as ErrorState<
                                                        List<
                                                          PendingNotificationRequest
                                                        >
                                                      >)
                                                  .error
                                                  .toString();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text("Error: $error"),
                                            ),
                                          );
                                          return const SizedBox();
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                            itemCount: notifications.length,
                          ),
                        );
                case ErrorState<List<PendingNotificationRequest>>():
                  String error =
                      (viewModel.getScheduledNotificationResult
                              as ErrorState<List<PendingNotificationRequest>>)
                          .error
                          .toString();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $error")));
                  return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
