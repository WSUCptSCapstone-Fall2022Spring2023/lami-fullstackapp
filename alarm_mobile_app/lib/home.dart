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

class AlarmItem extends StatelessWidget {
  AlarmItem({
    required this.alarm,
  }) : super(key: ObjectKey(alarm));

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    String getText() {
      if (alarm.enabled) {
        createNotification(alarm);
        return "On";
      }
      AwesomeNotifications().cancel(int.parse(alarm.id));
      return "Off";
    }

    Color getColor() {
      if (alarm.enabled) {
        return Colors.lightGreen;
      }
      return Colors.red;
    }

    // represents a single alarm in the home screen
    return ListTile(
      title: Column(children: [
        Row(children: [
          Expanded(
              child: Text(
            alarm.nameOfDrug,
            textScaleFactor: 1.25,
          )),
          Expanded(
              child: Row(children: [
            const Text(
              "Enabled: ",
              textScaleFactor: 1.25,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: getColor(), shape: const CircleBorder()),
                onPressed: () {},
                child: Text(getText()))
          ]))
        ]),
        const Divider(
          thickness: 3.0,
        ),
        Row(
          children: [
            Expanded(
                child: Text(
              "Time: " + alarm.time.format(context),
              textScaleFactor: 1.2,
            )),
            Expanded(
                child: Text(
              "Desc: " + alarm.description,
              textScaleFactor: 1.2,
            ))
          ],
        )
      ]),
      onLongPress: () async {
        FirebaseFirestore instance = FirebaseFirestore.instance;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        return showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: const Text(
                    "Change Alarm",
                    textScaleFactor: 1,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          runApp(EditAlarm(alarm: alarm));
                        },
                        child: const Text(
                          "Edit Alarm",
                          textScaleFactor: 1.2,
                        )),
                    TextButton(
                        child: const Text(
                          "Delete Alarm",
                          textScaleFactor: 1.2,
                        ),
                        onPressed: () {
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
                                            await deleteAlarm(
                                                alarm.id, instance);
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
                  ]);
            });
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({required this.alarms, Key? key}) : super(key: key);
  final List<Alarm> alarms;
  @override
  Widget build(BuildContext context) {
    // when the user enters the home screen, cancel all their notifications
    AwesomeNotifications().cancelAll().then((value) {});
    const appTitle = "Alliance House Medication Reminder";
    return MaterialApp(
      title: appTitle,
      theme: ThemeColors.darkData,
      themeMode: ThemeMode.dark,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
            actions: [
              // settings button
              IconButton(
                  icon: const Icon(Icons.settings, color: Color.fromRGBO(246, 244, 232, 1)),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              runApp(const CreateAlarm());
            },
            child: const Icon(
              Icons.add,
              color: Color.fromRGBO(246, 244, 232, 1),
            )
          )),
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
              thickness: 4.0,
              color: Colors.black,
            ),
        itemCount: widget.alarms.length);
  }
}
