import 'package:call_manager/widgets/call_card.dart';
import 'package:call_manager/firebase/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This widget represents the content on the main screen of the app
class CallCardList extends StatefulWidget {
  @override
  _CallCardListState createState() => _CallCardListState();
}

class _CallCardListState extends State<CallCardList> with FirebaseMixin {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore.calls(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return Center(
              child: const CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  final ds = snapshot.data.docs[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CallCard(callSnapshot: ds),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  'Nothing here!',
                  style: Theme.of(context).textTheme.headline6,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
