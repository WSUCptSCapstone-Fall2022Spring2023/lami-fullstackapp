// ignore_for_file: avoid_print

import 'package:alarm_mobile_app/medication.dart';
import 'package:alarm_mobile_app/add_medication.dart';
import 'package:alarm_mobile_app/utils.dart';
import 'package:alarm_mobile_app/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:alarm_mobile_app/users.dart';
import 'package:alarm_mobile_app/alarm.dart';

// could be changed
const uid = 'mockUID';
const usersCollection = 'users';


void main() {
  group('dump', () {
    final instance = FakeFirebaseFirestore();
    Users mockUser = Users(
        id: uid,
        usertype: "reg",
        email: "user@test.com",
        firstname: "firstname",
        lastname: "lastname");
    mockUser.medications = [];
    Map<String, dynamic> data = mockUser.toMap();
    instance.collection(usersCollection).doc(uid).set(data);

    Medication mockMedication =
    Medication(id: "mockID", nameOfDrug: "mockMedication");
    mockMedication.description = "mockDescription";
    mockMedication.repeatOption = RepeatOption.specificDays;
    mockMedication.daysOfWeek = List.filled(7, true);
    mockMedication.repeatDuration = Duration(days: 1);
    mockMedication.repeatTimes = 2;
    mockMedication.alarms = [
      Alarm(
        alarmID: "mockAlarm1",
        time: TimeOfDay(hour: 8, minute: 30),
        nameOfDrug: 'mockMedication',
        takenToday: false,
      )
    ];

    //CollectionReference users = instance.collection('users');


    test('1. Get the current user data from firestore', () async {
      //Users result = await getCurrentUser(uid, users);
      //expect(mockUser.toString(), equals(result.toString()));
    });

    test('2. Add a new medication', () async {
      // mockUser.medications.add(mockMedication);
      // List<Medication> result = convertMapMedicationsToList(await saveMedicationToFirestore(mockMedication, mockUser, users, instance));
      // expect(mockUser.medications.toString(), equals(result.toString()));
    });

    test('3. Get Medications', () async {
      // List<Medication> result = await getMedications(uid, users);
      // expect(mockUser.medications.toString(), equals(result.toString()));
    });

    test('4. Edit a Medication', () async {
      //expect(, equals());
    });

    test('5. Delete a medication', () async {
      // mockUser.medications.clear();
      // await deleteMedication(mockMedication.id, instance, uid, users);
      // List<Medication> result = await getMedications(uid, users);
      // expect(mockUser.medications.toString(), equals(result.toString()));
    });

    test('6. Update User Information', () async {
      //expect(, equals());
    });

    test('7. Get All Users', () async {
      //expect(, equals());
    });

    test('8. ', () async {
      //expect(, equals());
    });

    test('9. ', () async {
      //expect(, equals());
    });

    test('10. ', () async {
      //expect(, equals());
    });

    test('11. ', () async {
      //expect(, equals());
    });

    test('12. ', () async {
      //expect(, equals());
    });

    test('13. ', () async {
      //expect(, equals());
    });

    test('14. ', () async {
      //expect(, equals());
    });

    test('15. ', () async {
      //expect(, equals());
    });


  });
}
