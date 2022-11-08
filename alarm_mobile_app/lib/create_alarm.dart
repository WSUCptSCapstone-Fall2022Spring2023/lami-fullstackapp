// represents the create alarm screen for the app
// allows the user to create a new alarm with the given information
// also allows the user to cancel that transaction
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';
import 'package:alarm_mobile_app/alarm.dart';
import 'package:alarm_mobile_app/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

// maximum number used for random id generation (2^32 - 1)
const int maxID = 2147483647;

class CreateAlarm extends StatelessWidget {
  const CreateAlarm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = "Alliance House Medication Reminder";

    return MaterialApp(
      title: appTitle,
      darkTheme: ThemeColors.darkData,
      theme: ThemeColors.lightData,
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const CreateAlarmForm(),
      ),
    );
  }
}

// Create a Form widget.
class CreateAlarmForm extends StatefulWidget {
  const CreateAlarmForm({Key? key}) : super(key: key);

  @override
  CreateAlarmFormState createState() {
    return CreateAlarmFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class CreateAlarmFormState extends State<CreateAlarmForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final medicationcontroller = TextEditingController();
  final descriptioncontroller = TextEditingController();
  final repeattimescontroller = TextEditingController();
  late TimeOfDay time = TimeOfDay.now();
  late bool enabled = true;
  late int durationvalue = 24;
  // will have to change in the future - depends on type used to get time
  final timecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (repeattimescontroller.text == "") {
      repeattimescontroller.text = "1";
    }
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.

            // Medication name
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "Enter the name of your medication.",
                labelText: 'Medication',
                labelStyle: TextStyle(fontSize: 20),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the name of your medication.';
                }
                return null;
              },
              controller: medicationcontroller,
            ),

            // input the time for medication
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // button
                  onPrimary: Colors.white, // letter
                  fixedSize: const Size(200.0, 60.0),
                ),
                onPressed: () async {
                  final TimeOfDay? result = await showTimePicker(
                      context: context,
                      initialTime: time,
                      initialEntryMode: TimePickerEntryMode.input);
                  if (result != null) {
                    setState(() {
                      time = result;
                    });
                  }
                },
                child: const Text(
                  'Set Time',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            // Description for medication
            TextFormField(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description',
                  labelStyle: TextStyle(fontSize: 20),
                  hintText:
                      "Enter the description of your medication (if needed)."),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the description for your medicaiton.';
                }
                return null;
              },
              controller: descriptioncontroller,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Repeat alarm',
                labelStyle: TextStyle(fontSize: 20),
                hintText: "Alarm will be repeated an amount of times per day",
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (int.tryParse(value ?? "1") == null) {
                  return "Enter a valid number";
                }
                int duration = durationvalue;
                int repeattimes = int.parse(value ?? "1");
                if (repeattimes < 1) return "Value must be greater than 0";
                if (duration * repeattimes > 24) {
                  return "Reduce either the repeat times or duration of alarm (cannot total more than 24 hours)";
                }
                return null;
              },
              controller: repeattimescontroller,
            ),
            DropdownButtonFormField<int>(
              value: durationvalue,
              icon: const Icon(Icons.arrow_drop_down),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Select repeat duration (hours): ",
                labelStyle: TextStyle(fontSize: 20),
              ),
              onChanged: (int? newvalue) {
                setState(() {
                  durationvalue = newvalue ?? 24;
                });
              },
              validator: (newvalue) {
                int duration = newvalue ?? 24;
                int repeattimes = int.parse(repeattimescontroller.text);
                if (repeattimes < 1) {
                  return "Repeat times must be greater than 0";
                }
                if (duration * repeattimes > 24) {
                  return "Reduce either the repeat times or duration of alarm (cannot total more than 24 hours)";
                }
                return null;
              },
              // values for list = 4, 8, 12, 24
              items: <int>[4, 8, 12, 24].map<DropdownMenuItem<int>>((int val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(
                    val.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),

            Row(children: [
              const Text(
                "Enabled?",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Switch(
                  value: enabled,
                  onChanged: (value) {
                    setState(() {
                      enabled = value;
                    });
                  },
                  activeColor: Colors.blue,
                  activeTrackColor: Colors.lightBlueAccent)
            ]),
            // Submit
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // button
                  onPrimary: Colors.white, // letter
                  // shape: CircleBorder(),
                  // fixedSize: Size.fromRadius(60),
                  // fixedSize: Size.fromHeight(50.0)),
                  fixedSize: const Size(200.0, 60.0),
                ),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    FirebaseFirestore inst = FirebaseFirestore.instance;
                    // gets the current user from the local shared preferences
                    Users currentuser = getCurrentUserLocal(pref);
                    CollectionReference users = inst.collection('/users');
                    DocumentSnapshot<Object?> snap =
                        await users.doc(currentuser.id).get();
                    if (snap.exists) {
                      Map<String, dynamic> data =
                          snap.data() as Map<String, dynamic>;
                      if (!data.containsKey('alarms')) {
                        // initializing the alarm collection if it does not exist
                        data['alarms'] = [];
                      }
                      // id is randomly generated - have to do it this way due to being able to delete alarms
                      String id = Random().nextInt(maxID).toString();
                      // creating a new alarm from the given information
                      Alarm newalarm = Alarm(
                          id: id,
                          time: time,
                          nameOfDrug: medicationcontroller.text,
                          description: descriptioncontroller.text,
                          enabled: enabled,
                      daysOfWeek: List.filled(7, true));
                      newalarm.repeatduration = Duration(hours: durationvalue);
                      newalarm.repeattimes =
                          int.parse(repeattimescontroller.text);
                      data['alarms'].add(newalarm.toMap());
                      // adds a new alarm to the users document as a subcollection
                      await users.doc(currentuser.id).update(data);
                      runApp(
                          Home(alarms: convertMapAlarmsToList(data['alarms'])));
                    }
                  }
                },
                child: const Text(
                  'Add Alarm',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // button
                  onPrimary: Colors.white, // letter
                  // shape: CircleBorder(),
                  // fixedSize: Size.fromRadius(60),
                  // fixedSize: Size.fromHeight(50.0)),
                  fixedSize: const Size(200.0, 60.0),
                ),
                onPressed: () {
                  getAlarms(FirebaseAuth.instance.currentUser?.uid,
                          FirebaseFirestore.instance)
                      .then((List<Alarm> value) {
                    runApp(Home(
                      alarms: value,
                    ));
                  });
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
