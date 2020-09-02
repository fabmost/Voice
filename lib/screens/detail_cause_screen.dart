import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'auth_screen.dart';
import '../translations.dart';
import '../mixins/share_mixin.dart';
import '../custom/galup_font_icons.dart';
import '../providers/content_provider.dart';
import '../models/cause_model.dart';
import '../widgets/description.dart';
import '../widgets/menu_content.dart';
import '../widgets/regalup_content.dart';
import '../widgets/cause_button.dart';
import '../widgets/poll_images.dart';
import '../widgets/poll_video.dart';

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

  void _call(phone) async {
    if (await canLaunch('tel:$phone')) {
      await launch('tel:$phone');
    } else {
      throw 'Could not launch $phone';
    }
  }

  void _launchURL(String url) async {
    String newUrl = url;
    if (!url.contains('http')) {
      newUrl = 'http://$url';
    }
    if (await canLaunch(newUrl.trim())) {
      await launch(newUrl.trim());
    } else {
      throw 'Could not launch $newUrl';
    }
  }

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
    widget.shareCause(_causeModel.id, _causeModel.title);
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

  Widget _userTile(context) {
    final now = new DateTime.now();
    final difference = now.difference(_causeModel.createdAt);
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).primaryColor,
        backgroundImage: _causeModel.info.isNotEmpty
            ? AssetImage('assets/logo.png')
            : _causeModel.user.icon == null
                ? null
                : NetworkImage(_causeModel.user.icon),
      ),
      title: _causeModel.info.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'creator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(width: 2),
                IconButton(
                  icon: Icon(GalupFont.info_circled_alt),
                  onPressed: () => _infoAlert(context, _causeModel.info),
                )
              ],
            )
          : Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    _causeModel.user.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                //InfluencerBadge(document['influencer'] ?? '', 16),
              ],
            ),
      subtitle: _causeModel.info.isNotEmpty
          ? Text('Por: Galup')
          : Text(timeago.format(now.subtract(difference))),
      trailing: MenuContent(
        id: _causeModel.id,
        isSaved: _causeModel.hasSaved,
        type: 'CA',
      ),
    );
  }

  Widget _challengeGoal(context) {
    var totalPercentage =
        (_causeModel.likes == 0) ? 0.0 : _causeModel.likes / _causeModel.goal;
    if (totalPercentage > 1) totalPercentage = 1;
    final format = NumberFormat('###.##');

    return Column(
      children: [
        if (_causeModel.resources.isNotEmpty &&
            _causeModel.resources[0].type == 'V')
          PollVideo(_causeModel.resources[0].url, null),
        if (_causeModel.resources.isNotEmpty &&
            _causeModel.resources[0].type == 'I')
          PollImages([_causeModel.resources[0].url], null),
        Container(
          height: 42,
          margin: EdgeInsets.all(16),
          child: Stack(
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: totalPercentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                      bottomRight: totalPercentage == 1
                          ? Radius.circular(12)
                          : Radius.zero,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Firmas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                        '${format.format(totalPercentage * 100)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(color: color, child: _userTile(context)),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _causeModel.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_causeModel.goal != null) _challengeGoal(context),
                  if (_causeModel.goal != null) const SizedBox(height: 16),
                  if (_causeModel.description != null &&
                      _causeModel.description.isNotEmpty)
                    Description(_causeModel.description),
                  if (_causeModel.description != null &&
                      _causeModel.description.isNotEmpty)
                    const SizedBox(height: 16),
                  CauseButton(
                    id: _causeModel.id,
                    hasLike: _causeModel.hasLiked,
                    setVotes: _setLike,
                  ),
                  if (_causeModel.phone != null)
                    ListTile(
                      onTap: () => _call(_causeModel.phone),
                      leading: Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      title: Text('Contáctame'),
                      subtitle: Text(_causeModel.phone),
                    ),
                  if (_causeModel.web != null)
                    ListTile(
                      onTap: () => _launchURL(_causeModel.web),
                      leading: Icon(
                        Icons.open_in_browser,
                        color: Colors.black,
                      ),
                      title: Text('Visita'),
                      subtitle: Text(_causeModel.web),
                    ),
                  if (_causeModel.account != null)
                    ListTile(
                      leading: Icon(
                        Icons.credit_card,
                        color: Colors.black,
                      ),
                      title: Text('Donaciones'),
                      subtitle: Text(_causeModel.account),
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
