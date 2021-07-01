import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettingPage extends StatefulWidget {
  @override
  _VoiceSettingPageState createState() => _VoiceSettingPageState();
}

class _VoiceSettingPageState extends State<VoiceSettingPage> {
  FlutterTts flutterTts;
  bool _isLoading = true;
  double pitch = 0.5, volume = 0, speechRate = 0;
  double pitchOld = 0.5, volumeOld = 0, speechRateOld = 0;
  String command = "Solution accepted for problem A. CF Bot";
  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    flutterTts = FlutterTts();
    SharedPreferences.getInstance().then((prefs) {
      pitch = prefs.getDouble("pitch");
      volume = prefs.getDouble("volume");
      speechRate = prefs.getDouble("rate");
      pitchOld = pitch;
      volumeOld = volume;
      speechRateOld = speechRate;
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
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Pitch :"),
                    ),
                    Expanded(
                      child: Slider(
                        value: pitch,
                        onChanged: (newPtich) {
                          setState(() {
                            pitch = newPtich;
                          });
                        },
                        min: 0.5,
                        max: 2,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Speech Rate :"),
                    ),
                    Expanded(
                      child: Slider(
                        value: speechRate,
                        onChanged: (val) {
                          setState(() {
                            speechRate = val;
                          });
                        },
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Volume :"),
                    ),
                    Expanded(
                      child: Slider(
                        value: volume,
                        onChanged: (val) {
                          setState(() {
                            volume = val;
                          });
                        },
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () async {
                      await Future.wait([
                        flutterTts.setLanguage("en-US"),
                        flutterTts.setSpeechRate(speechRate),
                        flutterTts.setVolume(volume),
                        flutterTts.setPitch(pitch),
                      ]);
                      await _speak(command);
                    },
                    child: Text("Speak")),
                SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.orange),
                          ),
                          onPressed: () {
                            setState(() {
                              pitch = pitchOld;
                              volume = volumeOld;
                              speechRate = speechRateOld;
                            });
                          },
                          child: Text("Reset")),
                      ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setDouble("pitch", pitch);
                            await prefs.setDouble("volume", volume);
                            await prefs.setDouble("rate", speechRate);

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
              ],
            ),
    );
  }
}
