import 'dart:async';
import 'package:call_manager/pass_notification.dart';
import 'package:flutter/material.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/time_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:call_manager/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:call_number/call_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

void main() {
  runApp(new AddNewCallScreen());
}

// Add New Call Screen
class AddNewCallScreen extends StatefulWidget {
  @override
  _AddNewCallScreenState createState() => new _AddNewCallScreenState();
}

class _AddNewCallScreenState extends State<AddNewCallScreen> {
  // Contact Picker stuff
  final ContactPicker _contactPicker = new ContactPicker();
  Contact _contact;

  //TextField controllers
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _phoneFieldController = TextEditingController();
  TextEditingController _descriptionFieldController = TextEditingController();
  TextEditingController _dateFieldController = TextEditingController();
  TextEditingController _timeFieldController = TextEditingController();

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");
  final timeFormat = DateFormat("h:mm a");

  DateTime reminderDate;
  TimeOfDay reminderTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 16.0, bottom: 8.0),
                      child: Text(
                        "Basic Info",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(OMIcons.person),
                  title: TextField(
                    enabled: true,
                    controller: _nameFieldController,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Name (Required)',
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.contacts),
                    onPressed: () async {
                      Contact contact = await _contactPicker.selectContact();
                      setState(() {
                        _contact = contact;
                        _nameFieldController.text = _contact.fullName;
                        _phoneFieldController.text = _contact.phoneNumber.number;
                      });
                    },
                    tooltip: "Choose from Contacts",
                  ),
                ),
                ListTile(
                  leading: Icon(OMIcons.phone),
                  title: TextField(
                    enabled: true,
                    keyboardType: TextInputType.phone,
                    maxLines: 1,
                    autofocus: false,
                    controller: _phoneFieldController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Required)',
                    ),
                  ),
                  trailing: Material(child: SizedBox(width: 48.0,),),
                ),
                ListTile(
                  leading: Icon(OMIcons.comment),
                  title: TextField(
                    enabled: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    autofocus: false,
                    controller: _descriptionFieldController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  trailing: Material(child: SizedBox(width: 48.0,),),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 16.0, left: 16.0, top: 12.0),
                  child: Divider(),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Text(
                        "Reminder",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.today),
                  title: DateTimePickerFormField(
                    format: dateFormat,
                    dateOnly: true,
                    firstDate: DateTime.now(),
                    onChanged: (date) {
                      reminderDate = date;
                      //_dateFieldController.text = date.toString();
                    },
                    controller: _dateFieldController,
                    decoration: InputDecoration(
                      labelText: "Reminder Date",
                    ),
                  ),
                  trailing: Material(child: SizedBox(width: 48.0,),),
                ),
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: TimePickerFormField(
                    format: timeFormat,
                    enabled: true,
                    initialTime: TimeOfDay.now(),
                    onChanged: (timeOfDay) {
                      reminderTime = timeOfDay;
                    },
                    controller: _timeFieldController,
                    decoration: InputDecoration(
                      labelText: "Reminder Time",
                    ),
                  ),
                  trailing: Material(child: SizedBox(width: 48.0,),),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext fabContext) {
          return FloatingActionButton.extended(
            backgroundColor: Colors.blue[700],
            onPressed: () async {
              if(_nameFieldController.text.toString() == "" || _phoneFieldController.text.toString() == "") {
                final snackBar = SnackBar(
                  content: Text("Please enter required fields"),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {

                    }
                  ),
                  duration: Duration(seconds: 3),
                );
                Scaffold.of(fabContext).showSnackBar(snackBar);
              } else {
                try {
                  CollectionReference userCalls = Firestore.instance.collection("Users").document(globals.loggedInUser.uid).collection("Calls");
                  String date;
                  String time;
                  if(reminderDate != null && reminderTime != null){
                    var scheduledNotificationDateTime = DateTime(
                      reminderDate.year,
                      reminderDate.month,
                      reminderDate.day,
                      reminderTime.hour,
                      reminderTime.minute,
                    );
                    var androidPlatformChannelSpecifics =
                      new AndroidNotificationDetails(
                        '1',
                        'Call Reminders',
                        'Allow Call Manager to create and send notifications about Call Reminders',
                      );

                    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

                    NotificationDetails platformChannelSpecifics = new NotificationDetails(
                        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

                    await PassNotification.of(context).schedule(
                      0,
                      'Call Reminder',
                      "Don't forget to call " + _nameFieldController.text + "!",
                      scheduledNotificationDateTime,
                      platformChannelSpecifics,
                      payload: _phoneFieldController.text
                    );

                    date = reminderDate.toString();
                    time = reminderTime.toString();
                  } else {
                    date = "";
                    time = "";
                  }

                  userCalls.add({
                    "Name":_nameFieldController.text,
                    "PhoneNumber":_phoneFieldController.text,
                    "Description":_descriptionFieldController.text,
                    "ReminderDate":date,
                    "ReminderTime":time
                  });
                } catch (e) {
                  print(e);
                } finally {
                  //Navigator.pushNamed(context, "/");
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/HomeScreen', (Route<dynamic> route) => false);
                }
              }
            },
            tooltip: "Save",
            elevation: 2.0,
            icon: new Icon(Icons.save),
            label: Text("Save"),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: Container(
        child: BottomAppBar(
          //hasNotch: false,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}