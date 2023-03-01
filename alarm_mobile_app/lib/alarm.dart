// represents the alarm class for medication reminders
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'utils.dart';

class Alarm {
  // fields for the table in the database
  // https://api.flutter.dev/flutter/material/showTimePicker.html
  // https://api.flutter.dev/flutter/material/TimeOfDay-class.html
  final String alarmID;
  final String nameOfDrug;
  final String dayOfWeek;
  late TimeOfDay time;

  // constructor for the values
  Alarm({
    required this.alarmID,
    required this.time,
    required this.nameOfDrug,
    required this.dayOfWeek
  });

  @override
  String toString() {
    return 'Alarm{alarmID: $alarmID, time: $time, nameOfDrug: $nameOfDrug)';
  }

  // maps the value from the database to the values present in the alarm class
  Map<String, dynamic> toMap() {
    return {
      'alarmID': alarmID,
      'time': time.toString(),
      'nameOfDrug': nameOfDrug,
      'dayOfWeek': dayOfWeek
    };
  }

  // used for payload stuff
  Map<String, String> toStringMap() {
    return {
      'alarmID': alarmID,
      'time': time.toString(),
      'nameOfDrug': nameOfDrug,
      'dayOfWeek': dayOfWeek
    };
  }

  // gets an alarm object from the given map
  static Alarm fromMap(Map<String, dynamic> data) {
    Alarm temp = Alarm(
        alarmID: data['alarmID'],
      time: parseTimeOfDayString(data['time']),
      nameOfDrug: data['nameOfDrug'],
      dayOfWeek: data['dayOfWeek']
    );
    return temp;
  }

  // same function as above just different types
  static Alarm fromStringMap(Map<String, String> data) {
    Alarm temp = Alarm(
      alarmID: data['alarmID'] ?? "",
        time: parseTimeOfDayString(data['time'] ?? ""),
        nameOfDrug: data['nameOfDrug'] ?? "",
        dayOfWeek: data['dayOfWeek'] ?? "",
    );
    return temp;
  }
}
