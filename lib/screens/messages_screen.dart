import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chat_tile.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with AutomaticKeepAliveClientMixin {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  List<ChatModel> _list = [];
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  bool onNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (scrollController.position.maxScrollExtent > scrollController.offset &&
          scrollController.position.maxScrollExtent - scrollController.offset <=
              50) {
        if (loadMoreStatus != null &&
            loadMoreStatus == LoadMoreStatus.STABLE &&
            _hasMore) {
          _currentPageNumber++;
          loadMoreStatus = LoadMoreStatus.LOADING;
          Provider.of<ChatProvider>(context, listen: false)
              .getChatsList(_currentPageNumber)
              .then((newObjects) {
            setState(() {
              if (newObjects.isEmpty) {
                _hasMore = false;
              } else {
                _list.addAll(newObjects);
              }
            });
            loadMoreStatus = LoadMoreStatus.STABLE;
          });
        }
      }
    }
    return true;
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    List results = await Provider.of<ChatProvider>(context, listen: false)
        .getChatsList(_currentPageNumber);
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        if(results.length < 10){
          _hasMore = false;
        }
        _list = results;
      }
      _isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
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
    super.build(context);
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _list.isEmpty
            ? Center(
                child: Text('No tienes mensajes'),
              )
            : NotificationListener(
                onNotification: onNotification,
                child: ListView.separated(
                  controller: scrollController,
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: _hasMore ? _list.length + 1 : _list.length,
                  itemBuilder: (context, i) {
                    if (i == _list.length) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    ChatModel mChat = _list[i];
                    return ChatTile(
                      userHash: mChat.user.hash,
                      userName: '${mChat.user.name} ${mChat.user.lastName}',
                      icon: mChat.user.icon,
                      message: mChat.lastMessage,
                      date: mChat.updatedAt,
                    );
                  },
                ),
              );
  }
}
