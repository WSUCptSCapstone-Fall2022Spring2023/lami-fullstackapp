import 'package:alarm_mobile_app/add_medication.dart';
import 'package:alarm_mobile_app/medication.dart';
import 'package:alarm_mobile_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'notifications.dart';
import 'users.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:alarm_mobile_app/admin.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:alarm_mobile_app/todays_medications.dart';
import 'package:alarm_mobile_app/edit_medication.dart';



class AdminMedicationItem extends StatelessWidget {
  AdminMedicationItem({
    required this.medication,
  }) : super(key: ObjectKey(medication));
  final Medication medication;


  @override
  Widget build(BuildContext context) {
    // represents a single alarm in the home screen
    return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(35, 10, 50, 10),
        title: Column(children: [
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Text(
                  medication.nameOfDrug,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.7,
                )),
          ]),
        ])
    );
  }
}

class AdminMedicationPage extends StatelessWidget {
  const AdminMedicationPage({required this.medications, Key? key, required this.username}) : super(key: key);
  final List<Medication> medications;
  final String username;

  @override
  @override
  Widget build(BuildContext context) {
    // when the user enters the home screen, cancel all their notifications
    AwesomeNotifications().cancelAll().then((value) {});
    const appTitle = "John's Medications";
    return MaterialApp(
      title: appTitle,
      darkTheme: ThemeColors.darkData,
      theme: ThemeColors.darkData,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          actions: [
            // settings button
            IconButton(
                icon: const Icon(Icons.exit_to_app,
                    color: Colors.black, size: 35),
                onPressed: () async {
                  getAllUsers(FirebaseFirestore.instance).then(
                          (List<Users> value) {
                        return runApp(Admin(
                          users: value,
                        ));
                      });
                }),
          ],
        ),
        body: AdminMedicationScreen(medications: medications),
      ),
    );
  }
}

// Create a Form widget.
class AdminMedicationScreen extends StatefulWidget {
  const AdminMedicationScreen({required this.medications, Key? key}) : super(key: key);
  final List<Medication> medications;

  @override
  AdminMedicationScreenState createState() {
    return AdminMedicationScreenState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class AdminMedicationScreenState extends State<AdminMedicationScreen> {
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return AdminMedicationItem(medication: widget.medications[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          thickness: 3.0,
          indent: 25,
          endIndent: 25,
        ),
        itemCount: widget.medications.length);
  }
}