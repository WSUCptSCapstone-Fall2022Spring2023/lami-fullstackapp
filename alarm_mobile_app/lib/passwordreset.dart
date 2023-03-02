// represents the password reset screen for the app
// allows the user to enter an email address
// they will get sent a link to reset their password
// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:alarm_mobile_app/resident_login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils.dart';

class PasswordReset extends StatelessWidget {
  const PasswordReset({Key? key}) : super(key: key);

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
        body: const PasswordResetForm(),
      ),
    );
  }
}

// Create a Form widget.
class PasswordResetForm extends StatefulWidget {
  const PasswordResetForm({Key? key}) : super(key: key);

  @override
  PasswordResetFormState createState() {
    return PasswordResetFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class PasswordResetFormState extends State<PasswordResetForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  late FirebaseAuth auth;

  PasswordResetFormState() {
    auth = FirebaseAuth.instance;
  }
  @override
  void dispose() {
    emailcontroller.dispose();
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
                labelText: 'Email for Password Reset',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address.';
                }
                if (!EmailValidator.validate(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              controller: emailcontroller,
              keyboardType: TextInputType.emailAddress,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  // fixedSize: Size(200, 150,),
                  fixedSize: const Size.fromRadius(50),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await auth.sendPasswordResetEmail(
                        email: emailcontroller.text.trim());
                    Fluttertoast.showToast(
                        msg:
                            "Please check your email for the password reset link.");
                    runApp(const ResidentLogIn());
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
