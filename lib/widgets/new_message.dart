import 'package:flutter/material.dart';

import '../translations.dart';

class NewMessage extends StatefulWidget {
  final Function sendMessage;

  NewMessage(this.sendMessage);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _enteredMessage = '';

  void _sendComment() async {
    //FocusScope.of(context).unfocus();
    widget.sendMessage(_enteredMessage);
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
