import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../translations.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

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
    final user = await Provider.of<AuthProvider>(context, listen: false).getHash();
    final userData =
        await Provider.of<UserProvider>(context, listen: false).userProfile();
    if (widget.chatId == null) {
      String chatId =
          Firestore.instance.collection('chats').document().documentID;
      final otherData = await Firestore.instance
          .collection('users')
          .document(widget.other)
          .get();
      await Firestore.instance.collection('chats').document(chatId).setData({
        'participant_ids': [user, widget.other],
        'participants': {
          user: {
            'user_name': userData.userName,
            'user_image': userData.icon,
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
          'userId': user,
          'username': userData.userName,
          'userimage': userData.icon,
        },
      );
      batch.updateData(
          Firestore.instance.collection('users').document(user), {
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
          'userId': user,
          'username': userData.userName,
          'userimage': userData.icon,
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
