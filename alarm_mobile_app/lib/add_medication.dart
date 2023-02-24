// represents the create alarm screen for the app
// allows the user to create a new alarm with the given information
// also allows the user to cancel that transaction
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:math';
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

class AlarmItem extends StatelessWidget {
  AlarmItem({
    required this.alarm,
  }) : super(key: ObjectKey(alarm));
  final Alarm alarm;


  @override
  Widget build(BuildContext context) {
    // represents a single alarm in the home screen
    ValueNotifier<bool> enabledController = ValueNotifier(true);
    enabledController.addListener(() async {
      // if (enabledController.value == true){
      //   alarm.enabled = true;
      // }
      // else
      // {
      //   alarm.enabled = false;
      // }
      // SharedPreferences pref =
      // await SharedPreferences.getInstance();
      // FirebaseFirestore inst = FirebaseFirestore.instance;
      // // gets the current user from the local shared preferences
      // Users currentUser = getCurrentUserLocal(pref);
      // CollectionReference users = inst.collection('/users');
      // DocumentSnapshot<Object?> snap =
      // await users.doc(currentUser.id).get();
      // Alarm newAlarm = Alarm(
      //     id: "id",
      //     time: TimeOfDay.now(),
      //     nameOfDrug: "alarm.nameOfDrug",
      //     description: "alarm.description",
      //     enabled: true,
      //     );
      // newAlarm.repeatduration = const Duration(days: 1);
      // newAlarm.repeattimes = 1;
      // if (snap.exists) {
      //   Map<String, dynamic> data =
      //   snap.data() as Map<String, dynamic>;
      //   String id = alarm.id;
      //   // creating a new alarm from the given information
      //   Alarm newAlarm = Alarm(
      //       id: id,
      //       time: alarm.time,
      //       nameOfDrug: alarm.nameOfDrug,
      //       description: alarm.description,
      //       enabled: alarm.enabled,
      //       daysOfWeek: [true, true, true, true, true, true, true]);
      //   newAlarm.repeatduration = alarm.repeatduration;
      //   newAlarm.repeattimes = alarm.repeattimes;
      //   // updating the alarm that was changed
      //   for (int i = 0; i < (data['alarms'] as List<dynamic>).length; i++) {
      //     if (data['alarms'][i]['id'] == newAlarm.id) {
      //       data['alarms'][i] = newAlarm.toMap();
      //       break;
      //     }
      //   }
      // updates the alarm information
      // await users.doc(currentUser.id).update(data);
      // }
    });

    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(35, 10, 50, 10),
        title: Column(children: [
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Text(
                  "alarm.nameOfDrug",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.7,
                ))
          ]),
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text("Time:  " + "alarm.time.format(context)",
                    textScaleFactor: 1.2),
              ),
              AdvancedSwitch(
                  controller: enabledController,
                  width: 80,
                  activeColor: ThemeColors.darkData.primaryColorLight,
                  inactiveColor: ThemeColors.darkData.disabledColor,
                  activeChild: const Text('ON',
                      textScaleFactor: 1.3,
                      style:
                      TextStyle(color: Color.fromRGBO(246, 244, 232, 1))),
                  inactiveChild: Text('OFF',
                      textScaleFactor: 1.3,
                      style:
                      TextStyle(color: ThemeColors.darkData.primaryColorDark))),
              const SizedBox(width: 35),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  )),
              const SizedBox(width: 30),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.darkData.primaryColorLight,
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
                                      // Navigator.of(context).pop();
                                      // await deleteAlarm(alarm.id, instance);
                                      // runApp(Home2(
                                      //     alarms: await getAlarms(
                                      //         prefs.getString("id") ?? '',
                                      //         instance)));
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
        body: AddMedicationForm()
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
  late List<Alarm> alarms = [
    Alarm(id: "id", time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "dayOfWeek"),
    Alarm(id: "id", time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "dayOfWeek"),
    Alarm(id: "id", time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "dayOfWeek"),
    Alarm(id: "id", time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "dayOfWeek"),
    Alarm(id: "id", time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "dayOfWeek")
  ];

  // will have to change in the future - depends on type used to get time
  //final timeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Medication newMedication = Medication(id: "id", nameOfDrug: 'nameOfDrug');
    newMedication.alarms = alarms;
    // Build a Form widget using the _formKey created above.
    return Scaffold(
            body: ListView(
              children: [
                tempName(),
                MedicationAlarms(alarms: newMedication.alarms),
                saveMedication()
              ],
            )


        // Column(
        //   children: <Widget>[
        //     //// Medication name
        //     TextFormField(
        //       decoration: const InputDecoration(
        //         border: UnderlineInputBorder(),
        //         hintText: "Enter the name of your medication.",
        //         labelText: 'Medication:',
        //         labelStyle:
        //         TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
        //       ),
        //       // The validator receives the text that the user has entered.
        //       validator: (value) {
        //         if (value == null || value.isEmpty) {
        //           return 'Please enter the name of your medication.';
        //         }
        //         return null;
        //       },
        //       controller: medicationController,
        //     ),
        //     const SizedBox(height: 5),
        //     //// Medication Description
        //     TextFormField(
        //       decoration: const InputDecoration(
        //           border: UnderlineInputBorder(),
        //           labelText: 'Dosage Information (Optional):',
        //           labelStyle:
        //           TextStyle(fontSize: 20, fontStyle: FontStyle.italic)
        //       ),
        //       controller: descriptionController,
        //     ),
        //     const SizedBox(height: 10),
        //     //// Frequency
        //     Row(children: const [
        //       Text(
        //         "Frequency:",
        //         style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
        //         textAlign: TextAlign.start,
        //       )
        //     ]),
        //     StatefulBuilder(builder: (context, _setState) {
        //       return Row(children: [
        //         Text(repeatOptionToString(repeatOption),
        //             style: const TextStyle(fontSize: 25.0)),
        //         const Spacer(),
        //         ElevatedButton(
        //             onPressed: () async {
        //               List? result = await repeatOptionPicker(context);
        //               if (result == null) {
        //                 return;
        //               }
        //               _setState(() => repeatOption = result[0]);
        //             },
        //             child: const Text("Edit"))
        //       ]);
        //     }),
        //     const HorizontalDivider(thickness: 2),
        //     //// Repeat Days
        //     Row(children: const [
        //       Text("Repeat (Days):",
        //           style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic))
        //     ]),
        //     WeekdaySelector(
        //       onChanged: (int day) {
        //         setState(() {
        //           final index = day % 7;
        //           repeatDays[index] = !repeatDays[index];
        //         });
        //       },
        //       values: repeatDays,
        //     ),
        //
        //
        //     const HorizontalDivider(thickness: 2),
        //     const SizedBox(height: 10),
        //     //// Times Per Day
        //     Row(children: const [
        //       Text(
        //         "How many times a day?",
        //         style: TextStyle(fontSize: 15.5, fontStyle: FontStyle.italic),
        //         textAlign: TextAlign.start,
        //       )
        //     ]),
        //     StatefulBuilder(builder: (context, _setState) {
        //       return Row(children: [
        //         Text(timesPerDay.toString(),
        //             style: const TextStyle(fontSize: 25.0)),
        //         const Spacer(),
        //         ElevatedButton(
        //             onPressed: () async {
        //               List? result = await timesPerDayPicker(context);
        //               if (result == null) {
        //                 return;
        //               }
        //               _setState(() => timesPerDay = result[0]);
        //             },
        //             child: const Text("Edit"))
        //       ]);
        //     }),
        //     const SizedBox(height: 5),
        //     const HorizontalDivider(thickness: 2),
        //     //// Add Medication
        //     Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 25.0),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           primary: Colors.red, // button
        //           onPrimary: Colors.white, // letter
        //           // shape: CircleBorder(),
        //           // fixedSize: Size.fromRadius(60),
        //           // fixedSize: Size.fromHeight(50.0)),
        //           fixedSize: const Size(200.0, 60.0),
        //         ),
        //         onPressed: () async {
        //           // Validate returns true if the form is valid, or false otherwise.
        //           if (_formKey.currentState!.validate()) {
        //             SharedPreferences pref =
        //                 await SharedPreferences.getInstance();
        //             FirebaseFirestore inst = FirebaseFirestore.instance;
        //             // gets the current user from the local shared preferences
        //             Users currentUser = getCurrentUserLocal(pref);
        //             CollectionReference users = inst.collection('/users');
        //             DocumentSnapshot<Object?> snap =
        //                 await users.doc(currentUser.id).get();
        //             if (snap.exists) {
        //               Map<String, dynamic> data =
        //                   snap.data() as Map<String, dynamic>;
        //               if (!data.containsKey('medications')) {
        //                 // initializing the medications collection if it does not exist
        //                 data['medications'] = [];
        //               }
        //               // id is randomly generated - have to do it this way due to being able to delete alarms
        //               String id = Random().nextInt(maxID).toString();
        //               // creating a new alarm from the given information
        //               Medication newMedication = Medication(
        //                   id: id,
        //                   nameOfDrug: medicationController.text,
        //               );
        //               newMedication.description = descriptionController.text;
        //               newMedication.repeatOption = repeatOption;
        //               newMedication.enabled = enabled;
        //               newMedication.alarms = [Alarm(id: 'id', time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "Monday")];
        //               newMedication.daysOfWeek = repeatDays;
        //               // newMedication.repeatDuration = Duration(hours: durationValue);
        //               newMedication.repeatTimes = timesPerDay;
        //               data['medications'].add(newMedication.toMap());
        //               // adds a new alarm to the users document as a subcollection
        //               await users.doc(currentUser.id).update(data);
        //               runApp(
        //                   MedicationPage(medications: convertMapMedicationsToList(data['medications'])));
        //             }
        //           }
        //         },
        //         child: const Text(
        //           'Add Alarm',
        //           style: TextStyle(
        //             fontSize: 20.0,
        //           ),
        //         ),
        //       ),
        //     ),
        //     //// Cancel
        //     Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 80.0),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           primary: Colors.orange, // button
        //           onPrimary: Colors.white, // letter
        //           // shape: CircleBorder(),
        //           // fixedSize: Size.fromRadius(60),
        //           // fixedSize: Size.fromHeight(50.0)),
        //           fixedSize: const Size(200.0, 60.0),
        //         ),
        //         onPressed: () {
        //           showDialog(
        //             context: context,
        //             builder: (BuildContext context) => _buildPopupDialog(context),
        //           );
        //           // getMedications(FirebaseAuth.instance.currentUser?.uid,
        //           //         FirebaseFirestore.instance)
        //           //     .then((List<Medication> value) {
        //           //   runApp(MedicationPage(
        //           //     medications: value,
        //           //   )
        //         },
        //         child: const Text(
        //           'Cancel',
        //           style: TextStyle(
        //             fontSize: 20.0,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
    );
  }

  Widget tempName()
  {
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
                  List? result = await repeatOptionPicker(context);
                  if (result == null) {
                    return;
                  }
                  _setState(() => repeatOption = result[0]);
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
                  List? result = await timesPerDayPicker(context);
                  if (result == null) {
                    return;
                  }
                  _setState(() => timesPerDay = result[0]);
                },
                child: const Text("Edit"))
          ]);
        }),
        const SizedBox(height: 5),
        const HorizontalDivider(thickness: 2),
        //// Add Medication

        //// Cancel
      ],
    );
  }

  repeatOptionPicker(BuildContext context) {
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
  }

  timesPerDayPicker(BuildContext context) {
    Picker(
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
  }

  String repeatOptionToString(RepeatOption repeatOption) {
    if (repeatOption == RepeatOption.daily) {
      return "Every Day";
    } else if (repeatOption == RepeatOption.specificDays) {
      return "Specific Days";
    } else if (repeatOption == RepeatOption.daysInterval) {
      return "Days Interval";
    } else {
      return "As Needed";
    }
  }

  RepeatOption pickerToRepeatOption(int pickerRepeatOption) {
    if (pickerRepeatOption == 0) {
      return RepeatOption.daily;
    } else if (pickerRepeatOption == 1) {
      return RepeatOption.specificDays;
    } else if (pickerRepeatOption == 2) {
      return RepeatOption.daysInterval;
    } else {
      return RepeatOption.asNeeded;
    }
  }

  getStatefulTime(){
    // int hour = int.parse(time.toString().substring(10, 12));
    // int minutes = int.parse(time.toString().substring(13, 15));
    // if (hour > 12){
    //   return (hour - 12).toString() + ':' + time.toString().substring(13, 15) + " PM";
    // }
    // return hour.toString() + ':' + time.toString().substring(13, 15) + " AM";
    return TimeOfDay.now().toString();
  }

  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Popup example'),
      content: WeekdaySelector(
        onChanged: (int day) {
          setState(() {
            final index = day % 7;
            repeatDays[index] = !repeatDays[index];
          });
        },
        values: repeatDays,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget saveMedication()
  {
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
              if (!data.containsKey('medications')) {
                // initializing the medications collection if it does not exist
                data['medications'] = [];
              }
              // id is randomly generated - have to do it this way due to being able to delete alarms
              String id = Random().nextInt(maxID).toString();
              // creating a new alarm from the given information
              Medication newMedication = Medication(
                id: id,
                nameOfDrug: medicationController.text,
              );
              newMedication.description = descriptionController.text;
              newMedication.repeatOption = repeatOption;
              newMedication.alarms = [Alarm(id: 'id', time: TimeOfDay.now(), nameOfDrug: "nameOfDrug", dayOfWeek: "Monday")];
              newMedication.daysOfWeek = repeatDays;
              // newMedication.repeatDuration = Duration(hours: durationValue);
              newMedication.repeatTimes = timesPerDay;
              data['medications'].add(newMedication.toMap());
              // adds a new alarm to the users document as a subcollection
              await users.doc(currentUser.id).update(data);
              runApp(
                  MedicationPage(medications: convertMapMedicationsToList(data['medications'])));
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
    // Build a Form widget using the _formKey created above.
    // return ListView.separated(
    //           itemBuilder: (BuildContext context, int index) {
    //             return AlarmItem(alarm: widget.alarms[index]);
    //           },
    //           separatorBuilder: (BuildContext context, int index) => const Divider(
    //             thickness: 3.0,
    //             indent: 25,
    //             endIndent: 25,
    //           ),
    //           itemCount: widget.alarms.length);
    return ColumnBuilder(
        key: GlobalKey<FormState>(),
        itemBuilder: (BuildContext context, int index) {
          return AlarmItem(alarm: widget.alarms[index]);
        },
        // separatorBuilder: (BuildContext context, int index) => const Divider(
        //   thickness: 3.0,
        //   indent: 25,
        //   endIndent: 25,
        // ),
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