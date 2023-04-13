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
    Users mockUser1 = Users(
        id: uid,
        usertype: "reg",
        email: "user@test.com",
        firstname: "firstname",
        lastname: "lastname");
    mockUser1.medications = [];
    Medication mockMedication1 = Medication(id: "mockID1", nameOfDrug: "mockMedication1");
    mockMedication1.description = "mockDescription1";
    mockMedication1.repeatOption = RepeatOption.specificDays;
    mockMedication1.daysOfWeek = List.filled(7, true);
    mockMedication1.repeatDuration = Duration(days: 1);
    mockMedication1.repeatTimes = 1;
    mockMedication1.alarms = [
      Alarm(
        alarmID: "mockAlarm1.1",
        time: TimeOfDay(hour: 8, minute: 30),
        nameOfDrug: 'mockMedication1',
        takenToday: false,
      )
    ];
    Medication mockMedication2 = Medication(id: "mockID2", nameOfDrug: "mockMedication2");
    mockMedication2.description = "mockDescription2";
    mockMedication2.repeatOption = RepeatOption.daysInterval;
    mockMedication2.daysOfWeek = List.filled(7, true);
    mockMedication2.repeatDuration = Duration(days: 1);
    mockMedication2.repeatTimes = 2;
    mockMedication2.alarms = [
      Alarm(
        alarmID: "mockAlarm2.1",
        time: TimeOfDay(hour: 10, minute: 20),
        nameOfDrug: 'mockMedication2',
        takenToday: false,
      ),
      Alarm(
        alarmID: "mockAlarm2.2",
        time: TimeOfDay(hour: 17, minute: 45),
        nameOfDrug: 'mockMedication2',
        takenToday: false,
      )
    ];
    Map<String, dynamic> data = mockUser1.toMap();
    instance.collection(usersCollection).doc(uid).set(data);
    CollectionReference users = instance.collection('users');


    test('1. Get the current user data from firestore', () async {
      // Test
      Users result = await getCurrentUser(uid, users);
      // Evaluation
      expect(mockUser1.toString(), equals(result.toString()));
    });

    test('2. Save medications to firestore', () async {
      // Setup
      mockUser1.medications.add(mockMedication1);
      mockUser1.medications.add(mockMedication2);
      // Test
      await saveMedicationToFirestore(mockMedication1, mockUser1, users);
      // Evaluation
      List<Medication> result = convertMapMedicationsToList(await saveMedicationToFirestore(mockMedication2, mockUser1, users));
      expect(mockUser1.medications.toString(), equals(result.toString()));
    });

    test('3. Get all medications of a user', () async {
      // Test
      List<Medication> result = await getMedications(uid, users);
      // Evaluation
      expect(mockUser1.medications.toString(), equals(result.toString()));
    });

    // test('4. Edit a medication', () async {
    //   mockMedication1.daysOfWeek = [false, true, false, true, true, true];
    //   mockMedication1.description = "I edited this alarm";
    //   mockUser1.medications[0] = mockMedication1;
    //   List<Medication> result = convertMapMedicationsToList(await editMedication(mockUser1, users, mockMedication1));
    //   expect(mockUser1.medications.toString(), equals(result.toString()));
    // });

    test('5. Get all alarms', () async {
      // Setup
      List<Alarm> expected = mockUser1.medications[0].alarms + mockUser1.medications[1].alarms;
      expected.sort((a, b) => toDouble(a.time).compareTo(toDouble(b.time)));
      // Test
      List<Alarm> result = getAllAlarms(mockUser1.medications);
      // Evaluation
      expect(expected.toString(), equals(result.toString()));
    });

    test('6. Mark a medication alarm as taken', () async {
      // Setup
      mockUser1.medications[0].alarms[0].takenToday = true;
      mockUser1.medications[1].alarms[1].takenToday = true;
      List<Alarm> allAlarms = getAllAlarms(mockUser1.medications);
      // Test
      await medicationTakenChanged(mockUser1, users, allAlarms, 0, [true, false, false]);
      await medicationTakenChanged(mockUser1, users, allAlarms, 2, [true, false, true]);
      // Evaluation
      List<Medication> result = await getMedications(uid, users);
      expect(mockUser1.medications.toString(), equals(result.toString()));
    });

    test('7. Delete a medication', () async {
      // Setup
      mockUser1.medications.removeAt(0);
      // Test
      await deleteMedication(mockMedication1.id, uid, users);
      // Evaluation
      List<Medication> result = await getMedications(uid, users);
      expect(mockUser1.medications.toString(), equals(result.toString()));
    });

    // test('8. Update User Information', () async {
    //   expect("", equals(""));
    // });
    //
    // test('9. Get All Users', () async {
    //   expect("", equals(""));
    // });

    // test('10. ', () async {
    //   expect("", equals(""));
    // });
    //
    // test('11. ', () async {
    //   expect("", equals(""));
    // });
    //
    // test('12. ', () async {
    //   expect("", equals(""));
    // });
    //
    // test('13. ', () async {
    //   expect("", equals(""));
    // });
    //
    // test('14. ', () async {
    //   expect("", equals(""));
    // });
    //
    // test('15. ', () async {
    //   expect("", equals(""));
    // });
  });
}
