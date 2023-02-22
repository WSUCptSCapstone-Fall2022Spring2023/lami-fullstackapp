import 'package:alarm_mobile_app/medication.dart';
import 'package:alarm_mobile_app/utils.dart';

import 'alarm.dart';

// represents the users class for all usersd
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
class Users {
  // fields for the table in the database
  final String id;
  final String usertype;
  final String email;
  final String firstname;
  final String lastname;
  late List<Medication> medications;
  late DateTime dateOfBirth;
  // constructor for the values
  Users({
    required this.id,
    required this.usertype,
    required this.email,
    required this.firstname,
    required this.lastname,
  });

  // should be used only for testing purposes
  @override
  String toString() {
    return 'User{id: $id, email: $email, usertype: $usertype, firstname: $firstname, lastname: $lastname, dateOfBirth: $dateOfBirth)\nMedications{$medications} ';
  }

  // maps the value from the database to the values present in the user class
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usertype': usertype,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'dateOfBirth': dateOfBirth,
      'medications': medications,
    };
  }

  //gets a userobject from the given data - note does not fill the alarm type since that would require this function to be async
  static Users fromMap(Map<String, dynamic> data, String id) {
    Users temp = Users(
      email: data['email'] ?? "unknown email",
      id: id,
      usertype: data['usertype'] ?? "unknown usertype",
      firstname: data['firstname'] ?? "unknown firstname",
      lastname: data['lastname'] ?? "unknown lastname",
    );
    temp.medications = medicationListFromMap(data['medications']);
    temp.dateOfBirth = DateTime.fromMillisecondsSinceEpoch(data['dateOfBirth'].seconds * 1000);
    return temp;
  }

  String getUserType() {
    return usertype;
  }
}
