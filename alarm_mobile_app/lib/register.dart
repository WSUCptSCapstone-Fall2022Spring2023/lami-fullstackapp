// represents the register screen for the app
// allows the user to register a new account
// has to supply a first + last name, email, and password
// by default the user is a reg user - no way in app to change to admin user
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:alarm_mobile_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'users.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

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
        body: const RegisterForm(),
      ),
    );
  }
}

// Create a Form widget.
class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class RegisterFormState extends State<RegisterForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final firstnamecontroller = TextEditingController();
  final lastnamecontroller = TextEditingController();
  late FirebaseAuth auth;
  RegisterFormState() {
    auth = FirebaseAuth.instance;
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
                if (!EmailValidator.validate(value, true, true)) {
                  return "Please enter a valid email address.";
                }
                return null;
              },
              controller: emailcontroller,
              keyboardType: TextInputType.emailAddress,
            ),
            // password
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
            // password confirmation
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password confirmation',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password again.';
                }
                if (value != passwordcontroller.text) {
                  return 'Passwords must match!';
                }
                return null;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            // First name
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'First name',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
              controller: firstnamecontroller,
            ),
            // Last name
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Last name',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
              controller: lastnamecontroller,
            ),

            // Submit
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow[700], // button
                  onPrimary: Colors.white, // letter
                  shape: const CircleBorder(),
                  fixedSize: const Size.fromRadius(60),
                ),
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    // registers the user in firebase auth and signs them in
                    User? user;
                    try {
                      user = (await auth.createUserWithEmailAndPassword(
                              email: emailcontroller.text,
                              password: passwordcontroller.text))
                          .user;
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        Fluttertoast.showToast(
                            msg: "The password provided is too weak");
                      } else if (e.code == 'email-already-in-use') {
                        Fluttertoast.showToast(
                            msg: "The email provided is already in use");
                      }
                    } catch (e) {
                      Fluttertoast.showToast(msg: e.toString());
                    }
                    if (user != null) {
                      // creates a new user with the values in the fields
                      Users newuser = Users(
                          email: emailcontroller.text.trim(),
                          id: user.uid.toString(),
                          usertype: "reg",
                          firstname: firstnamecontroller.text,
                          lastname: lastnamecontroller.text);
                      newuser.alarms = [];
                      await writeToSharedPreferences(newuser, pref);
                      // adds the user to the database
                      CollectionReference users =
                          FirebaseFirestore.instance.collection('/users');
                      Map<String, dynamic> data = newuser.toMap();
                      users.doc(newuser.id.toString()).set(data);
                      runApp(const Home(alarms: []));
                    }
                  }
                },
                child: const Text(
                  'Sign up!',
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
