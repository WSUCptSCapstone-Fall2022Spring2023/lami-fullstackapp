// represents the login screen for the app
// has options for logging in, registering, and resetting password
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:alarm_mobile_app/employee_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_mobile_app/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alarm_mobile_app/users.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:alarm_mobile_app/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:alarm_mobile_app/medication_page.dart';

class ResidentLogIn extends StatelessWidget {
  const ResidentLogIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = "Alliance House Medication Reminder";
    // temporary URL - will replace w/ video once that is recorded
    final Uri _url =
        Uri.parse('https://www.youtube.com/channel/UCwEi93Tw9U6z8u4KKXxJJ1g');
    void _launchURL() async {
      if (!await launchUrl(_url)) throw 'Could not launch $_url';
    }

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
            body: const ResidentLogInForm(),
          );
        }));
  }
}

// Create a Form widget.
class ResidentLogInForm extends StatefulWidget {
  const ResidentLogInForm({Key? key}) : super(key: key);

  @override
  ResidentLogInFormState createState() {
    return ResidentLogInFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class ResidentLogInFormState extends State<ResidentLogInForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  late FirebaseAuth auth;
  DateTime _selectedDate = DateTime(DateTime.now().year - 1, 1, 1);

  ResidentLogInFormState() {
    auth = FirebaseAuth.instance;
  }
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            // Add TextFormFields and ElevatedButton here.
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address.';
                }
                return null;
              },
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "Date of Birth",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white)
              ),
              child: SizedBox(
                height: 200,
                child: ScrollDatePicker(
                  selectedDate: DateUtils.dateOnly(_selectedDate),
                  minimumDate: DateTime(DateTime.now().year - 100, 1, 1),
                  maximumDate: DateTime(DateTime.now().year - 10, 12, 31),
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _selectedDate = DateUtils.dateOnly(value);
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight, // button
                ),
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  runApp(const EmployeeLogIn());
                },
                child: const Text('Employee Login'),
              ),
            ),
            // Sign up
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight,  // button
                ),
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  runApp(const Register());
                },
                child: const Text('Sign up?'),
              ),
            ),
            // Submit
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight,
                  shape: const CircleBorder(),
                  // fixedSize: Size(200, 150,),
                  fixedSize: const Size.fromRadius(50),
                ),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // sign in user with firebase auth - await waits until the server returns the user
                    User? user;
                    try {
                      UserCredential credential =
                          await auth.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: _selectedDate.toString() + "R3sident&AcCount*");
                      user = credential.user;
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        Fluttertoast.showToast(
                            msg: "Invalid email");
                      } else if (e.code == 'wrong-password') {
                        Fluttertoast.showToast(
                            msg: "Invalid date of birth");
                      } else {
                        Fluttertoast.showToast(msg: e.code);
                      }
                      return;
                    } catch (e) {
                      Fluttertoast.showToast(msg: e.toString());
                      return;
                    }

                    // valid user - get user variable from db
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    FirebaseFirestore inst = FirebaseFirestore.instance;
                    if (user != null) {
                      Users currentUser = await getCurrentUser(user.uid);
                      await writeToSharedPreferences(currentUser, pref);
                      // if (currentUser.usertype == 'admin') {
                      //   return runApp(Admin(users: await getAllUsers(inst)));
                      // }
                      return runApp(
                          MedicationPage(medications: await getMedications(currentUser.id, inst)));
                      // go to home screen w/ current user
                    } else {
                      //user exists in firebase auth but not in firestore - add to firestore
                      CollectionReference users = inst.collection('users');
                      Users newuser = Users(
                          email: emailController.text,
                          id: user?.uid.toString() ?? '',
                          usertype: "reg",
                          firstname: '',
                          lastname: '');
                      newuser.medications = [];
                      Map<String, dynamic> data = newuser.toMap();
                      data['alarms'] = [];
                      users.doc(newuser.id.toString()).set(data);
                      await writeToSharedPreferences(newuser, pref);
                      runApp(const MedicationPage(medications: []));
                    }
                  } else {
                    //error - user does not exist - display error email/ password is invalid

                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
