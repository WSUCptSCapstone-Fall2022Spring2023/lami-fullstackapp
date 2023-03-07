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

class AlarmItem extends StatelessWidget {
  AlarmItem({
    required this.alarm,
    required this.isCheckedList,
    required this.index,
    required this.onCheckedChanged,
  }) : super(key: ObjectKey(alarm));

  final Alarm alarm;
  final List<bool> isCheckedList;
  final int index;
  final ValueChanged<bool> onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(30, 15, 50, 10),
      title: Column(children: [
        Row(children: [
          Text(alarm.time.format(context), textScaleFactor: 1.05),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          const SizedBox(width: 25),
          Expanded(
              child: Text(
                alarm.nameOfDrug,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textScaleFactor: 1.7,
              )),
          const SizedBox(width: 25),
          StatefulBuilder(builder: (context, _setState) {
            return Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: isCheckedList[index],
                onChanged: (bool? value) {
                  _setState(() {
                    isCheckedList[index] = value!;
                    onCheckedChanged(value!);
                  });
                },
              ),
            );
          })
        ])
      ]),
    );
  }
}

class TodaysMedications extends StatefulWidget {
  const TodaysMedications({required this.medications, Key? key})
      : super(key: key);

  final List<Medication> medications;

  @override
  _TodaysMedicationsState createState() => _TodaysMedicationsState();
}

class _TodaysMedicationsState extends State<TodaysMedications> {
  late List<bool> _isCheckedList;
  late int _checkedCount;
  late List<Alarm> allAlarms = [];

  @override
  void initState() {
    super.initState();

    int currentDayOfWeek;
    if (DateTime.now().weekday == 7) {
      currentDayOfWeek = 0;
    } else {
      currentDayOfWeek = DateTime.now().weekday;
    }
    for (int i = 0; i < widget.medications.length; i++) {
      if (widget.medications[i].daysOfWeek[currentDayOfWeek] == true) {
        allAlarms.addAll(widget.medications[i].alarms);
      }
    }
    allAlarms.sort((a, b) => toDouble(a.time).compareTo(toDouble(b.time)));
    _isCheckedList = List.generate(allAlarms.length, (index) => allAlarms[index].takenToday);
    _checkedCount = _isCheckedList.where((element) => element).length;
    temp();
  }

  void temp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? lastOpened = pref.getString("lastOpened");
    if (lastOpened != null)
    {
      if (DateTime.parse(lastOpened).day != DateTime.now().day){
        for (int i = 0; i < allAlarms.length; i++){
          _onCheckboxChanged(i, false);
        }
      }
    }
    pref.setString("lastOpened", DateTime.now().toString());
  }


  void _onCheckboxChanged(int index, bool value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore inst = FirebaseFirestore.instance;
    // gets the current user from the local shared preferences
    Users currentUser = getCurrentUserLocal(pref);
    CollectionReference users = inst.collection('/users');
    DocumentSnapshot<Object?> snap =
    await users.doc(currentUser.id).get();
    if (snap.exists) {
      Map<String, dynamic> data =
      snap.data() as Map<String, dynamic>;
      // creating a new alarm from the given information
      Alarm newAlarm = Alarm(
          alarmID: allAlarms[index].alarmID,
          time: allAlarms[index].time,
          nameOfDrug: allAlarms[index].nameOfDrug,
          takenToday: _isCheckedList[index]
      );
      // updating the alarm that was changed
      for (int i = 0; i < (data['medications'] as List<dynamic>).length; i++) {
        for (int j = 0; j <
            (data['medications'][i]['alarms'] as List<dynamic>).length; j++) {
          var checkAlarm = data['medications'][i]['alarms'][j]['alarmID'];
          if (data['medications'][i]['alarms'][j]['alarmID'] ==
              allAlarms[index].alarmID) {
            data['medications'][i]['alarms'][j] = newAlarm.toMap();
            break;
          }
        }
      }
      await users.doc(currentUser.id).update(data);
    }
    setState(()  {
      _isCheckedList[index] = value;
      _checkedCount = _isCheckedList.where((element) => element).length;
    });
  }
  @override
  Widget build(BuildContext context) {
    const appTitle = "Today's Medications";
    // temp();
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
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("character"),
                const SizedBox(height: 130, width: 50),
                Transform.scale(
                  scale: 1.5,
                  child: CircularProgressIndicator(
                    value: _checkedCount / _isCheckedList.length,
                    strokeWidth: 10,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return AlarmItem(
                    alarm: allAlarms[index],
                    isCheckedList: _isCheckedList,
                    index: index,
                    onCheckedChanged: (value) {
                      _onCheckboxChanged(index, value);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(
                  thickness: 3.0,
                  indent: 25,
                  endIndent: 25,
                ),
                itemCount: allAlarms.length,
              ),
            ),
          ],
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
                      runApp(TodaysMedications(medications: widget.medications));
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
                    onPressed: () async {
                      Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                      user.medications = await getMedications(user.id, FirebaseFirestore.instance);
                      runApp(MedicationPage(medications: user.medications));
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
}
