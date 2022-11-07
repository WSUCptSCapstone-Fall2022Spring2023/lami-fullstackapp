// represents the home screen for the app
// displays all the user's alarms and has options on long press to edit and delete that alarm
// also has a button for adding a new alarm and going to the settings page
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/create_alarm.dart';
import 'package:alarm_mobile_app/edit_alarm.dart';
import 'package:alarm_mobile_app/settings.dart';
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

  final _controller = ValueNotifier<bool>(false);
  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    // String getText() {
    //   if (alarm.enabled) {
    //     createNotification(alarm);
    //     return "On";
    //   }
    //   AwesomeNotifications().cancel(int.parse(alarm.id));
    //   return "Off";
    // }

    // Color getColor() {
    //   if (alarm.enabled) {
    //     return Colors.lightGreen;
    //   }
    //   return Colors.red;
    // }

    // represents a single alarm in the home screen
    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(35, 10, 50, 10),
        title: Column(children: [
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Text(
              alarm.nameOfDrug,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: 1.7,
            ))
            // Expanded(
            //     child: Row(
            //         mainAxisAlignment: MainAxisAlignment.end,
            //
            //         children: [
            //   // const Text(
            //   //   "Enabled: ",
            //   //   textScaleFactor: 1.25,
            //   // ),
            //   // ElevatedButton(
            //   //     style: ElevatedButton.styleFrom(
            //   //         primary: getColor(), shape: const CircleBorder()),
            //   //     onPressed: () {},
            //   //     child: Text(getText())),
            // ])),
          ]),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text("Time:  " + alarm.time.format(context),
                    textScaleFactor: 1.2),
              ),
              // Expanded(
              //     child: Text(
              //   "Desc: " + alarm.description,
              //   textScaleFactor: 1.2,
              // )),
              // const SizedBox(width: 70),
              AdvancedSwitch(
                  controller: _controller,
                  width: 80,
                  activeColor: const Color.fromRGBO(24, 150, 190, 1),
                  inactiveColor: const Color.fromRGBO(7, 42, 64, 1),
                  activeChild: const Text('ON',
                      textScaleFactor: 1.3,
                      style:
                          TextStyle(color: Color.fromRGBO(246, 244, 232, 1))),
                  inactiveChild: const Text('OFF',
                      textScaleFactor: 1.3,
                      style:
                          TextStyle(color: Color.fromRGBO(246, 244, 232, 1)))),
              const SizedBox(width: 35),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: () {
                    runApp(EditAlarm(alarm: alarm));
                  },
                  child: const Text(
                    "Edit",
                    textScaleFactor: 1.3,
                  )),
              const SizedBox(width: 30),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  child: const Text(
                    "Delete",
                    textScaleFactor: 1.3,
                  ),
                  onPressed: () async {
                    FirebaseFirestore instance = FirebaseFirestore.instance;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    // secondary confirmation dialog for deleting an alarm
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text("Are you sure?"),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await deleteAlarm(alarm.id, instance);
                                      runApp(Home(
                                          alarms: await getAlarms(
                                              prefs.getString("id") ?? '',
                                              instance)));
                                    },
                                    child: const Text(
                                      "Yes",
                                      textScaleFactor: 1.2,
                                    )),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "No",
                                      textScaleFactor: 1.2,
                                    )),
                              ]);
                        });
                  })
            ],
          ),
        ]));
  }
}

class Home extends StatelessWidget {
  const Home({required this.alarms, Key? key}) : super(key: key);
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
      theme: ThemeColors.lightData,
      themeMode: ThemeMode.system,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
            actions: [
              // settings button
              IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () async {
                    Users user = getCurrentUserLocal(
                        await SharedPreferences.getInstance());
                    user.alarms =
                        await getAlarms(user.id, FirebaseFirestore.instance);
                    runApp(SettingsPage(user: user));
                  }),
            ],
          ),
          body: HomeScreen(alarms: alarms),
          bottomNavigationBar: BottomAppBar(
              color: Colors.white,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 50,
                      ),
                      onPressed: () {},
                    )
                  ])),
          // floatingActionButtonLocation:
          //     FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     runApp(const CreateAlarm());
          //   },
          //   child: const Icon(
          //     Icons.add,
          //     color: Colors.white,
          //     size: 45,
          //   ),
          //   backgroundColor: Colors.blue,
          // )
      ),
    );
  }
}

// Create a Form widget.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.alarms, Key? key}) : super(key: key);
  final List<Alarm> alarms;

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
          return AlarmItem(alarm: widget.alarms[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
              thickness: 3.0,
              indent: 25,
              endIndent: 25,
            ),
        itemCount: widget.alarms.length);
  }
}
