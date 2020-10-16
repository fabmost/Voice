import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'detail_poll_screen.dart';
import 'detail_challenge_screen.dart';
import 'detail_tip_screen.dart';
import 'detail_cause_screen.dart';
import 'view_profile_screen.dart';
import 'detail_comment_screen.dart';
import '../translations.dart';
import '../providers/content_provider.dart';
import '../models/notification_model.dart';

enum LoadMoreStatus { LOADING, STABLE }

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController scrollController = new ScrollController();
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  //List<NotificationModel> _list = [];
  int _currentPageNumber;
  bool _isLoading = false;
  bool _hasMore = true;

  void _toPoll(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPollScreen(
          id: id,
        ),
      ),
    );
  }

  void _toChallenge(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailChallengeScreen(
          id: id,
        ),
      ),
    );
  }

  void _toTip(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTipScreen(
          id: id,
        ),
      ),
    );
  }

  void _toCause(id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCauseScreen(
          id: id,
        ),
      ),
    );
  }

  void _toProfile(context, id) {
    Navigator.of(context).pushNamed(ViewProfileScreen.routeName, arguments: id);
  }

  void _toComment(context, id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailCommentScreen(
          id,
          true,
        ),
      ),
    );
  }

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          _moreData();
        }
      }
    }
    return true;
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ContentProvider>(context, listen: false)
        .getNotifications(_currentPageNumber);
    setState(() {
      /*
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _list = results;
        _moreData();
      }
      */
      _isLoading = false;
    });
    _moreData();
  }

  void _moreData() {
    _currentPageNumber++;
    loadMoreStatus = LoadMoreStatus.LOADING;
    Provider.of<ContentProvider>(context, listen: false)
        .getNotifications(_currentPageNumber)
        .then((hasMore) {
      if (!hasMore) {
        setState(() {
          _hasMore = false;
        });
      }
      loadMoreStatus = LoadMoreStatus.STABLE;
    });
  }

  Widget _notification(NotificationModel model) {
    final now = new DateTime.now().toUtc();
    final difference = now.difference(model.createdAt);
    final newDate = now.subtract(difference).toLocal();

    return Container(
      color: model.isNew ? Color(0x22000000) : Colors.white,
      child: ListTile(
        onTap: () {
          Provider.of<ContentProvider>(context, listen: false)
              .notificationRead(model.id);
          switch (model.type) {
            case 'poll':
              return _toPoll(model.idContent);
            case 'challenge':
              return _toChallenge(model.idContent);
            case 'tip':
              return _toTip(model.idContent);
            case 'cause':
              return _toCause(model.idContent);
            case 'profile':
              return _toProfile(context, model.idContent);
            case 'comment':
              return _toComment(context, model.idContent);
            default:
              return null;
          }
        },
        leading: CircleAvatar(
          radius: 21,
          backgroundColor: Theme.of(context).accentColor,
          backgroundImage: model.icon == null ? null : NetworkImage(model.icon),
        ),
        title: Text(model.message),
        subtitle: Text(
          timeago.format(newDate,
              locale: Translations.of(context).currentLanguage),
        ),
      ),
    );
  }

  @override
  void initState() {
    _currentPageNumber = 0;
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cart = context.watch<ContentProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_notifications')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : cart.getNotificationsList.isEmpty
              ? Center(
                  child: Text(
                    'No tienes notificaciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8E8EAB),
                    ),
                  ),
                )
              : NotificationListener(
                  onNotification: onNotification,
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _hasMore
                        ? cart.getNotificationsList.length + 1
                        : cart.getNotificationsList.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 0,
                    ),
                    itemBuilder: (context, i) {
                      if (i == cart.getNotificationsList.length)
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        );
                      return _notification(cart.getNotificationsList[i]);
                    },
                  ),
                ),
    );
  }
}
