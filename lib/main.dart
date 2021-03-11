import 'package:call_manager/screens/home_screen.dart';
import 'package:call_manager/screens/login_screen.dart';
import 'package:call_manager/screens/add_new_call_screen.dart';
import 'package:call_manager/utils/pass_notification.dart';
import 'package:call_number/call_number.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize notification plugin
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    initializationSettingsAndroid,
    initializationSettingsIOS,
  );
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      await CallNumber().callNumber(payload);
    },
  );

  // launch app
  runApp(
    PassNotification(
      flutterLocalNotificationsPlugin,
      child: CallManagerApp(),
    ),
  );
}

class CallManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Manager',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue[700],
        accentColor: Colors.blue[700],
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.blue[600],
        ),
        fontFamily: 'SourceSansPro-Bold',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[700],
        accentColor: Colors.blue[700],
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.blue[600],
        ),
        fontFamily: 'SourceSansPro-Bold',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      home: LoginPage(),
      routes: <String, WidgetBuilder>{
        '/HomeScreen': (BuildContext context) => HomeScreen(),
        '/AddNewCallScreen': (BuildContext context) => NewCallScreen(),
        //'/EditCallScreen': (BuildContext context) => EditCallScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
