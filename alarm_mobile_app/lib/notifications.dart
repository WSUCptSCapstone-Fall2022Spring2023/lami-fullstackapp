import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:alarm_mobile_app/main.dart';
import 'alarm.dart';

void createNotification(Alarm alarm) {
  int hour = alarm.time.hour;
  int minute = alarm.time.minute;
  for (int i = 0; i < 1; i++) {
    if (hour >= 24) hour -= 24;
    Map<String, String> payload = alarm.toStringMap();
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: int.parse(alarm.alarmID),
            channelKey: "PalouseAlarm",
            title: "Reminder: " + alarm.nameOfDrug,
            body: "alarm.description",
            wakeUpScreen: true,
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Alarm,
            ticker: "testing",
            displayOnBackground: true,
            displayOnForeground: true,
            payload: payload),
        schedule: NotificationCalendar(
          hour: hour,
          minute: minute,
          timeZone: "America/Los_Angeles",
          allowWhileIdle: true,
        ),
        actionButtons: [
          NotificationActionButton(
              key: alarm.alarmID,
              label: "Dismiss",
              // buttonType: ActionButtonType.DisabledAction
          )
        ]);
    hour += 1;
  }
}

void createNotificationTomorrow(Alarm alarm, DateTime tomorrow) {
  Map<String, String> payload = alarm.toStringMap();
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: int.parse(alarm.alarmID),
          channelKey: "PalouseAlarm",
          title: "Reminder take: " + alarm.nameOfDrug,
          body: "alarm.description",
          wakeUpScreen: true,
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          ticker: "testing",
          displayOnBackground: true,
          displayOnForeground: true,
          payload: payload),
      schedule: NotificationCalendar(
          hour: alarm.time.hour,
          minute: alarm.time.minute,
          day: tomorrow.day,
          month: tomorrow.month,
          year: tomorrow.year,
          timeZone: "America/Los_Angeles",
          allowWhileIdle: true),
      actionButtons: [
        NotificationActionButton(
            key: alarm.alarmID,
            label: "Dismiss",
            // buttonType: ActionButtonType.DisabledAction
        )
      ]);
}

//USED FOR TESTING LAYOUT OF NOTIFICATIONS - DELETE FOR FINAL CODE
void createImmediateNotif(String title, String desc) {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 0,
          channelKey: "PalouseAlarm",
          title: "Reminder take: " + title,
          body: desc,
          wakeUpScreen: true,
          locked: true,
          category: NotificationCategory.Alarm,
          ticker: "testing ticker"),
      actionButtons: [
        NotificationActionButton(
          key: "0",
          label: "Dismiss",
          // buttonType: ActionButtonType.DisabledAction,
        )
      ]);
}

Future<void> resetBadgeCounter() async {
await AwesomeNotifications().resetGlobalBadge();
}

Future<void> cancelNotifications() async {
await AwesomeNotifications().cancelAll();
}
