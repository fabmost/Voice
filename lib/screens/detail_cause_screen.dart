import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'flag_screen.dart';
import 'auth_screen.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/cause_model.dart';
import '../widgets/regalup_content.dart';
import '../widgets/cause_button.dart';

class DetailCauseScreen extends StatefulWidget with ShareContent {
  static const routeName = '/cause';
  final String id;

  DetailCauseScreen({this.id});

  @override
  _DetailCauseScreenState createState() => _DetailCauseScreenState();
}

class _DetailCauseScreenState extends State<DetailCauseScreen> {
  CauseModel _causeModel;
  bool _isLoading = false;
  int _likes;

  final Color color = Color(0xFFF0F0F0);

  void _infoAlert(context, info) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(info),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Colors.black,
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  void _anonymousAlert(context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text),
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

  void _share() {
    widget.shareCause(_causeModel.id, _causeModel.cause);
  }

  void _flag(context, reference) {
    /*
    Navigator.of(context)
        .popAndPushNamed(FlagScreen.routeName, arguments: reference.documentID);
        */
  }

  void _save(context, reference, myId, hasSaved) async {
    /*
    final user = await FirebaseAuth.instance.currentUser();
    if (user.isAnonymous) {
      _anonymousAlert(
        context,
        Translations.of(context).text('dialog_need_account'),
      );
      return;
    }
    WriteBatch batch = Firestore.instance.batch();
    if (hasSaved) {
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'saved': FieldValue.arrayRemove([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayRemove([myId]),
        'interactions': FieldValue.increment(-1)
      });
    } else {
      batch.updateData(Firestore.instance.collection('users').document(myId), {
        'saved': FieldValue.arrayUnion([reference.documentID]),
      });
      batch.updateData(reference, {
        'saved': FieldValue.arrayUnion([myId]),
        'interactions': FieldValue.increment(1)
      });
    }
    batch.commit();

    Navigator.of(context).pop();
    */
  }

  void _options(context, reference, myId, hasSaved) {
    /*
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _save(context, reference, myId, hasSaved),
                leading: Icon(
                  GalupFont.saved,
                ),
                title: Text(hasSaved
                    ? Translations.of(context).text('button_delete')
                    : Translations.of(context).text('button_save')),
              ),
              ListTile(
                onTap: () => _flag(context, reference),
                leading: new Icon(
                  Icons.flag,
                  color: Colors.red,
                ),
                title: Text(
                  Translations.of(context).text('title_flag'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
    */
  }

  Future<void> _fetchCause() async {
    setState(() {
      _isLoading = true;
    });
    final result = await Provider.of<ContentProvider>(context, listen: false)
        .getContent('CA', widget.id);
    setState(() {
      _isLoading = false;
      _causeModel = result;
      _likes = _causeModel.likes;
    });
  }

  void _setLike(isLike) {
    setState(() {
      isLike ? _likes++ : _likes--;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_cause')),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchCause(),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  Container(
                    color: color,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _causeModel.by,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(GalupFont.info_circled_alt),
                            onPressed: () =>
                                _infoAlert(context, _causeModel.info),
                          )
                        ],
                      ),
                      subtitle: Text('Por: Galup'),
                      trailing: Transform.rotate(
                        angle: 270 * pi / 180,
                        child: IconButton(
                          icon: Icon(Icons.chevron_left),
                          /*
                            onPressed: () => _options(
                                  context,
                                  reference,
                                  userSnap.data.uid,
                                  hasSaved,
                                )*/
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _causeModel.cause,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  CauseButton(
                    id: _causeModel.id,
                    hasLike: _causeModel.hasLiked,
                    setVotes: _setLike,
                  ),
                  SizedBox(height: 16),
                  Container(
                    color: color,
                    child: Row(
                      children: <Widget>[
                        RegalupContent(
                          id: _causeModel.id,
                          type: 'CA',
                          regalups: _causeModel.regalups,
                          hasRegalup: _causeModel.hasRegalup,
                        ),
                        IconButton(
                          icon: Icon(GalupFont.share),
                          onPressed: _share,
                        ),
                        Expanded(child: SizedBox(height: 1)),
                        Text(_likes == 0 ? '' : '$_likes Votos'),
                        SizedBox(width: 16),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
