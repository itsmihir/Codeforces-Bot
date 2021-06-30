import 'package:cfverdict/home.dart';
import 'package:cfverdict/login.dart';
import 'package:cfverdict/provider/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: User(),
        ),
      ],
      child: Consumer<User>(
        builder: (ctx, user, _) => MaterialApp(
          title: 'CodeForces Bot',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.dark,
          home: user.isLoggedIn()
              ? HomePage()
              : FutureBuilder(
                  future: user.tryAutoLogIn(),
                  builder: (ctx, status) {
                    if (status.connectionState == ConnectionState.done) {
                      return LoginScreen();
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
