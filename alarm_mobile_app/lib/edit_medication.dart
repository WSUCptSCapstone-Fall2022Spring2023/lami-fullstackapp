// represents the edit alarm screen for the app
// is essentially the create alarm screen, but with the values filled in
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';

import 'package:alarm_mobile_app/alarm.dart';
import 'package:alarm_mobile_app/home.dart';
import 'package:alarm_mobile_app/medication.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_medication.dart';
import 'medication_page.dart';
import 'users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_horizontal_divider/flutter_horizontal_divider.dart';

class EditMedication extends StatelessWidget {
  final Medication medication;
  const EditMedication({Key? key, required this.medication}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const appTitle = "Alliance House Medication Reminder";
    return MaterialApp(
      title: appTitle,
      darkTheme: ThemeColors.darkData,
      theme: ThemeColors.darkData,
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: EditMedicationForm(medication: medication),
      ),
    );
  }
}

// Create a Form widget.
class EditMedicationForm extends StatefulWidget {
  final Medication medication;
  const EditMedicationForm({Key? key, required this.medication}) : super(key: key);
  @override
  EditMedicationFormState createState() {
    return EditMedicationFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class EditMedicationFormState extends State<EditMedicationForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  EditMedicationFormState();

  final _formKey = GlobalKey<FormState>();
  final medicationController = TextEditingController();
  final descriptionController = TextEditingController();
  late RepeatOption repeatOption = RepeatOption.daily;
  late List<bool> repeatDays = List<bool>.filled(7, true);
  late int timesPerDay = 1;
  late List<Alarm> alarms = [];

  @override
  Widget build(BuildContext context) {
    // if (medicationController.text == "") {
    //   medicationController.text = medi.
    //   descriptionController.text = alarm.description;
    //   repeatTimeController.text = alarm.repeattimes.toString();
    //   repeatDurationController.text = alarm.repeatduration.inHours.toString();
    //   durationValue = alarm.repeatduration.inHours;
    // }

    //// Build a Form widget using the _formKey created above.
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
                        alarms = populateAlarms();
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
                  // if (alarms.isEmpty && timesPerDay != 0) {
                  //     alarms = populateAlarms();
                  // }
                  // else if (alarms.length != timesPerDay) {
                  //   alarms = populateAlarms();
                  // }
                  //alarms = await _navigateAndDisplaySelection(context);
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

}

