// holds all the utility functions for this project
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'users.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

// represents the theming info for light, dark, high-contrast, and dark high-contrast themes
// should never be instantiated
abstract class ThemeColors {
  static ThemeData darkData = ThemeData(
      brightness: Brightness.dark,
      primaryColorDark: const Color.fromRGBO(7, 42, 64, 1),
      primaryColorLight: const Color.fromRGBO(24, 183, 190, 1),
      scaffoldBackgroundColor: const Color.fromRGBO(7, 42, 64, 1),
      bottomAppBarColor: const Color.fromRGBO(24, 183, 190, 1),
      disabledColor: const Color.fromRGBO(246, 244, 232, 1),
      appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark, color: Color.fromRGBO(24, 183, 190, 1)));
  static ThemeData lightData = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark, color: Colors.blue));
}

///Gets the list of alarms associated with the given userid
///@returns the list of alarms if it is found [] if not
///This function is async and returns a future to allow for non-asynchrous functions to use this method
///Throws an exception if the user was not found or the userid is null
Future<List<Alarm>> getAlarms(String? uid, FirebaseFirestore instance) async {
  if (uid != null) {
    CollectionReference users = FirebaseFirestore.instance.collection('/users');
    DocumentSnapshot<Object?> snap = await users.doc(uid).get();
    if (snap.exists) {
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      if (!data.containsKey('alarms')) {
        // initializing the alarm collection if it does not exist
        data['alarms'] = [];
      }
      List<Alarm> alarms = [];
      for (var element in data['alarms']) {
        alarms.add(Alarm.fromMap(element));
      }
      return alarms;
    }
  }
  throw Exception("User does not exist in the database!");
}

///gets the user associated with that uid
///@param uid: uid that is generated from firebaseauthentication
///@return returns the user object that is associated with that uid
///note: function has to be async due to get()
Future<Users> getCurrentUser(String uid) async {
  FirebaseFirestore inst = FirebaseFirestore.instance;
  CollectionReference users = inst.collection('users');
  DocumentSnapshot<Object?> snap = await users.doc(uid).get();
  if (snap.exists) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return Users.fromMap(data, uid);
  }
  throw Exception("ERROR USER DOES NOT EXIST");
}

///gets the current user object that is stored in the shared preferences
///@param pref - instance of sharedpreferences
///@return returns the user object - note that alarms is not stored in sharedpreferences
Users getCurrentUserLocal(SharedPreferences pref) {
  return Users(
      id: pref.getString("id") ?? '',
      usertype: pref.getString("usertype") ?? '',
      email: pref.getString("email") ?? '',
      firstname: pref.getString("firstname") ?? '',
      lastname: pref.getString("lastname") ?? '');
}

/// writes the given user to the shared preferences
/// @param user: user to be written
/// @param pref: instance of shared preferences
/// note: this function is async due to how sharedprefences writes data
Future<void> writeToSharedPreferences(
    Users user, SharedPreferences pref) async {
  await pref.setString("id", user.id);
  await pref.setString("firstname", user.firstname);
  await pref.setString("lastname", user.lastname);
  await pref.setString("usertype", user.usertype);
  await pref.setString("email", user.email);
}

///Parses the given TimeOfDay string into a TimeOfDayObject
///@param time must be in format TimeOfDay(hr:min)
///@return returns a timeofday object
TimeOfDay parseTimeOfDayString(String time) {
  time = time.substring(time.indexOf("(") + 1, time.length - 1);
  return TimeOfDay(
      hour: int.parse(time.split(":")[0]),
      minute: int.parse(time.split(":")[1]));
}

parseDaysOfWeekList(List days){
}

List<bool> parseDaysOfWeekString(String days){
  var parseList = days.substring(1, days.length-1).split(', ');
  var returnList = List.filled(7, true);
  for (int i = 0; i < 7; i++)
    {
      if (parseList[i] == 'true')
        {
          returnList[i] = true;
        }
      else
        {
          returnList[i] = false;
        }
    }
  return returnList;
}

