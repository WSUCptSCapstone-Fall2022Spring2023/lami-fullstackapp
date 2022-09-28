// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:alarm_mobile_app/users.dart';
import 'package:alarm_mobile_app/alarm.dart';

// could be changed
const uid = 'abc';
const usersCollection = 'users';

void main() {
  group('dump', () {
    final instance = FakeFirebaseFirestore();
    Users anuser = Users(
        email: 'abc@test.com',
        id: uid,
        usertype: "reg",
        firstname: 'Lami',
        lastname: "Alliance");
    anuser.alarms = [];
    Map<String, dynamic> data = anuser.toMap();
    TimeOfDay now = TimeOfDay.now();
    Alarm newalarm = Alarm(
        id: '123',
        time: now,
        nameOfDrug: 'WSU-Pullman',
        description: 'Have one in the morning',
        enabled: true);
    // CollectionReference users = instance.collection('/users');

    test('1. Create an user with data for firestore', () async {
      await instance.collection(usersCollection).doc(uid).set(data);
      // expect(instance.dump(), equals(expectedDumpAfterset));
      print(instance.dump());
    });

    test('2. Change the user\'s email address', () async {
      await instance.collection(usersCollection).doc(uid).set(data);
      CollectionReference users = instance.collection('users');
      users.doc(uid).update({'email': 'def@test.com'});
      // expect(instance.dump(), equals(expectedDumpAfterset));
      print(instance.dump());
    });

    test('3. Try to remove the user', () async {
      await instance.collection(usersCollection).doc(uid).set(data);
      CollectionReference users = instance.collection('users');
      users.doc(uid).delete();
      expect(instance.dump(), equals({"users": {}}));
      print(instance.dump());
    });

    test('4. Adding a new alarm', () async {
      await instance.collection(usersCollection).doc(uid).set(data);
      CollectionReference users = instance.collection('users');
      DocumentSnapshot<Object?> snap = await users.doc(anuser.id).get();
      Map<String, dynamic> drugData = snap.data() as Map<String, dynamic>;
      drugData['alarms'] = [];
      drugData['alarms'].add(newalarm.toMap());
      users.doc(uid).update(drugData);
      // users.doc(uid).update({'email': 'def@test.com'});
      // expect(instance.dump(), equals(expectedDumpAfterset));
      print(instance.dump());
    });

    test('5. Add another user with data for firestore', () async {
      await instance.collection(usersCollection).doc(uid).set(data);
      CollectionReference users = instance.collection('users');
      DocumentSnapshot<Object?> snap = await users.doc(anuser.id).get();
      Map<String, dynamic> drugData = snap.data() as Map<String, dynamic>;
      drugData['alarms'] = [];
      drugData['alarms'].add(newalarm.toMap());
      users.doc(uid).update(drugData);
      Alarm newalarm2 = Alarm(
          id: '124',
          time: now,
          nameOfDrug: 'WSU-Spokane',
          description: 'Takes 1 hour by driving',
          enabled: true);
      drugData['alarms'].add(newalarm2.toMap());
      users.doc(uid).update(drugData);
      // expect(instance.dump(), equals(expectedDumpAfterset));
      print(instance.dump());
    });
  });
}
