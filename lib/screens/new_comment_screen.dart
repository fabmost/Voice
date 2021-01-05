import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_inc/custom/suggestion_textfield.dart';

import '../translations.dart';
import '../mixins/alert_mixin.dart';
import '../widgets/influencer_badge.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../custom/my_special_text_span_builder.dart';

class NewCommentScreen extends StatefulWidget {
  final String contentId;
  final String parentId;
  final String creator;
  final Function function;

  NewCommentScreen(
    this.contentId,
    this.parentId,
    this.creator,
    this.function,
  );

  @override
  _NewCommentScreenState createState() => _NewCommentScreenState();
}

class _NewCommentScreenState extends State<NewCommentScreen> with AlertMixin {
  final _controller = TextEditingController();
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

  void _sendComment() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (Provider.of<UserProvider>(context, listen: false).getUser == null) {
      anonymousAlert(context);
      return;
    }
    String toSend = '@[${widget.creator}]${widget.creator} ${_controller.text}';
    List<Map> hashes = [];
    RegExp exp = new RegExp(r"\B#\w\w+");
    exp.allMatches(toSend).forEach((match) {
      if (!hashes.contains(match.group(0))) {
        hashes.add({'text': removeDiacritics(match.group(0).toLowerCase())});
      }
    });

    var result = await Provider.of<ContentProvider>(context, listen: false)
        .newReply(
            comment: '$toSend ',
            type: 'comment',
            idContent: widget.contentId,
            id: widget.parentId,
            hashtags: hashes);

    widget.function(result);
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            text: 'Respuesta a ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: '@${widget.creator}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            ],
          ),
        ),
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SuggestionField(
                textFieldConfiguration: TextFieldConfiguration(
                  autofocus: true,
                  spanBuilder: MySpecialTextSpanBuilder(),
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  autocorrect: true,
                  maxLines: null,
                  maxLength: 240,
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: Translations.of(context).text('hint_comment'),
                  ),
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
                  _controller.text =
                      '$subs@[${suggestion.userName}]${suggestion.userName} ';
                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));
                  //_descFocus.requestFocus();
                  //FocusScope.of(context).requestFocus(_descFocus);
                },
                autoFlipDirection: true,
              ),
            ),
          ),
          _isLoading
              ? Container(
                  margin: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                )
              : Container(
                  margin: const EdgeInsets.all(16),
                  width: double.infinity,
                  height: 42,
                  child: RaisedButton(
                    onPressed: _toCheck.trim().isEmpty ? null : _sendComment,
                    textColor: Colors.white,
                    child: Text('Enviar'),
                  ),
                )
        ],
      ),
    );
  }
}
