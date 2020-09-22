import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'influencer_badge.dart';
import '../translations.dart';
import '../mixins/alert_mixin.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';
import '../custom/suggestion_textfield.dart';
import '../custom//my_special_text_span_builder.dart';

class NewComment extends StatefulWidget {
  final String type;
  final String id;
  final String idComment;
  final Function function;

  NewComment({
    @required this.id,
    @required this.type,
    this.idComment,
    @required this.function,
  });

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends State<NewComment> with AlertMixin{
  final _controller = TextEditingController();
  //var _enteredMessage = '';
  var _toCheck = '';
  bool _isSearching = false;
  bool _isLoading = false;

  Widget _userTile(context, content) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            content.icon == null ? null : NetworkImage(content.icon),
      ),
      title: Row(
        children: <Widget>[
          Text(
            content.userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(content.userName, content.certificate, 16),
        ],
      ),
      //subtitle: Text(doc['user_name']),
    );
  }

  void _sendComment() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    var result;

    List<Map> hashes = [];
    RegExp exp = new RegExp(r"\B#\w\w+");
    exp.allMatches(_controller.text).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });

    if (widget.idComment != null) {
      result = await Provider.of<ContentProvider>(context, listen: false)
          .newReply(
              comment: '${_controller.text} ',
              type: 'comment',
              idContent: widget.id,
              id: widget.idComment,
              hashtags: hashes);
    } else {
      result =
          await Provider.of<ContentProvider>(context, listen: false).newComment(
        comment: '${_controller.text} ',
        type: widget.type,
        id: widget.id,
        hashtag: hashes,
      );
    }
    widget.function(result);
    setState(() {
      _controller.clear();
      _isLoading = false;
    });
  }

  Future<List> _getSuggestions(String query) async {
    if (query.endsWith(' ')) {
      _isSearching = false;
      return null;
    }
    int index = query.lastIndexOf('@');
    String realQuery = query.substring(index + 1);
    Map results = await Provider.of<UserProvider>(context, listen: false)
        .getAutocomplete(realQuery);
    return results['users'];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SuggestionField(
              textFieldConfiguration: TextFieldConfiguration(
                spanBuilder: MySpecialTextSpanBuilder(),
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                autocorrect: true,
                maxLines: null,
                maxLength: 240,
                decoration: InputDecoration(
                    counterText: '',
                    hintText: Translations.of(context).text('hint_comment')),
                onChanged: (value) {
                  setState(() {
                    //_enteredMessage = value;
                    _toCheck = value;
                  });
                },
              ),
              suggestionsCallback: (pattern) {
                //TextSelection selection = _descriptionController.selection;
                //String toCheck = pattern.substring(0, selection.end);
                if (_isSearching) {
                  return _getSuggestions(pattern);
                }
                if (pattern.endsWith('@')) {
                  _isSearching = true;
                }
                return null;
              },
              itemBuilder: (context, itemData) {
                return _userTile(context, itemData);
              },
              onSuggestionSelected: (suggestion) {
                _isSearching = false;
                //TextSelection selection = _descriptionController.selection;
                int index = _controller.text.lastIndexOf('@');
                String subs = _controller.text.substring(0, index);
                _controller.text = '$subs@[${suggestion.userName}]${suggestion.userName} ';
                _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length));
                //_descFocus.requestFocus();
                //FocusScope.of(context).requestFocus(_descFocus);
              },
              autoFlipDirection: true,
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _isLoading ? null : _toCheck.trim().isEmpty ? null : _sendComment,
          )
        ],
      ),
    );
  }
}
