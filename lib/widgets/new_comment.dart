import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';
import '../translations.dart';

class NewComment extends StatefulWidget {
  final DocumentReference reference;

  NewComment(this.reference);

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends State<NewComment> {
  final _controller = TextEditingController();
  var _enteredMessage = '';

  void _anonymousAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(Translations.of(context).text('dialog_need_account')),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.red,
            child: Text(Translations.of(context).text('button_cancel')),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
            textColor: Theme.of(context).accentColor,
            child: Text(Translations.of(context).text('button_create_account')),
          ),
        ],
      ),
    );
  }

  void _sendComment() async {
    FocusScope.of(context).unfocus();
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert();
      return;
    }
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    String commentId =
        Firestore.instance.collection('chats').document().documentID;
    WriteBatch batch = Firestore.instance.batch();

    batch.setData(
        Firestore.instance.collection('comments').document(commentId), {
      'comments': 0,
      'parent': widget.reference,
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userImage': userData['image'],
      'username': userData['user_name']
    });
    batch.updateData(userData.reference, {
      'comments': FieldValue.arrayUnion([commentId]),
    });
    batch.updateData(widget.reference, {
      'comments': FieldValue.increment(1),
      'interactions': FieldValue.increment(1)
    });
    batch.commit();
    setState(() {
      _enteredMessage = '';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                  hintText: Translations.of(context).text('hint_comment')),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendComment,
          )
        ],
      ),
    );
  }
}
