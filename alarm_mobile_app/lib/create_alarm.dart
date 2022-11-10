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
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_horizontal_divider/flutter_horizontal_divider.dart';
import 'package:weekday_selector/weekday_selector.dart';

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
  final medicationController = TextEditingController();
  final descriptionController = TextEditingController();
  final repeatTimesController = TextEditingController();
  late TimeOfDay time = TimeOfDay.now();
  late bool enabled = true;
  late int durationValue = 24;
  // will have to change in the future - depends on type used to get time
  final timeController = TextEditingController();
  late List<bool> repeatDays = List<bool>.filled(7, true);

  @override
  Widget build(BuildContext context) {
    if (repeatTimesController.text == "") {
      repeatTimesController.text = "1";
    }
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.

            //// Medication name
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: "Enter the name of your medication.",
                labelText: 'Medication:',
                labelStyle:
                TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the name of your medication.';
                }
                return null;
              },
              controller: medicationController,
            ),
            const SizedBox(height: 5),

            //// Medication Description
            TextFormField(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description:',
                  labelStyle:
                  TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                  hintText:
                  "If needed, enter a short description for the medication."),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'If needed, enter a short description for the medication.';
                }
                return null;
              },
              controller: descriptionController,
            ),

            //// Time
            const SizedBox(height: 10),
            Row(children: const [
              Text(
                "Time:",
                style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
                textAlign: TextAlign.start,
              )
            ]),
            StatefulBuilder(builder: (context, _setState) {
              return Row(children: [
                Text(getStatefulTime(time), style: const TextStyle(fontSize: 30.0)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? result = await showTimePicker(
                        context: context,
                        initialTime: time,
                        initialEntryMode: TimePickerEntryMode.input);
                    if (result != null) {
                      time = result;
                      _setState(() => time = result);
                    }
                  },
                  child: const Text('Edit', style: TextStyle(fontSize: 14.0)),
                )
              ]);
            }),
            const HorizontalDivider(thickness: 2),

            //// Repeat Days
            const SizedBox(height: 5),
            Row(children: const [
              Text("Repeat (Days):",
                  style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic))
            ]),
            WeekdaySelector(
              onChanged: (int day) {
                setState(() {
                  // Use module % 7 as Sunday's index in the array is 0 and
                  // DateTime.sunday constant integer value is 7.
                  final index = day % 7;
                  // We "flip" the value in this example, but you may also
                  // perform validation, a DB write, an HTTP call or anything
                  // else before you actually flip the value,
                  // it's up to your app's needs.
                  repeatDays[index] = !repeatDays[index];
                });
              },
              values: repeatDays,
            ),
            const HorizontalDivider(thickness: 2),

            //// Repeat Hours
            const SizedBox(height: 10),
            Row(children: const [
              Text(
                "Repeat (Hours):",
                style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
                textAlign: TextAlign.start,
              )
            ]),
            StatefulBuilder(builder: (context, _setState) {
              return Row(children: [
                Text(getRepeatDuration(durationValue),
                    style: const TextStyle(fontSize: 25.0)),
                const Spacer(),
                ElevatedButton(
                    onPressed: () async {
                      List? result = await showPickerNumber(context);
                      if (result == null) {
                        return;
                      }
                      _setState(() => durationValue = result[0]);
                    },
                    child: const Text("Edit"))
              ]);
            }),
            const HorizontalDivider(thickness: 2),

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
                          nameOfDrug: medicationController.text,
                          description: descriptionController.text,
                          enabled: enabled,
                      daysOfWeek: repeatDays);
                      newalarm.repeatduration = Duration(hours: durationValue);
                      newalarm.repeattimes =
                          int.parse(repeatTimesController.text);
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
  showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          const NumberPickerColumn(begin: 0, end: 23),
        ]),
        hideHeader: true,
        title: const Text("Please Select a Value\n\t(0 to Disable)"),
        onConfirm: (Picker picker, List value) {
          // alarm.repeatduration = parseStringDuration(value[0].toString());
          setState(() {
            durationValue = value[0] ?? 24;
          });
        }).showDialog(context);
  }
}
