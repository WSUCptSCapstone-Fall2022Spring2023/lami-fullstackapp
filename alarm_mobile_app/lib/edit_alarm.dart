// represents the edit alarm screen for the app
// is essentially the create alarm screen, but with the values filled in
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/alarm.dart';
import 'package:alarm_mobile_app/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weekday_selector/weekday_selector.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_horizontal_divider/flutter_horizontal_divider.dart';

class EditAlarm extends StatelessWidget {
  final Alarm alarm;
  const EditAlarm({Key? key, required this.alarm}) : super(key: key);
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
        body: EditAlarmForm(alarm: alarm),
      ),
    );
  }
}

// Create a Form widget.
class EditAlarmForm extends StatefulWidget {
  final Alarm alarm;
  const EditAlarmForm({Key? key, required this.alarm}) : super(key: key);
  @override
  EditAlarmFormState createState() {
    return EditAlarmFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class EditAlarmFormState extends State<EditAlarmForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  EditAlarmFormState();

  final _formKey = GlobalKey<FormState>();
  final medicationController = TextEditingController();
  final descriptionController = TextEditingController();
  late TimeOfDay time = alarm.time;
  late bool enabled = alarm.enabled;
  late List<bool> repeatDays = alarm.daysOfWeek;
  late Alarm alarm = widget.alarm;
  // final daysController = TextEditingController();
  final timeController = TextEditingController();
  final repeatTimeController = TextEditingController();
  final repeatDurationController = TextEditingController();
  late int durationValue = 24;

  @override
  Widget build(BuildContext context) {
    if (medicationController.text == "") {
      medicationController.text = alarm.nameOfDrug;
      descriptionController.text = alarm.description;
      repeatTimeController.text = alarm.repeattimes.toString();
      repeatDurationController.text = alarm.repeatduration.inHours.toString();
      durationValue = alarm.repeatduration.inHours;
    }

    //// Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
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
                Text(getStatefulTime(alarm.time), style: const TextStyle(fontSize: 30.0)),
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

            //// Alarm On/Off
            Row(children: [
              const Text(
                "Alarm On/Off: ",
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

            //// Submit Button
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // button
                  foregroundColor: Colors.white, // letter
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
                    Users currentUser = getCurrentUserLocal(pref);
                    CollectionReference users = inst.collection('/users');
                    DocumentSnapshot<Object?> snap =
                        await users.doc(currentUser.id).get();
                    if (snap.exists) {
                      Map<String, dynamic> data =
                          snap.data() as Map<String, dynamic>;
                      String id = alarm.id;
                      // creating a new alarm from the given information
                      Alarm newAlarm = Alarm(
                          id: id,
                          time: time,
                          nameOfDrug: medicationController.text,
                          description: descriptionController.text,
                          enabled: enabled,
                          daysOfWeek: repeatDays);
                      newAlarm.repeatduration = Duration(hours: durationValue);
                      newAlarm.repeattimes =
                          int.parse(repeatTimeController.text);
                      // updating the alarm that was changed
                      for (int i = 0;
                          i < (data['alarms'] as List<dynamic>).length;
                          i++) {
                        if (data['alarms'][i]['id'] == newAlarm.id) {
                          data['alarms'][i] = newAlarm.toMap();
                          break;
                        }
                      }
                      // updates the alarm information
                      await users.doc(currentUser.id).update(data);
                      runApp(
                          Home(alarms: convertMapAlarmsToList(data['alarms'])));
                    }
                  }
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),

            //// Cancel Button
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // button
                  foregroundColor: Colors.white, // letter
                  // shape: CircleBorder(),
                  // fixedSize: Size.fromRadius(60),
                  // fixedSize: Size.fromHeight(50.0)),
                  fixedSize: const Size(200.0, 60.0),
                ),
                onPressed: () {
                  getAlarms(FirebaseAuth.instance.currentUser?.uid,
                          FirebaseFirestore.instance)
                      .then((List<Alarm> value) {
                    return runApp(Home(
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

  // getRepeatDuration() {
  //   if (durationValue == 0) {
  //     return "Press Edit to enable";
  //   } else if (durationValue == 1) {
  //     return "Repeat every hour";
  //   } else {
  //     return "Repeat every " + durationValue.toString() + " hours";
  //   }
  // }
  //
  // getStatefulTime(){
  //   int hour = int.parse(time.toString().substring(10, 12));
  //   int minutes = int.parse(time.toString().substring(13, 15));
  //   if (hour > 12){
  //     return (hour - 12).toString() + ':' +time.toString().substring(13, 15) + " PM";
  //   }
  //   return hour.toString() + ':' + time.toString().substring(13, 15) + " AM";
  // }

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



// input the time for medication
// const Text(
//   "Repeat (Hours):",
//   style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic)
// ),
// Row(
//   children: [
//     ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.blue, // button
//       foregroundColor: Colors.white, // letter
//       fixedSize: const Size(200.0, 60.0),
//     ),
//     onPressed: () async {
//       final TimeOfDay? result = await showTimePicker(
//           context: context,
//           initialTime: time,
//           initialEntryMode: TimePickerEntryMode.input);
//       if (result != null) {
//         time = result;
//       }
//     },
//     child: const Text(
//       'Set Time',
//       style: TextStyle(
//         fontSize: 20.0,
//       ),
//     ),
//   )]
// ),

// TextFormField(
//   decoration: const InputDecoration(
//     border: UnderlineInputBorder(),
//     hintText: "Enter a time for your alarm.",
//     labelText: 'Time:',
//     labelStyle:
//         TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
//   ),
//   // The validator receives the text that the user has entered.
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter the name of your medication.';
//     }
//     return null;
//   },
//   controller: medicationController,
// ),

// ElevatedButton(
// style: ElevatedButton.styleFrom(
//   backgroundColor: Colors.blue, // button
//   foregroundColor: Colors.white, // letter
//   fixedSize: const Size(200.0, 60.0),
// ),
// onPressed: () async {
//   final TimeOfDay? result = await showTimePicker(
//       context: context,
//       initialTime: time,
//       initialEntryMode: TimePickerEntryMode.input);
//   if (result != null) {
//     time = result;
//   }
// },
// child: const Text(
//   'Set Time',
//   style: TextStyle(
//     fontSize: 20.0,
//   ),
// ),
//   )


// const SizedBox(height: 10),
// DropdownButtonFormField<int>(
//   value: durationValue,
//   icon: const Icon(Icons.arrow_drop_down),
//   decoration:  InputDecoration(
//     border: const UnderlineInputBorder(),
//     labelText: "Select repeat duration (hours): " + alarm.repeatduration.inHours.toString(),
//     labelStyle:
//         const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
//   ),
//   onChanged: (int? newValue) {
//     durationValue = newValue ?? 24;
//   },
//   validator: (newValue) {
//     int duration = newValue ?? 24;
//     int repeatTimes = int.parse(repeatTimeController.text);
//     if (repeatTimes < 1) {
//       return "Repeat times must be greater than 0";
//     }
//     if (duration * repeatTimes > 24) {
//       return "Reduce either the repeat times or duration of alarm (cannot total more than 24 hours)";
//     }
//     return null;
//   },
//   // values for list = 4, 8, 12, 24
//   items: <int>[4, 8, 12, 24].map<DropdownMenuItem<int>>((int val) {
//     return DropdownMenuItem<int>(
//       value: val,
//       child: Text(
//         val.toString(),
//         style: const TextStyle(fontSize: 20),
//       ),
//     );
//   }).toList(),
// ),


