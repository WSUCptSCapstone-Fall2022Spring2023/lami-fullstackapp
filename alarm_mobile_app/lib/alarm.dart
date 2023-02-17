// represents the alarm class for medication reminders
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'utils.dart';

class Alarm {
  // fields for the table in the database
  // https://api.flutter.dev/flutter/material/showTimePicker.html
  // https://api.flutter.dev/flutter/material/TimeOfDay-class.html
  final String id;
  final TimeOfDay time;
  final String nameOfDrug;
  final String description;
  late bool enabled;
  // default values for repeating x times per day every x amount of times
  late int repeattimes = 1;
  late Duration repeatduration = const Duration(days: 1);
  late List<bool> daysOfWeek = List.filled(7, true);

  // constructor for the values
  Alarm({
    required this.id,
    required this.time,
    required this.nameOfDrug,
    required this.description,
    required this.enabled,
    required this.daysOfWeek
  });

  @override
  String toString() {
    return 'Alarm{id: $id, time: $time, nameOfDrug: $nameOfDrug, description: $description, enabled: $enabled, daysOfWeek: $daysOfWeek)';
  }

  // maps the value from the database to the values present in the alarm class
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toString(),
      'nameOfDrug': nameOfDrug,
      'description': description,
      'enabled': enabled,
      'repeatduration': repeatduration.toString(),
      'repeattimes': repeattimes,
      'daysOfWeek': daysOfWeek.toString()
    };
  }

  // used for payload stuff
  Map<String, String> toStringMap() {
    return {
      'id': id,
      'time': time.toString(),
      'nameOfDrug': nameOfDrug,
      'description': description,
      'enabled': enabled.toString(),
      'repeatduration': repeatduration.toString(),
      'repeattimes': repeattimes.toString(),
      'daysOfWeek': daysOfWeek.toString()
    };
  }

  // gets an alarm object from the given map
  static Alarm fromMap(Map<String, dynamic> data) {
    Alarm temp = Alarm(
      id: data['id'],
      time: parseTimeOfDayString(data['time']),
      nameOfDrug: data['nameOfDrug'],
      description: data['description'],
      enabled: data['enabled'],
      daysOfWeek: parseDaysOfWeekString(data['daysOfWeek'])
    );
    if (!data.containsKey('repeatduration')) {
      temp.repeatduration = const Duration(days: 1);
    } else {
      temp.repeatduration = parseStringDuration(data['repeatduration']);
    }
    if (!data.containsKey('repeattimes')) {
      temp.repeattimes = 1;
    } else {
      temp.repeattimes = data['repeattimes'];
    }
    return temp;
  }

  // same function as above just different types
  static Alarm fromStringMap(Map<String, String> data) {
    bool val;
    if (data['enabled'] == 'true') {
      val = true;
    } else {
      val = false;
    }
    Alarm temp = Alarm(
        id: data['id'] ?? "",
        time: parseTimeOfDayString(data['time'] ?? ""),
        nameOfDrug: data['nameOfDrug'] ?? "",
        description: data['description'] ?? "",
        enabled: val,
        daysOfWeek: parseDaysOfWeekString(data['daysOfWeek'] ?? "")
    );
    temp.repeattimes = int.parse(data['repeattimes'] ?? "1");
    temp.repeatduration = parseStringDuration(
        data['repeatduration'] ?? const Duration(days: 1).toString());
    return temp;
  }
}
