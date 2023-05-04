// represents the alarm class for medication reminders
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:math';
import 'package:alarm_mobile_app/edit_alarms.dart';
import 'package:alarm_mobile_app/medication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_horizontal_divider/flutter_horizontal_divider.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:alarm_mobile_app/medication_page.dart';
import 'alarm.dart';

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
  late List<Alarm> alarms;

  // constructor for the values
  Medication({
    required this.id,
    required this.nameOfDrug,
  });

  @override
  String toString() {
    return 'Medication{'
        'id: $id,'
        'nameOfDrug: $nameOfDrug,'
        'description: $description,'
        'repeatOption: $repeatOption,'
        'daysOfWeek: $daysOfWeek,'
        'repeatDuration: $repeatDuration,'
        'repeatTimes: $repeatTimes,'
        'alarms: $alarms';
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
      'alarms': alarms.map((i) => i.toMap()).toList(),
    };
  }

  // gets an alarm object from the given map
  static Medication fromMap(Map<String, dynamic> data) {
    Medication medication =
        Medication(id: data['id'], nameOfDrug: data['nameOfDrug']);
    medication.description = data['description'];
    medication.repeatOption = repeatOptionFromString(data['repeatOption']);
    medication.daysOfWeek = parseDaysOfWeekString(data['daysOfWeek']);
    medication.repeatDuration = parseStringDuration(data['repeatDuration']);
    medication.repeatTimes = data['repeatTimes'];
    medication.alarms = data['alarms']
        .map<Alarm>((mapString) => Alarm.fromMap(mapString))
        .toList();
    return medication;
  }

  // same function as above just different types
  static Medication fromStringMap(Map<String, String> data) {
    Medication temp = Medication(
      id: data['id'] ?? "",
      nameOfDrug: data['nameOfDrug'] ?? "",
    );
    temp.description = data["description"] ?? "";
    temp.repeatOption = stringToRepeatOption(data["repeatOption"]);
    temp.daysOfWeek = parseDaysOfWeekString(data['daysOfWeek'] ?? "");
    temp.repeatDuration = parseStringDuration(
        data['repeatDuration'] ?? const Duration(days: 1).toString());
    temp.repeatTimes = int.parse(data['repeatTimes'] ?? "1");
    //temp.alarms = alarmsStringToList(data["alarms"]);
    // temp.alarms = convertAlarmsToMap(alarmsStringToList(data["alarms"]));
    // temp.todaysMedicationsTaken = todaysMedicationsTakenFromString(data['todaysMedicationsTaken']);
    return temp;
  }
}
