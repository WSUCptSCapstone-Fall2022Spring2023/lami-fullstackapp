// ignore_for_file: avoid_print

import 'package:alarm_mobile_app/medication.dart';
import 'package:alarm_mobile_app/utils.dart';
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

    test('1. Create an user with data for firestore', () {
      // expect(instance.dump(), equals(expectedDumpAfterset));
      print(instance.dump());
    });

    test('2. Add a new medication', () async {
      await instance.collection(usersCollection).doc(uid).set(data);
      CollectionReference users = instance.collection('users');
      DocumentSnapshot<Object?> snap = await users.doc(mockUser.id).get();
      Map<String, dynamic> drugData = snap.data() as Map<String, dynamic>;
      await saveMedicationToFirestore(mockMedication, mockUser, instance);
      // drugData['medications'] = [];
      // drugData['medications'].add(mockMedication.toMap());
      // users.doc(uid).update(drugData);
      // expect(instance.dump(), equals(expectedDumpAfterset));
      print(instance.dump());
    });
  });
}
