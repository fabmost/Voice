import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voice_inc/translations.dart';

class FlagScreen extends StatelessWidget {
  static const routeName = '/flag';

  void _sendFlag(context, id, reason) async {
    final user = await FirebaseAuth.instance.currentUser();
    WriteBatch batch = Firestore.instance.batch();

    batch.updateData(Firestore.instance.collection('content').document(id), {
      'flag': FieldValue.arrayUnion([user.uid])
    });
    batch.setData(Firestore.instance.collection('flag').document(), {
      'user_id': user.uid,
      'content_id': id,
      'reason': reason,
      'createdAt': Timestamp.now(),
    });

    await batch.commit();
    _showAlert(context);
  }

  void _showAlert(context) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_flag_title')),
        content: Text(Translations.of(context).text('dialog_flag_content')),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _flagCard(context, id, motive) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _sendFlag(context, id, motive),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Text(motive),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translations.of(context).text('title_flag'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 16),
            Text(Translations.of(context).text('label_flag')),
            SizedBox(height: 16),
            _flagCard(context, id, Translations.of(context).text('flag_1')),
            SizedBox(height: 16),
            _flagCard(context, id, Translations.of(context).text('flag_2')),
            SizedBox(height: 16),
            _flagCard(context, id, Translations.of(context).text('flag_3')),
          ],
        ),
      ),
    );
  }
}
