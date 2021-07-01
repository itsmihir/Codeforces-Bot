import 'dart:async';
import 'dart:convert';
import 'package:cfverdict/command.dart';
import 'package:cfverdict/model/verdict.dart';
import 'package:cfverdict/provider/user.dart';
import 'package:cfverdict/provider/voice.dart';
import 'package:cfverdict/voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts;
  bool _isLoading = true, _isRunning = false;
  Timer _timer;
  String userName;
  int prev = -1;
  final delta = Duration(seconds: 5);
  Map<String, String> commands = new Map();

  void updateCommand(prefs) {
    commands["accepted"] = prefs.getString("accepted");
    commands["partial"] = prefs.getString("partial");
    commands["time"] = prefs.getString("time");
    commands["wrong"] = prefs.getString("wrong");
    commands["memory"] = prefs.getString("memory");
    commands["runtime"] = prefs.getString("runtime");
    commands["compile"] = prefs.getString("compile");
    commands["other"] = prefs.getString("other");
  }

  String getCommand(Verdict verdict) {
    String text;
    switch (verdict.verdict) {
      case "OK":
        {
          text = commands["accepted"];
          break;
        }
      case "PARTIAL":
        {
          text = commands["partial"];
          break;
        }
      case "TIME_LIMIT_EXCEEDED":
        {
          text = commands["time"];
          break;
        }
      case "WRONG_ANSWER":
        {
          text = commands["wrong"];
          break;
        }
      case "MEMORY_LIMIT_EXCEEDED":
        {
          text = commands["memory"];
          break;
        }
      case "RUNTIME_ERROR":
        {
          text = commands["runtime"];
          break;
        }
      case "COMPILATION_ERROR":
        {
          text = commands["compile"];
          break;
        }
      default:
        {
          text = commands["other"];
        }
    }
    return DecodedVoice(verdict).getCommand(text);
  }

  Future<bool> fetchData() async {
    final url = Uri.parse('https://codeforces.com/api/user.status');
    var response = await http
        .post(url, body: {"handle": userName, "from	": "1", "count": "1"});
    if (response.statusCode != 200) {
      await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"))
              ],
              title: Text("Something is wrong"),
              content: Text("Check your internet or your codeforces username"),
            );
          });
      return false;
    }
    final data = json.decode(response.body);
    if (data["result"].isEmpty ||
        data["result"][0]["verdict"].toString() == "null" ||
        data["result"][0]["verdict"].toString() == "TESTING") return true;
    Verdict result = Verdict(
        index: data["result"][0]["problem"]["index"].toString(),
        name: data["result"][0]["problem"]["name"].toString(),
        verdict: data["result"][0]["verdict"].toString(),
        memoryConsumedBytes:
            int.parse(data["result"][0]["memoryConsumedBytes"].toString()),
        timeConsumedMillis:
            int.parse(data["result"][0]["timeConsumedMillis"].toString()),
        passedTestCount:
            int.parse(data["result"][0]["passedTestCount"].toString()));

    if (data["result"][0]["id"] != prev &&
        result.verdict != "TESTING" &&
        _isRunning) {
      _speak(getCommand(result));
    }
    prev = data["result"][0]["id"];
    return true;
  }

  @override
  void initState() {
    flutterTts = FlutterTts();
    SharedPreferences.getInstance().then((prefs) async {
      await Future.wait([
        flutterTts.setLanguage("en-US"),
        flutterTts.setSpeechRate(prefs.getDouble("rate")),
        flutterTts.setVolume(prefs.getDouble("volume")),
        flutterTts.setPitch(prefs.getDouble("pitch")),
      ]);

      updateCommand(prefs);
      userName = Provider.of<User>(context, listen: false).getUserName;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) _timer.cancel();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_isRunning) Text("Bot is up and running."),
                  ElevatedButton(
                      onPressed: () async {
                        if (_isRunning) {
                          FirebaseFirestore.instance
                              .collection('User')
                              .doc(userName)
                              .set({
                            "end": FieldValue.arrayUnion(
                                [DateTime.now().toString()])
                          }, SetOptions(merge: true));
                          _timer.cancel();
                        } else {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) {
                                return Center(
                                    child: CircularProgressIndicator());
                              });
                          final res = await fetchData();
                          Navigator.of(context).pop();
                          if (!res) return;

                          FirebaseFirestore.instance
                              .collection('User')
                              .doc(userName)
                              .set({
                            "start": FieldValue.arrayUnion(
                                [DateTime.now().toString()])
                          }, SetOptions(merge: true));
                          _timer =
                              new Timer.periodic(delta, (timer) => fetchData());
                        }
                        setState(() {
                          _isRunning = !_isRunning;
                        });
                      },
                      child: _isRunning
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Stop Bot"),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Start Bot"),
                            )),
                  if (!_isRunning)
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => VoiceSettingPage()))
                              .then((value) {
                            SharedPreferences.getInstance().then((prefs) {
                              Future.wait([
                                flutterTts
                                    .setSpeechRate(prefs.getDouble("rate")),
                                flutterTts.setVolume(prefs.getDouble("volume")),
                                flutterTts.setPitch(prefs.getDouble("pitch")),
                              ]);
                            });
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Voice Settings"),
                        )),
                  if (!_isRunning)
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => CommandSettingPage()))
                              .then((value) async {
                            final prefs = await SharedPreferences.getInstance();
                            updateCommand(prefs);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Command Settings"),
                        )),
                  if (!_isRunning)
                    ElevatedButton(
                        onPressed: () {
                          Provider.of<User>(context, listen: false).logOut();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Logout"),
                        ))
                ],
              ),
            ),
    );
  }
}
