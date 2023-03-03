// represents the home screen for the app
// displays all the user's alarms and has options on long press to edit and delete that alarm
// also has a button for adding a new alarm and going to the settings page
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/add_medication.dart';
import 'package:alarm_mobile_app/medication.dart';
import 'package:alarm_mobile_app/medication_page.dart';
import 'package:alarm_mobile_app/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'notifications.dart';
import 'users.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

int medicationsTaken = 0;

class AlarmItem extends StatelessWidget {

  AlarmItem({
    required this.alarm, required this.takenNotifier,
  }) : super(key: ObjectKey(alarm));
  final Alarm alarm;
  final ValueNotifier<bool> takenNotifier;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(30, 15, 50, 10),
        title: Column(children: [
          Row(
              children: [

                Text(alarm.time.format(context),
                    textScaleFactor: 1.05
                ),
              ]
          ),
          const SizedBox(height: 5),
          Row(
              children: [
                const SizedBox(width: 25),
                Expanded(
                    child: Text(
                      alarm.nameOfDrug,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.7,
                    )
                ),
                const SizedBox(width: 25),
                StatefulBuilder(builder: (context, _setState) {
                  return Transform.scale(
                    scale: 1.5,
                    child: Checkbox(
                      value: takenNotifier.value,
                      onChanged: (bool? value) {
                        _setState(() {
                          takenNotifier.value = value!;
                        });
                      },
                    ),
                  );
                })
              ]
          )
        ])
    );
  }
}

class TodaysMedications extends StatelessWidget {
  const TodaysMedications({required this.medications, Key? key}) : super(key: key);
  final List<Medication> medications;

  @override
  @override
  Widget build(BuildContext context) {
    // when the user enters the home screen, cancel all their notifications
    AwesomeNotifications().cancelAll().then((value) {});
    const appTitle = "Today's Medications";
    List<Alarm> allAlarms = [];
    int currentDayOfWeek;
    if (DateTime.now().weekday == 7){
      currentDayOfWeek = 0;
    }
    else {
      currentDayOfWeek = DateTime.now().weekday;
    }
    for (int i = 0; i < medications.length; i++){
      if (medications[i].daysOfWeek[currentDayOfWeek] == true){
        allAlarms.addAll(medications[i].alarms);
      }
    }
    allAlarms.sort((a, b) => toDouble(a.time).compareTo(toDouble(b.time)));
    List<ValueNotifier<bool>> medicationsTaken = List.filled(allAlarms.length, ValueNotifier<bool>(false));
    for (int i = 0; i < medicationsTaken.length; i++){
      medicationsTaken[i].addListener(() {
        if (medicationsTaken[i].value == true){
          // progress += 1;

        }
        else{
          // progress -= 1;
        }
      });
    }
    // ValueNotifier<List<bool>> takenNotifier = ValueNotifier(medicationsTaken);

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
                icon: const Icon(Icons.add, color: Colors.black, size: 35),
                onPressed: () async {
                  Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                  user.medications = await getMedications(user.id, FirebaseFirestore.instance);
                  runApp(const AddMedication());
                }),
          ],
        ),
        body:
        Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("character"),
                  const SizedBox(height: 130, width: 50),
                  StatefulBuilder(builder: (context, _setState) {
                    return Transform.scale(
                      scale: 1.5,
                      child:
                      CircularProgressIndicator(
                        value: 0.77,
                        strokeWidth: 10,
                      ),
                    );

                  }),
                ],
              ),
              Expanded(
                  child: HomeScreen(alarms: allAlarms, takenNotifiersList: medicationsTaken)
              )
            ]
        ),

        bottomNavigationBar: BottomAppBar(
            color: ThemeColors.darkData.primaryColorDark,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.darkData.primaryColorLight,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                    ),
                    child: Icon(
                        Icons.calendar_view_day,
                        size: 50,
                        color: ThemeColors.darkData.primaryColorDark
                    ),
                    onPressed: () {
                      runApp(TodaysMedications(medications: medications));
                    },
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.darkData.primaryColorLight,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                    ),
                    child: Icon(
                        Icons.medication,
                        size: 50,
                        color: ThemeColors.darkData.primaryColorDark
                    ),
                    onPressed: () {
                      runApp(MedicationPage(medications: medications));
                    },
                  ),
                  const SizedBox(width: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.darkData.primaryColorLight,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                    ),
                    child: Icon(
                        Icons.person,
                        size: 50,
                        color: ThemeColors.darkData.primaryColorDark
                    ),
                    onPressed: () async {
                      Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                      user.medications = await getMedications(user.id, FirebaseFirestore.instance);
                      runApp(SettingsPage(user: user));
                    },
                  )
                ])),
      ),
    );
  }

  void medicationTakenValueChanged(bool value){

  }

  getPrefValue(String alarmID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(alarmID);
  }
}

// Create a Form widget.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.alarms, Key? key, required this.takenNotifiersList}) : super(key: key);
  final List<Alarm> alarms;
  final List<ValueNotifier<bool>> takenNotifiersList;
  @override
  HomeScreenState createState() {
    return HomeScreenState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {

    // Build a Form widget using the _formKey created above.
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return AlarmItem(alarm: widget.alarms[index], takenNotifier: widget.takenNotifiersList[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          thickness: 3.0,
          indent: 25,
          endIndent: 25,
        ),
        itemCount: widget.alarms.length);
  }
}
