// represents the admin screen for the app
// displays all the users (except admin users)
// when a user is tapped on, it shows their alarms
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/admin_medications.dart';
import 'package:alarm_mobile_app/medication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'utils.dart';
import 'users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_mobile_app/admin_settings.dart';



class UserItem extends StatelessWidget {
  UserItem({
    required this.users,
  }) : super(key: ObjectKey(users));

  final Users users;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(children: [
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Text(
                "${users.firstname} ${users.lastname}",
                textScaleFactor: 1.25,
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              onPressed: () async {
                CollectionReference userCollection = FirebaseFirestore.instance.collection('/users');
                List<Medication> medications = await getMedications(users.id, userCollection);
                runApp(AdminMedicationPage(medications: medications, username: users.firstname + " " + users.lastname));
              },
              child: const Text(
                "Medications",
                textScaleFactor: 1.3,
              )),
        ]),
        const SizedBox(height: 8)
      ]),
    );
  }
}

class Admin extends StatelessWidget {
  const Admin({required this.users, Key? key}) : super(key: key);
  final List<Users> users;

  @override
  Widget build(BuildContext context) {
    // print(alarms);
    const appTitle = "Alliance House Medication Reminder Admin";

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
                  icon:
                    const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 30,
                    ),
                  onPressed: () async {
                    Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                    runApp(AdminSettingsPage(user: user));
                  }),
            ],
          ),
          body: AdminScreen(users: users),
        ));
  }
}

// Create a Form widget.
class AdminScreen extends StatefulWidget {
  const AdminScreen({required this.users, Key? key}) : super(key: key);
  final List<Users> users;
  @override
  AdminScreenState createState() {
    return AdminScreenState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return UserItem(users: widget.users[index]);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          thickness: 3.0,
          indent: 25,
          endIndent: 25,
        ),
        itemCount: widget.users.length);
  }
}
