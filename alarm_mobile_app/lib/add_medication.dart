// represents the create alarm screen for the app
// allows the user to create a new alarm with the given information
// also allows the user to cancel that transaction
// Copyright 2018 The Flutter team. All rights reserved.
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

// maximum number used for random id generation (2^32 - 1)
const int maxID = 2147483647;



class AddMedication extends StatelessWidget {
  const AddMedication({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const appTitle = "New Medication";

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
                icon: const Icon(Icons.exit_to_app, color: Colors.black, size: 35),
                onPressed: () async {
                  Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                  user.medications = await getMedications(user.id, FirebaseFirestore.instance);
                  runApp(MedicationPage(medications: user.medications));
                }),
          ],
        ),
        body: AddMedicationForm(key: key)
      ),
    );
  }
}



// Create a Form widget.
class AddMedicationForm extends StatefulWidget {
  const AddMedicationForm({Key? key}) : super(key: key);
  @override
  AddMedicationFormState createState() {
    return AddMedicationFormState();
  }
}



// Define a corresponding State class.
// This class holds data related to the form.
class AddMedicationFormState extends State<AddMedicationForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final medicationController = TextEditingController();
  final descriptionController = TextEditingController();
  late RepeatOption repeatOption = RepeatOption.daily;
  late List<bool> repeatDays = List<bool>.filled(7, true);
  late int timesPerDay = 1;
  late List<Alarm> alarms = [];
  String id = Random().nextInt(maxID).toString();



  // will have to change in the future - depends on type used to get time
  //final timeController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    // creating a new medication from the given information
    // Medication newMedication = Medication(
    //   id: id,
    //   nameOfDrug: medicationController.text,
    // );
    // newMedication.description = descriptionController.text;
    // newMedication.repeatOption = repeatOption;
    // newMedication.alarms = alarms;
    // newMedication.daysOfWeek = repeatDays;
    // // newMedication.repeatDuration = Duration(hours: durationValue);
    // newMedication.repeatTimes = timesPerDay;
    // Build a Form widget using the _formKey created above.
    return Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(25),
              children: [
                basicMedicationInformation(),
                //MedicationAlarms(key: _formKey, alarms: newMedication.alarms),
                saveMedication()
              ],
            )
    );
  }

  Widget basicMedicationInformation() {
    return Column(
      children: <Widget>[
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
              labelText: 'Dosage Information (Optional):',
              labelStyle:
              TextStyle(fontSize: 20, fontStyle: FontStyle.italic)
          ),
          controller: descriptionController,
        ),
        const SizedBox(height: 10),
        //// Frequency
        Row(children: const [
          Text(
            "Frequency:",
            style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
            textAlign: TextAlign.start,
          )
        ]),
        StatefulBuilder(builder: (context, _setState) {
          return Row(children: [
            Text(repeatOptionToString(repeatOption),
                style: const TextStyle(fontSize: 25.0)),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  Picker(
                      adapter: PickerDataAdapter(
                          data: [
                            PickerItem(text: const Text("Every Day")),
                            PickerItem(text: const Text("Specific Days")),
                            PickerItem(text: const Text("Days Interval")),
                            PickerItem(text: const Text("As Needed"))
                          ]
                      ),
                      hideHeader: true,
                      title: const Text("Frequency"),
                      onConfirm: (Picker picker, List value) {
                        setState(() {
                          repeatOption = pickerToRepeatOption(value[0]);
                        });
                      }).showDialog(context);
                },
                child: const Text("Edit"))
          ]);
        }),
        const HorizontalDivider(thickness: 2),
        //// Repeat Days
        Row(children: const [
          Text("Repeat (Days):",
              style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic))
        ]),
        WeekdaySelector(
          onChanged: (int day) {
            setState(() {
              final index = day % 7;
              repeatDays[index] = !repeatDays[index];
            });
          },
          values: repeatDays,
        ),
        const HorizontalDivider(thickness: 2),
        const SizedBox(height: 10),
        //// Times Per Day
        Row(children: const [
          Text(
            "How many times a day?",
            style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
            textAlign: TextAlign.start,
          )
        ]),
        StatefulBuilder(builder: (context, _setState) {
          return Row(children: [
            Text(timesPerDay.toString(),
                style: const TextStyle(fontSize: 25.0)),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  final result = await Picker(
                      adapter: NumberPickerAdapter(data: [
                        const NumberPickerColumn(begin: 1, end: 24),
                      ]),
                      hideHeader: true,
                      title: const Text("Times Per Day"),
                      onConfirm: (Picker picker, List value) {
                        //alarm.repeatduration = parseStringDuration(value[0].toString());
                        setState(() {
                          timesPerDay = value[0] + 1;
                        });
                      }).showDialog(context);
                  // if (result == null) {
                  //   return;
                  // }
                  // List<Alarm> alarms2 = populateAlarms();
                  // _setState(() => timesPerDay = result[0] = alarms.length);
                },
                child: const Text("Edit"))
          ]);
        }),
        const SizedBox(height: 5),
        const HorizontalDivider(thickness: 2),
        //// Add Medication
        const SizedBox(height: 10),
        //// Times Per Day
        Row(children: const [
          Text(
            "View/Edit Alarms",
            style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
            textAlign: TextAlign.start,
          )
        ]),
        StatefulBuilder(builder: (context, _setState) {
          return Row(children: [
            // Text(timesPerDay.toString(),
            //     style: const TextStyle(fontSize: 25.0)),
            const Spacer(),
            ElevatedButton(
                onPressed: () async {
                  if (alarms.isEmpty && timesPerDay != 0) {
                      alarms = populateAlarms();
                  }
                  else if (alarms.length != timesPerDay) {
                    alarms = populateAlarms();
                  }
                  alarms = await _navigateAndDisplaySelection(context);
                },
                child: const Text("View/Edit Alarms"))
          ]);
        }),
        const SizedBox(height: 5),
        //// Cancel
      ],
    );
  }

  List<Alarm> populateAlarms(){
    List<Alarm> list = List<Alarm>.empty(growable: true);
    // list.length = timesPerDay;
    for (int i = 0; i < timesPerDay; i++){
      list.add(
          Alarm(
            alarmID: Random().nextInt(maxID).toString(),
            time: TimeOfDay(hour: i+8, minute: i),
            nameOfDrug: medicationController.text,
            dayOfWeek: 'Monday'
          )
      );
    }
    return list;
  }

  Future<List<Alarm>> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => EditAlarms(alarms: alarms)),
    );
    return result as List<Alarm>;
  }

  Widget saveMedication() {
    return Padding(
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
          if (medicationController.text.trim() != "") {
            SharedPreferences pref =
            await SharedPreferences.getInstance();
            FirebaseFirestore inst = FirebaseFirestore.instance;
            // gets the current user from the local shared preferences
            Users currentUser = getCurrentUserLocal(pref);
            CollectionReference users = inst.collection('/users');
            DocumentSnapshot<Object?> snap =
            await users.doc(currentUser.id).get();
            if (snap.exists) {
              Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
              if (!data.containsKey('medications')) {
                // initializing the medications collection if it does not exist
                data['medications'] = [];
              }
              // id is randomly generated - have to do it this way due to being able to delete alarms
              String id = Random().nextInt(maxID).toString();
              // creating a new medication from the given information
              Medication newMedication = Medication(
                id: id,
                nameOfDrug: medicationController.text,
              );
              newMedication.description = descriptionController.text;
              newMedication.repeatOption = repeatOption;
              newMedication.daysOfWeek = repeatDays;
              newMedication.repeatDuration = const Duration(days: 1);
              newMedication.repeatTimes = timesPerDay;
              newMedication.alarms = alarms;
              data['medications'].add(newMedication.toMap());
              // adds a new alarm to the users document as a subcollection
              await users.doc(currentUser.id).update(data);
              runApp(MedicationPage(medications: convertMapMedicationsToList(data['medications'])));
            }
          }
        },
        child: const Text(
          'Save',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}



class AlarmItem extends StatelessWidget {
  AlarmItem({
    required this.alarm,
  }) : super(key: ObjectKey(alarm));
  final Alarm alarm;
  @override
  Widget build(BuildContext context) {
    // represents a single alarm in the home screen
    ValueNotifier<bool> enabledController = ValueNotifier(true);
    enabledController.addListener(() async {});
    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(35, 10, 50, 10),
        title:
        Row(
          children: [
            const SizedBox(width: 10),
            const Expanded(
              child: Text("Time:  " + "alarm.time.format(context)",
                  textScaleFactor: 1.2),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.darkData.primaryColorLight,
                    minimumSize: const Size(120, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  // runApp(EditAlarm(alarm: alarm));
                },
                child: const Text(
                  "Edit",
                  textScaleFactor: 1.3,
                )
            )
          ],
        )
    );
  }
}



// Create a Form widget.
class MedicationAlarms extends StatefulWidget {
  const MedicationAlarms({required this.alarms, Key? key}) : super(key: key);
  final List<Alarm> alarms;

  @override
  MedicationAlarmsState createState() {
    return MedicationAlarmsState();
  }
}



// Define a corresponding State class.
// This class holds data related to the form.
class MedicationAlarmsState extends State<MedicationAlarms> {
  @override
  Widget build(BuildContext context) {
    return ColumnBuilder(
        key: GlobalKey<FormState>(),
        itemBuilder: (BuildContext context, int index) {
          return AlarmItem(alarm: widget.alarms[index]);
        },
        itemCount: widget.alarms.length,
        textDirection: TextDirection.ltr,);
  }
}




// Row(children: [
//   const Text(
//     "Enabled?",
//     style: TextStyle(
//       fontSize: 20.0,
//     ),
//   ),
//   Switch(
//       value: enabled,
//       onChanged: (value) {
//         setState(() {
//           enabled = value;
//         });
//       },
//       activeColor: Colors.blue,
//       activeTrackColor: Colors.lightBlueAccent)
// ]),