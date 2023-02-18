// represents the login screen for the app
// has options for logging in, registering, and resetting password
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:alarm_mobile_app/admin.dart';
import 'package:alarm_mobile_app/passwordreset.dart';
import 'package:alarm_mobile_app/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'users.dart';
import 'home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';

class EmployeeLogIn extends StatelessWidget {
  const EmployeeLogIn({Key? key}) : super(key: key);

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
            body: const LogInForm(),
          );
        }));
  }
}

// Create a Form widget.
class LogInForm extends StatefulWidget {
  const LogInForm({Key? key}) : super(key: key);

  @override
  LogInFormState createState() {
    return LogInFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class LogInFormState extends State<LogInForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  late FirebaseAuth auth;

  LogInFormState() {
    auth = FirebaseAuth.instance;
  }
  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
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
              controller: emailcontroller,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password',
              ),
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
              controller: passwordcontroller,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            // Forgot password?
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.darkData.primaryColorLight, // button
                ),
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  runApp(const LogIn());
                },
                child: const Text('Resident Login'),
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
                          email: emailcontroller.text.trim(),
                          password: passwordcontroller.toString());
                      user = credential.user;
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        Fluttertoast.showToast(
                            msg: "Invalid username or password");
                      } else if (e.code == 'wrong-password') {
                        Fluttertoast.showToast(
                            msg: "Invalid username or password");
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
                      Users currentuser = await getCurrentUser(user.uid);
                      await writeToSharedPreferences(currentuser, pref);
                      if (currentuser.usertype == 'admin') {
                        return runApp(Admin(users: await getAllUsers(inst)));
                      }
                      return runApp(
                          Home(alarms: await getAlarms(currentuser.id, inst)));
                      // go to home screen w/ current user
                    } else {
                      //user exists in firebase auth but not in firestore - add to firestore
                      CollectionReference users = inst.collection('users');
                      Users newuser = Users(
                          email: emailcontroller.text,
                          id: user?.uid.toString() ?? '',
                          usertype: "reg",
                          firstname: '',
                          lastname: '');
                      newuser.alarms = [];
                      Map<String, dynamic> data = newuser.toMap();
                      data['alarms'] = [];
                      users.doc(newuser.id.toString()).set(data);
                      await writeToSharedPreferences(newuser, pref);
                      runApp(Home(alarms: []));
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