/// deletes the given alarmid from the users collection and returns true if it exists, false otherwise
/// @param id: alarm id
/// @param instance: instance of firebasefirestore
/// @return returns true if the alarm exists in the users alarms collection, false otherwise
/// note: this function is async due to how firestore works
Future<bool> deleteAlarm(String id, FirebaseFirestore instance) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String uid = pref.getString("id") ?? '';
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  DocumentSnapshot<Object?> snap = await users.doc(uid).get();
  if (snap.exists) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    // looping through the collection of alarms - note it is a list
    for (int i = 0; i < data['alarms'].length; i++) {
      // checking to see if that specific alarm id exists
      if (data['alarms'][i]['id'] == id) {
        data['alarms'].removeAt(i);
        break;
      }
    }
    await users.doc(uid).update(data);
    return true;
  }
  return false;
}

/// converts the list of Map<String,dynamic> alarms to a List<Alarm> - used due to how firestore data is stored
/// @param alarms: List<String,dynamic> with all the alarms
/// @return returns the converted List with the Alarm type
List<Alarm> convertMapAlarmsToList(List<dynamic> alarms) {
  List<Alarm> temp = [];
  for (var v in alarms) {
    Map<String, dynamic> tempval = v as Map<String, dynamic>;
    temp.add(Alarm.fromMap(tempval));
  }
  return temp;
}

/// converts the given TimeOfDay object to a datetime object - with day + 1 if the time if < the current time
/// @param time: timeofday object
/// @return returns a DateTime object w/ day + 1 if time is before the current time
DateTime convertFromTimeOfDay(TimeOfDay time) {
  DateTime now = DateTime.now();
  // bunch of conversion stuff - namely edge cases
  if (time.hour < now.hour) {
    DateTime newtime =
        DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
    return newtime;
  } else if (time.hour == now.hour && time.minute <= now.minute) {
    DateTime newtime =
        DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
    return newtime;
  }
  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
}

// gets all the users that are reg type and returns the list of them
// note has to be async due to querying the db
Future<List<Users>> getAllUsers(FirebaseFirestore instance) async {
  try {
    // was running into issues w/ caching when testing - decided to clear cache before retrieving most updated info
    await instance.clearPersistence();
  } finally {
    CollectionReference users = FirebaseFirestore.instance.collection('/users');
    List<Users> allusers = [];
    // stream of all users whose type = 'reg'
    var stream = users.where("usertype", isEqualTo: "reg").snapshots();
    // getting the info stored in each user doc
    var reguserslist = (await stream.first).docs;
    for (var element in reguserslist) {
      Map<String, dynamic> user = element.data() as Map<String, dynamic>;
      Users temp = Users.fromMap(user, user["id"]);
      List<Alarm> alarms = [];
      if (!user.containsKey('alarms')) {
        // initializing the alarm collection if it does not exist
        user['alarms'] = [];
      }
      for (var element in user['alarms']) {
        alarms.add(Alarm.fromMap(element));
      }
      temp.alarms = alarms;
      allusers.add(temp);
    }
    // ignore: control_flow_in_finally
    return allusers;
  }
}

// syncs the data locally with the data in the db
Future<void> updateUser(Users user) async {
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  DocumentSnapshot<Object?> snap = await users.doc(user.id).get();
  if (snap.exists) {
    var data = snap.data() as Map<String, dynamic>;
    data['firstname'] = user.firstname;
    data['lastname'] = user.lastname;
    data['email'] = user.email;
    await users.doc(user.id).update(data);
  }
}

// calls an user and updates his/her password.
Future<void> updateUserPassword(FirebaseAuth auth, String newPassword) async {
  User? user = auth.currentUser;
  try {
    await user!.updatePassword(newPassword);
    Fluttertoast.showToast(msg: "Your password updated!");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(msg: "The password provided is too weak");
    } else if (e.code == 'requires-recent-login') {
      Fluttertoast.showToast(msg: "Please log in after log out");
    }
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}

// parses the output of Duration.toString() back to a Duration type
// format is HH:MM:SS.mmmmmm
// ignores everything except hours
Duration parseStringDuration(String dur) {
  List<String> values = dur.split(":");
  return Duration(hours: int.parse(values[0]));
}


