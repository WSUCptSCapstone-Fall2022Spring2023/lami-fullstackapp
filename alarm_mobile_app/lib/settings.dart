// represents the settings screen for the app
// allows the user to change their information including first + last name
// email and password
// also allows the user to log out if necessary
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/admin.dart';
import 'package:alarm_mobile_app/resident_login.dart';
import 'package:alarm_mobile_app/medication.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alarm_mobile_app/medication_page.dart';
import 'package:alarm_mobile_app/todays_medications.dart';

class SettingsPage extends StatelessWidget {
  final Users user;
  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = "Profile";
    // temporary URL - will replace w/ video once that is recorded
    final Uri _url =
        Uri.parse('https://www.youtube.com/channel/UCwEi93Tw9U6z8u4KKXxJJ1g');
    void _launchURL() async {
      if (!await launchUrl(_url)) throw 'Could not launch $_url';
    }
    // Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
    // user.medications = await getMedications(user.id, FirebaseFirestore.instance);
    CollectionReference users = FirebaseFirestore.instance.collection('/users');
    return MaterialApp(
        title: appTitle,
        darkTheme: ThemeColors.darkData,
        theme: ThemeColors.darkData,
        themeMode: ThemeMode.system,
        home: Builder(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(appTitle),
              actions: [
                //help button
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Need Help?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _launchURL();
                                    },
                                    child: const Text(
                                      "Click Me!",
                                      textScaleFactor: 1.5,
                                    )),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 22),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Dismiss",
                                        textScaleFactor: 1.5))
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.help, color: Colors.black))
              ],
            ),
            body: SettingsPageForm(
              user: user,
            ),
            bottomNavigationBar: BottomAppBar(
                color: ThemeColors.darkData.primaryColorDark,
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.darkData.primaryColorLight,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                        ),
                        child: Icon(
                            Icons.calendar_view_day,
                            size: 50,
                            color: ThemeColors.darkData.primaryColorDark
                        ),
                        onPressed: () async {
                          Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                          runApp(TodaysMedications(medications: await getMedications(user.id, users)));
                        },
                      ),
                      const SizedBox(width: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.darkData.primaryColorLight,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                        ),
                        child: Icon(
                            Icons.medication,
                            size: 50,
                            color: ThemeColors.darkData.primaryColorDark
                        ),
                          onPressed: () async {
                            Users user = getCurrentUserLocal(await SharedPreferences.getInstance());
                            runApp(MedicationPage(medications: await getMedications(user.id, users)));
                          },
                      ),
                      const SizedBox(width: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.darkData.primaryColorLight,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20)
                        ),
                        child: Icon(
                            Icons.person,
                            size: 50,
                            color: ThemeColors.darkData.primaryColorDark
                        ),
                        onPressed: () async {
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          runApp(SettingsPage(user: getCurrentUserLocal(pref)));
                        },
                      )
                    ])),
          );
        }));
  }
}

// Create a Form widget.
class SettingsPageForm extends StatefulWidget {
  final Users user;
  const SettingsPageForm({Key? key, required this.user}) : super(key: key);

  @override
  SettingsPageFormState createState() {
    return SettingsPageFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SettingsPageFormState extends State<SettingsPageForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  SettingsPageFormState();
  final _formKey = GlobalKey<FormState>();
  final firstnamecontroller = TextEditingController();
  final lastnamecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  late SharedPreferences pref;
  @override
  Widget build(BuildContext context) {
    firstnamecontroller.text = widget.user.firstname;
    lastnamecontroller.text = widget.user.lastname;
    emailcontroller.text = widget.user.email;
    CollectionReference users = FirebaseFirestore.instance.collection('/users');
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
                labelText: 'First Name',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return "Enter a first name!";
                }
                return null;
              },
              controller: firstnamecontroller,
            ),
            // Description for medication
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Last Name',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null) {
                  return "Enter a last name!";
                }
                return null;
              },
              controller: lastnamecontroller,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email Address',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (!EmailValidator.validate(value ?? '')) {
                  return "Please enter a valid email!";
                }
                return null;
              },
              controller: emailcontroller,
            ),
            // Submit
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight,  // letter
                  fixedSize: const Size(200.0, 60.0),
                ),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    Users currentuser = Users(
                        id: widget.user.id,
                        email: emailcontroller.text,
                        usertype: widget.user.usertype,
                        firstname: firstnamecontroller.text,
                        lastname: lastnamecontroller.text);
                    await FirebaseAuth.instance.currentUser
                        ?.updateEmail(emailcontroller.text);
                    await updateUser(currentuser);
                    writeToSharedPreferences(
                        currentuser, await SharedPreferences.getInstance());
                    // Users are allowed to change their names and emails without their passwords
                    if (passwordcontroller.text.isNotEmpty) {
                      Fluttertoast.showToast(msg: "Changed password.");
                      // used to change the password
                      String newPassword = passwordcontroller.text;
                      await updateUserPassword(
                          FirebaseAuth.instance, newPassword);
                    }
                    if (getCurrentUserLocal(
                                await SharedPreferences.getInstance())
                            .usertype ==
                        'reg') {
                      getMedications(FirebaseAuth.instance.currentUser?.uid, users)
                          .then((List<Medication> value) {
                        return runApp(MedicationPage(
                          medications: value,
                        ));
                      });
                    } else {
                      return runApp(Admin(
                          users:
                              await getAllUsers(FirebaseFirestore.instance)));
                    }
                  }
                },
                child: const Text(
                  'Save Changes',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight,
                  fixedSize: const Size(200.0, 60.0),
                ),
                onPressed: () async {
                  FirebaseAuth instance = FirebaseAuth.instance;
                  return showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Log Out?',
                            textScaleFactor: 1,
                          ),
                          actions: [
                            TextButton(
                                onPressed: () async {
                                  await AwesomeNotifications().cancelAll();
                                  await instance.signOut();
                                  runApp(const ResidentLogIn());
                                },
                                child: const Text(
                                  "Confirm",
                                  textScaleFactor: 1.2,
                                )),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Cancel",
                                  textScaleFactor: 1.2,
                                ))
                          ],
                        );
                      });
                },
                child: const Text(
                  'Log Out',
                  textDirection: TextDirection.ltr,
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
