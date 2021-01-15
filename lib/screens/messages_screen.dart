import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chat_tile.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key key}) : super(key: key);

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen>
    with AutomaticKeepAliveClientMixin {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = new ScrollController();
  int _currentPageNumber = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isEmpty = false;

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
    _currentPageNumber = 0;
    setState(() {
      _isLoading = true;
    });
    List results = await Provider.of<ChatProvider>(context, listen: false)
        .getChatsList(_currentPageNumber);
    setState(() {
      if (results.isEmpty) {
        _isEmpty = true;
        _hasMore = false;
      } else {
        if (results.length < 10) {
          _hasMore = false;
        }
      }
      _isLoading = false;
    });
  }

  void checkIfUpdateNeeded() {
    if (Provider.of<ChatProvider>(context, listen: false).needsReload) {
      _getData();
    }
  }

  Widget _mList() {
    return Consumer<ChatProvider>(
      builder: (context, value, child) => ListView.separated(
        controller: scrollController,
        itemCount: _hasMore ? value.getChats.length + 1 : value.getChats.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, i) {
          if (i == value.getChats.length) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          ChatModel mChat = value.getChats[i];
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
        : _isEmpty
            ? Center(
                child: Text('No tienes mensajes'),
              )
            : NotificationListener(
                onNotification: onNotification,
                child: _mList(),
              );
  }
}
