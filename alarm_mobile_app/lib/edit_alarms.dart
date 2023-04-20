// represents the home screen for the app
// displays all the user's alarms and has options on long press to edit and delete that alarm
// also has a button for adding a new alarm and going to the settings page
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/add_medication.dart';
import 'package:alarm_mobile_app/settings.dart';
import 'package:alarm_mobile_app/add_medication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'notifications.dart';
import 'users.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

class AlarmItem extends StatelessWidget {
  AlarmItem({
    required this.alarm,
  }) : super(key: ObjectKey(alarm));
  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(35, 10, 50, 10),
        title:
        Row(
          children: [
            const SizedBox(height: 40),
            Expanded(child:
            StatefulBuilder(builder: (context, _setState) {
              return Row(children: [
                Text(alarm.time.format(context), style: const TextStyle(fontSize: 20.0)),
                const Spacer(),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(ThemeColors.darkData.primaryColorLight)
                  ),
                  onPressed: () async {
                    final TimeOfDay? result = await showTimePicker(
                        context: context,
                        initialTime: alarm.time,
                        initialEntryMode: TimePickerEntryMode.input);
                    if (result != null) {
                      _setState(() => alarm.time = result);
                    }
                  },
                  child: const Text('Edit', style: TextStyle(fontSize: 14.0)),
                )
              ]);
            }),
            )
          ],
        )
    );
  }
}

class EditAlarms extends StatelessWidget {
  const EditAlarms({required this.alarms, Key? key}) : super(key: key);
  final List<Alarm> alarms;

  @override
  @override
  Widget build(BuildContext context) {
    // when the user enters the home screen, cancel all their notifications
    AwesomeNotifications().cancelAll().then((value) {});
    const appTitle = "Alliance House Medication Reminder";
    return MaterialApp(
        title: appTitle,
        darkTheme: ThemeColors.darkData,
        theme: ThemeColors.darkData,
        themeMode: ThemeMode.system,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
            actions: [
              // settings button
              IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.black, size: 35),
                  onPressed: () {
                    Navigator.pop(context, alarms);
                  }),
            ],
          ),
          body:
          Column(
              children: [
                Expanded(child: EditAlarmsScreen(alarms: alarms)),
              ]
          ),
          bottomNavigationBar:
          BottomAppBar(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const SizedBox(height: 75.0,width: 1.0,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.darkData.primaryColorLight,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                  ),
                  child: const Text(
                      "Save"
                  ),
                  onPressed: () {
                    Navigator.pop(context, alarms);
                  },
                ),
                const SizedBox(height: 75.0,width: 1.0,)
              ],
            ),
            color: ThemeColors.darkData.primaryColorDark,
            notchMargin: 8.0,
          ),
        )
    );
  }
}

// Create a Form widget.
class EditAlarmsScreen extends StatefulWidget {
  const EditAlarmsScreen({required this.alarms, Key? key}) : super(key: key);
  final List<Alarm> alarms;

  @override
  EditAlarmsState createState() {
    return EditAlarmsState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class EditAlarmsState extends State<EditAlarmsScreen> {
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return AlarmItem(alarm: widget.alarms[index]
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          thickness: 3.0,
          indent: 25,
          endIndent: 25,
        ),
        itemCount: widget.alarms.length);
  }
}
