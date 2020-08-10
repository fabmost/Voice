import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'influencer_badge.dart';
import '../providers/content_provider.dart';
import '../screens/auth_screen.dart';
import '../custom/suggestion_textfield.dart';
import '../custom//my_special_text_span_builder.dart';
import '../translations.dart';

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

class _NewCommentState extends State<NewComment> {
  final _controller = TextEditingController();
  //var _enteredMessage = '';
  var _toCheck = '';
  Algolia algolia;
  AlgoliaQuery searchQuery;
  bool _isSearching = false;

  Widget _userTile(context, id, doc) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(doc['user_image'] ?? ''),
      ),
      title: Row(
        children: <Widget>[
          Text(
            doc['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(doc['influencer'] ?? '', 16),
        ],
      ),
      subtitle: Text(doc['user_name']),
    );
  }

  void _anonymousAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.of(context).text('dialog_need_account')),
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
    var result = await Provider.of<ContentProvider>(context, listen: false).newComment(
      comment: _controller.text,
      type: widget.type,
      id: widget.id,
    );
    widget.function(result);
    setState(() {
      _controller.clear();
    });
  }

  Future<List> _getSuggestions(String query) async {
    if (query.endsWith(' ')) {
      _isSearching = false;
      return null;
    }
    searchQuery = algolia.instance.index('suggestions');
    int index = query.lastIndexOf('@');
    String realQuery = query.substring(index);
    searchQuery = searchQuery.search(realQuery);
    AlgoliaQuerySnapshot results = await searchQuery.getObjects();
    return results.hits;
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    algolia = Algolia.init(
      applicationId: 'J3C3F33D3S',
      apiKey: '70469e6182ac069696c17d836c210780',
    );
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
                AlgoliaObjectSnapshot result = itemData;
                if (result.data['interactions'] == null) {
                  return _userTile(context, result.objectID, result.data);
                }
                return Container();
              },
              onSuggestionSelected: (suggestion) {
                _isSearching = false;
                //TextSelection selection = _descriptionController.selection;
                int index = _controller.text.lastIndexOf('@');
                String subs = _controller.text.substring(0, index);
                _controller.text =
                    '$subs@[${suggestion.objectID}]${suggestion.data['name']} ';
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
            onPressed: _toCheck.trim().isEmpty ? null : _sendComment,
          )
        ],
      ),
    );
  }
}
