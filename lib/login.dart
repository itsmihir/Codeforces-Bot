import 'package:cfverdict/provider/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: TextField(
            controller: controller,
            decoration:
                new InputDecoration(hintText: 'Enter Your Codeforces Username'),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              Provider.of<User>(context, listen: false).logIn(controller.text);
            },
            child: Text("Login"))
      ]),
    );
  }
}
