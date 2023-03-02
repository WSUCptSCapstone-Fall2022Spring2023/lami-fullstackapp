import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_mobile_app/utils.dart';
import 'package:alarm_mobile_app/users.dart';

/*
  Functions with * means they need cloud_firestore.dart inside

  *Future<List<Alarm>> getAlarms(String? uid, FirebaseFirestore instance) async;
  *Future<Users> getCurrentUser(String uid) async;
  Users getCurrentUserLocal(SharedPreferences pref);
  Future<void> writeToSharedPreferences(Users user, SharedPreferences pref) async;
  TimeOfDay parseTimeOfDayString(String time);
  *Future<bool> deleteAlarm(String id, FirebaseFirestore instance) async;
  List<Alarm> convertMapAlarmsToList(List<dynamic> alarms);
  DateTime convertFromTimeOfDay(TimeOfDay time);
  *Future<List<Users>> getAllUsers(FirebaseFirestore instance) async;
  *Future<void> updateUser(Users user) async;
  *Future<void> updateUserPassword(FirebaseAuth auth, String newPassword) async;
*/

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('getCurrentUserLocal(SharedPreferences pref) tests', () {
    Map<String, Object> mockUser = <String, Object>{
      "email": "example@wsu.edu",
      "id": "123456789",
      "usertype": "reg",
      "firstname": 'Pullman',
      "lastname": 'Moscow',
      "medications": []
    };
    test('Try to get the current user', () async {
      SharedPreferences.setMockInitialValues(mockUser);
      final pref = await SharedPreferences.getInstance();
      Users user = getCurrentUserLocal(pref);

      expect(user.email, "example@wsu.edu");
      expect(user.id, "123456789");
      expect(user.usertype, "reg");
      expect(user.firstname, "Pullman");
      expect(user.lastname, "Moscow");
    });
  });

  group("writeToSharedPreferences(Users user, SharedPreferences pref) tests", () {
    Map<String, Object> testuser = <String, Object>{
      "email": "example@wsu.edu",
      "id": "123456789",
      "usertype": "reg",
      "firstname": 'Pullman',
      "lastname": 'Moscow',
      "alarms": []
    };

    Users testuser2 = Users(
        id: "123456789",
        usertype: "reg",
        email: "example@wsu.edu",
        firstname: "Washington",
        lastname: "Idaho");

    Users testuser3 =
        Users(id: "", usertype: "", email: "", firstname: "", lastname: "");

    test('Try to write a user into SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(testuser);
      final pref = await SharedPreferences.getInstance();
      await writeToSharedPreferences(testuser2, pref);

      expect(pref.getString("email"), "example@wsu.edu");
      expect(pref.getString("id"), "123456789");
      expect(pref.getString("usertype"), "reg");
      expect(pref.getString("firstname"), "Washington");
      expect(pref.getString("lastname"), "Idaho");
    });

    test('Try to write a user into SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(testuser);
      final pref = await SharedPreferences.getInstance();
      await writeToSharedPreferences(testuser3, pref);

      expect(pref.getString("email"), "");
      expect(pref.getString("id"), "");
      expect(pref.getString("usertype"), "");
      expect(pref.getString("firstname"), "");
      expect(pref.getString("lastname"), "");
    });
  });

  group("parseTimeOfDayString(String time) tests", () {
    test('Sends the string of the current time', () {
      TimeOfDay expected = const TimeOfDay(hour: 12, minute: 33);
      TimeOfDay result = parseTimeOfDayString(expected.toString());
      // Expects the function returns an object of TimeOfDay
      expect(expected, result);
    });
  });

  group("convertFromTimeOfDay(TimeOfDay time) tests", () {
    test(
        'time.hour < now.hour || (time.hour == now.hour && time.minute <= now.minute)',
        () async {
      const TimeOfDay t = TimeOfDay(hour: 0, minute: 0);
      final DateTime n = DateTime.now();
      final DateTime nt =
          DateTime(n.year, n.month, n.day + 1, t.hour, t.minute);

      // Expects DateTime(now.year, now.month, now.day + 1, time.hour, time.minute)
      expect(nt, convertFromTimeOfDay(t));
    });

    // needs to run before 11PM since the function uses DateTime.now() inside
    test('else', () async {
      const TimeOfDay t = TimeOfDay(hour: 23, minute: 0);
      final DateTime n = DateTime.now();
      final DateTime nt = DateTime(n.year, n.month, n.day, t.hour, t.minute);

      // Expects DateTime(now.year, now.month, now.day, time.hour, time.minute)
      expect(nt, convertFromTimeOfDay(t));
    });
  });

  // parseDaysOfWeekString
  // convertMapMedicationsToList
  // convertFromTimeOfDay
  // parseStringDuration
  // stringToRepeatOption
  // repeatOptionToString
  // medicationListFromMap
  // alarmsStringToList
  // repeatOptionFromString
}
