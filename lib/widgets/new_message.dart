import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../translations.dart';

class NewMessage extends StatefulWidget {
  final String chatId;
  final String other;
  final Function setId;

  NewMessage(this.chatId, this.other, this.setId);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _enteredMessage = '';

  void _sendComment() async {
    FocusScope.of(context).unfocus();
    final user = await FirebaseAuth.instance.currentUser();
    final userData =
        await Firestore.instance.collection('users').document(user.uid).get();
    if (widget.chatId == null) {
      String chatId =
          Firestore.instance.collection('chats').document().documentID;
      final otherData = await Firestore.instance
          .collection('users')
          .document(widget.other)
          .get();
      await Firestore.instance.collection('chats').document(chatId).setData({
        'participant_ids': [user.uid, widget.other],
        'participants': {
          user.uid: {
            'user_name': userData['user_name'],
            'user_image': userData['image'],
          },
          otherData.documentID: {
            'user_name': otherData['user_name'],
            'user_image': otherData['image'],
          }
        },
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'last_message': _enteredMessage,
      });

      WriteBatch batch = Firestore.instance.batch();
      batch.setData(
        Firestore.instance
            .collection('chats')
            .document(chatId)
            .collection('messages')
            .document(),
        {
          'text': _enteredMessage,
          'createdAt': Timestamp.now(),
          'userId': user.uid,
          'username': userData['user_name'],
          'userimage': userData['image'],
        },
      );
      batch.updateData(
          Firestore.instance.collection('users').document(user.uid), {
        'chats': FieldValue.arrayUnion([chatId]),
      });
      batch.updateData(
          Firestore.instance.collection('users').document(widget.other), {
        'chats': FieldValue.arrayUnion([chatId]),
      });
      batch.commit();
      widget.setId(chatId);
    } else {
      WriteBatch batch = Firestore.instance.batch();

      batch.setData(
        Firestore.instance
            .collection('chats')
            .document(widget.chatId)
            .collection('messages')
            .document(),
        {
          'text': _enteredMessage,
          'createdAt': Timestamp.now(),
          'userId': user.uid,
          'username': userData['user_name'],
          'userimage': userData['image'],
          'receiverId': widget.other,
        },
      );
      batch.updateData(
          Firestore.instance.collection('chats').document(widget.chatId), {
        'updatedAt': Timestamp.now(),
        'last_message': _enteredMessage,
      });
      batch.commit();
    }
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
              maxLines: null,
              maxLength: 240,
              decoration: InputDecoration(
                  counterText: '',
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
