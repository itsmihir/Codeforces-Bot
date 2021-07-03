import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User with ChangeNotifier {
  String userName;

  Future<void> setVoiceDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble("pitch") == null) {
      await prefs.setDouble("pitch", 1);
      await prefs.setDouble("volume", 1.0);
      await prefs.setDouble("rate", 0.5);
    }
    if (prefs.getString("accepted") == null) {
      await prefs.setString(
          "accepted", "Solution Accepted, for Problem {index}.");
      await prefs.setString("time",
          "TIME LIMIT EXCEEDED on test {passedTestCount+1}, took {timeConsumedMillis} Milliseconds, for Problem {index}.");
      await prefs.setString("memory",
          "MEMORY LIMIT EXCEEDED on test {passedTestCount+1}, took {memoryConsumedBytes/1000000} Mb, for Problem {index}.");
      await prefs.setString("wrong",
          "WRONG ANSWER on test {passedTestCount+1}, for Problem {index}.");
      await prefs.setString("runtime",
          "RUNTIME ERROR on test {passedTestCount+1}, for Problem {index}.");
      await prefs.setString("compile",
          "COMPILATION ERROR on test {passedTestCount+1}, for Problem {index}.");
      await prefs.setString("other",
          "{verdict} on test {passedTestCount+1}, for Problem {index}.");
    }
  }

  void logIn(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", name);
    userName = name;
    await setVoiceDate();
    notifyListeners();
  }

  bool isLoggedIn() {
    return userName != null;
  }

  Future<void> tryAutoLogIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("user");
    if (name != null) {
      userName = name;
      await setVoiceDate();
      notifyListeners();
    }
  }

  void logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
    userName = null;
    notifyListeners();
  }

  get getUserName {
    return userName;
  }
}
