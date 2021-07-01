import 'package:cfverdict/model/verdict.dart';
import 'package:cfverdict/provider/voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommandSettingPage extends StatefulWidget {
  @override
  _CommandSettingPageState createState() => _CommandSettingPageState();
}

class _CommandSettingPageState extends State<CommandSettingPage> {
  final Verdict dummy = new Verdict(
      index: "A",
      name: "CF Bot",
      verdict: "Accepted",
      passedTestCount: 100,
      timeConsumedMillis: 1000,
      memoryConsumedBytes: 10000000);
  bool _isLoading = true;
  FlutterTts flutterTts;
  SharedPreferences prefs;
  TextEditingController accepted = new TextEditingController();
  TextEditingController partial = new TextEditingController();
  TextEditingController time = new TextEditingController();
  TextEditingController wrong = new TextEditingController();
  TextEditingController memory = new TextEditingController();
  TextEditingController runtime = new TextEditingController();
  TextEditingController compile = new TextEditingController();
  TextEditingController other = new TextEditingController();
  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  String validateAll() {
    String errors = "";

    String res = DecodedVoice(dummy).validate(accepted.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(partial.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(time.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(wrong.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(memory.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(runtime.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(compile.text);
    if (res != "OK") errors += res + "\n";

    res = DecodedVoice(dummy).validate(other.text);
    if (res != "OK") errors += res + "\n";

    return (errors.isEmpty ? "OK" : errors);
  }

  @override
  void initState() {
    flutterTts = FlutterTts();
    SharedPreferences.getInstance().then((pref) async {
      prefs = pref;
      await Future.wait([
        flutterTts.setLanguage("en-US"),
        flutterTts.setSpeechRate(prefs.getDouble("rate")),
        flutterTts.setVolume(prefs.getDouble("volume")),
        flutterTts.setPitch(prefs.getDouble("pitch")),
      ]);

      accepted.text = prefs.getString("accepted");
      partial.text = prefs.getString("partial");
      time.text = prefs.getString("time");
      wrong.text = prefs.getString("wrong");
      memory.text = prefs.getString("memory");
      runtime.text = prefs.getString("runtime");
      compile.text = prefs.getString("compile");
      other.text = prefs.getString("other");
      setState(() {
        _isLoading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("Accepted : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: accepted,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(DecodedVoice(dummy)
                                    .getCommand(accepted.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("Pretest Passed : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: partial,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(DecodedVoice(dummy)
                                    .getCommand(partial.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("Wrong Answer : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: wrong,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(
                                    DecodedVoice(dummy).getCommand(wrong.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("TLE : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: time,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(
                                    DecodedVoice(dummy).getCommand(time.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("MLE : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: memory,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(DecodedVoice(dummy)
                                    .getCommand(memory.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("Runtime Error : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: runtime,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(DecodedVoice(dummy)
                                    .getCommand(runtime.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("Compilation Error : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: compile,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(DecodedVoice(dummy)
                                    .getCommand(compile.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                          child: Text("Other : "),
                        ),
                        Expanded(
                          child: TextField(
                            controller: other,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: () {
                                _speak(
                                    DecodedVoice(dummy).getCommand(other.text));
                              },
                              child: Text("Try")),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.purple),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      scrollable: true,
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Ok"))
                                      ],
                                      content: SelectableText(
                                          "Variables\n\n - index : String. Usually, a letter or letter with digit(s) indicating the problem index in a contest\n\n - name : String. Problem Title.\n\n - verdict : String. Verdict of the submission.\n\n - passedTestCount : Integer. Number of passed tests.\n\n - timeConsumedMillis : Integer. Maximum time in milliseconds, consumed by solution for one test.\n\n - memoryConsumedBytes : Integer. Maximum memory in bytes, consumed by solution for one test.\n\n\n Note\n\n - You Can only use only one variable in one {}/block."),
                                    );
                                  });
                            },
                            child: Text("Help")),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                            ),
                            onPressed: () async {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  });
                              String res = validateAll();
                              if (res != "OK") {
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (_) =>
                                        AlertDialog(content: Text(res)));
                                return;
                              }

                              await Future.wait([
                                prefs.setString("accepted", accepted.text),
                                prefs.setString("partial", partial.text),
                                prefs.setString("time", time.text),
                                prefs.setString("wrong", wrong.text),
                                prefs.setString("memory", memory.text),
                                prefs.setString("runtime", runtime.text),
                                prefs.setString("compile", compile.text),
                                prefs.setString("other", other.text)
                              ]);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text("Save")),
                        ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"))
                      ]),
                  SizedBox(height: 30),
                ],
              ));
  }
}
