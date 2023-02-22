// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// represents the initialization + starting point of the app - redirects users to the appropriate screen

import 'package:alarm_mobile_app/home.dart';
import 'medication.dart';
import 'package:alarm_mobile_app/medication_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'alarm.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'users.dart';
import 'admin.dart';
import 'notifications.dart';

// starting point of the program, initializes most of the services for the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'PalouseAlarm',
          channelName: 'PalouseAlarm',
          channelDescription: 'PalouseAlarmNotifs',
          defaultColor: Colors.white,
          ledColor: Colors.red,
          importance: NotificationImportance.Max),
    ],
    channelGroups: [
      NotificationChannelGroup(
          channelGroupkey: "PalouseAlarm", channelGroupName: "PalouseAlarm"),
    ],
  );

  // getting permissions (IOS only)
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // used for repeating notifications even w/out the user going back into the app
  // should be using dismissed stream but for some reason it isn't working
  AwesomeNotifications().displayedStream.listen((ReceivedNotification notif) {
    AndroidForegroundService.stopForeground();
    if (notif.payload != null) {
      Alarm alarm = Alarm.fromStringMap(notif.payload ?? {});
      createNotificationTomorrow(
          alarm, DateTime.now().add(const Duration(days: 1)));
    }
  });
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDCFUlDP6sg7nsKKWuOpLj9VhX8-pa37pI",
          appId: "1:547099170398:android:de23c7142de8a41a5b46cf",
          messagingSenderId: "547099170398",
          projectId: "sl-lami-fullstackapp"),
    );
  }
  // starts the app
  runApp(const App());
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  const App({Key? key}) : super(key: key);
  @override
  _AppState createState() => _AppState();
}
// #enddocregion MyApp
// #enddocregion _buildSuggestions

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          FirebaseAuth auth = FirebaseAuth.instance;
          if (auth.currentUser == null) {
            return const LogIn();
          } else {
            getCurrentUser(auth.currentUser!.uid).then((Users u) {
              var pref = SharedPreferences.getInstance();
              pref.then((value) {
                writeToSharedPreferences(u, value);
              });
              // regular user
              if (u.usertype == 'reg') {
                // gets all their alarms and goes to the home screen
                getMedications(auth.currentUser?.uid, FirebaseFirestore.instance)
                    .then((List<Medication> value) {
                  return runApp(MedicationPage(
                    medications: value,
                  ));
                }, onError: (e) {
                  Fluttertoast.showToast(
                      msg:
                          "ERROR Occured - Please contact the house director - ERROR CODE: DB MISMATCH");
                  return runApp(const LogIn());
                });
                // if the current user is admin, run getAllUsers()
              } else if (u.usertype == 'admin') {
                // gets all the users and goes to the admin screen
                getAllUsers(FirebaseFirestore.instance).then(
                    (List<Users> value) {
                  return runApp(Admin(
                    users: value,
                  ));
                }, onError: (e) {
                  Fluttertoast.showToast(
                      msg: // at least, this is reached.
                          "ERROR Occured on admin user - Please contact the house director - ERROR CODE: DB MISMATCH");
                  return runApp(const LogIn());
                });
              } else {
                Fluttertoast.showToast(
                    msg: // at least, this is reached.
                        "ERROR occured: invalid user type");
                return runApp(const LogIn());
              }
            });
          }
        } else {
          return const CupertinoActivityIndicator(animating: true);
        }
        return const CupertinoActivityIndicator(animating: true);
      },
    );
  }
}
