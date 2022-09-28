// represents the admin screen for the app
// displays all the users (except admin users)
// when a user is tapped on, it shows their alarms
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'alarm.dart';
import 'utils.dart';
import 'users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';

class AlarmItem extends StatelessWidget {
  AlarmItem({
    required this.alarm,
  }) : super(key: ObjectKey(alarm));

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    String getText() {
      if (alarm.enabled) {
        return "On";
      }
      return "Off";
    }

    Color getColor() {
      if (alarm.enabled) {
        return Colors.lightGreen;
      }
      return Colors.red;
    }

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
          color: Colors.black,
          thickness: 0.0,
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
    );
  }
}

class UserItem extends StatelessWidget {
  UserItem({
    required this.users,
  }) : super(key: ObjectKey(users));

  final Users users;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(title: Text(users.firstname + " " + users.lastname),
        //subtitle: Text(users.firstname),
        children: <Widget>[
          Column(children: <Widget>[
            ConstrainedBox(
                // not know why this is working.
                // will fix this later once we find a problem.
                constraints: const BoxConstraints(minHeight: 60.0),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return AlarmItem(alarm: users.alarms[index]);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                          thickness: 4.0,
                          color: Colors.black,
                        ),
                    itemCount: users.alarms.length))
          ])
        ]);
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
                    runApp(SettingsPage(user: user));
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
              thickness: 4.0,
              color: Colors.black,
            ),
        itemCount: widget.users.length);
  }
}
