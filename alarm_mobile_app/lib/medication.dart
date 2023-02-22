// represents the alarm class for medication reminders
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'utils.dart';

class Medication {
  // fields for the table in the database
  // https://api.flutter.dev/flutter/material/showTimePicker.html
  // https://api.flutter.dev/flutter/material/TimeOfDay-class.html
  final String id;
  final String nameOfDrug;
  late String description;
  late RepeatOption repeatOption;
  late List<bool> daysOfWeek = List.filled(7, true);
  late Duration repeatDuration = const Duration(days: 1);
  // default values for repeating x times per day every x amount of times
  late int repeatTimes = 1;
  late List<TimeOfDay> time;
  late bool enabled;

  // constructor for the values
  Medication({
    required this.id,
    required this.nameOfDrug,
  });

  @override
  String toString() {
    return 'Alarm{'
        'id: $id,'
        'nameOfDrug: $nameOfDrug,'
        'description: $description,'
        'repeatOption: $repeatOption,'
        'daysOfWeek: $daysOfWeek,'
        'repeatDuration: $repeatDuration,'
        'repeatTimes: $repeatTimes,'
        'time: $time,'
        'enabled: $enabled';
  }

  // maps the value from the database to the values present in the alarm class
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameOfDrug': nameOfDrug,
      'description': description,
      'repeatOption': repeatOption.toString(),
      'daysOfWeek': daysOfWeek.toString(),
      'repeatDuration': repeatDuration.toString(),
      'repeatTimes': repeatTimes,
      'time': time.toString(),
      'enabled': enabled,
    };
  }

  // used for payload stuff
  Map<String, String> toStringMap() {
    return {
      'id': id,
      'nameOfDrug': nameOfDrug,
      'description': description,
      'repeatOption': repeatOption.toString(),
      'daysOfWeek': daysOfWeek.toString(),
      'repeatDuration': repeatDuration.toString(),
      'repeatTimes': repeatTimes.toString(),
      'time': time.toString(),
      'enabled': enabled.toString(),
    };
  }

  // gets an alarm object from the given map
  static Medication fromMap(Map<String, dynamic> data) {
    Medication temp = Medication(
        id: data['id'],
        nameOfDrug: data['nameOfDrug']
    );
    temp.enabled = data["enabled"];
    temp.daysOfWeek = parseDaysOfWeekString(data['daysOfWeek']);
    if (!data.containsKey('repeatDuration')) {
      temp.repeatDuration = const Duration(days: 1);
    }
    else {
      temp.repeatDuration = parseStringDuration(data['repeatDuration']);
    }
    if (!data.containsKey('repeatTimes')) {
      temp.repeatTimes = 1;
    } else {
      temp.repeatTimes = data['repeatTimes'];
    }

    RepeatOption tempRepeatOption;
    if (data['repeatOption'] == 'RepeatOption.daily')
    {
      tempRepeatOption = RepeatOption.daily;
    }
    else if (data['repeatOption'] == 'RepeatOption.daysInterval')
    {
      tempRepeatOption = RepeatOption.daysInterval;
    }
    else if (data['repeatOption'] == 'RepeatOption.specificDays')
    {
      tempRepeatOption = RepeatOption.specificDays;
    }
    else
    {
      tempRepeatOption = RepeatOption.asNeeded;
    }
    return temp;
  }

  // same function as above just different types
  static Medication fromStringMap(Map<String, String> data) {
    Medication temp = Medication(
      id: data['id'] ?? "",
      nameOfDrug: data['nameOfDrug'] ?? "",
    );

    bool enabled;
    if (data['enabled'] == 'true') {
      enabled = true;
    }
    else {
      enabled = false;
    }

    List<TimeOfDay> time = [];
    temp.description = data["description"] ?? "";
    temp.repeatOption = stringToRepeatOption(data["repeatOption"]);
    temp.daysOfWeek = parseDaysOfWeekString(data['daysOfWeek'] ?? "");
    temp.repeatDuration = parseStringDuration(data['repeatDuration'] ?? const Duration(days: 1).toString());
    temp.repeatTimes = int.parse(data['repeatTimes'] ?? "1");
    temp.time = timeOfDayStringsToList(data["time"]);
    temp.enabled = enabled;
    return temp;
  }
}
