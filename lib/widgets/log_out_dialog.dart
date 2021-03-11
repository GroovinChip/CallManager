import 'package:call_manager/firebase/firebase_mixin.dart';
import 'package:flutter/material.dart';

class LogOutDialog extends StatefulWidget {
  LogOutDialog({Key key}) : super(key: key);

  @override
  _LogOutDialogState createState() => _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text('Log Out'),
      content: Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('NO'),
        ),
        TextButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          },
          child: Text('YES'),
        ),
      ],
    );
  }
}
