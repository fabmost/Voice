import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new_group_screen.dart';
import 'edit_group_screen.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../models/group_model.dart';
import '../providers/user_provider.dart';

enum LoadMoreStatus { LOADING, STABLE }

class NewContentGroupsScreen extends StatefulWidget {
  static const String routeName = '/content-groups';
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<NewContentGroupsScreen> {
  LoadMoreStatus loadMoreStatus = LoadMoreStatus.STABLE;
  final ScrollController scrollController = ScrollController();
  int _currentPageNumber;
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
          Provider.of<UserProvider>(context, listen: false)
              .getGroups(_currentPageNumber)
              .then((newContent) {
            setState(() {
              if (newContent.isEmpty) {
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
    setState(() {
      _isLoading = true;
    });
    List results = await Provider.of<UserProvider>(context, listen: false)
        .getGroups(_currentPageNumber);
    setState(() {
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        if (results.length < 10) _hasMore = false;
      }
      _isLoading = false;
    });
  }

  Widget _groupTile(GroupModel mGroup) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pop(mGroup);
      },
      title: Text(mGroup.title),
      subtitle: Text('${mGroup.members} miembros'),
      trailing: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditGroupScreen(
                id: mGroup.id,
                name: mGroup.title,
              ),
            ),
          );
        },
        icon: Icon(Icons.edit),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context).text('title_groups')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<UserProvider>(
              builder: (context, value, child) {
                List<GroupModel> mList = value.getGroupsList;
                return mList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(height: 16),
                            Icon(
                              GalupFont.empty_saved,
                              color: Color(0xFF8E8EAB),
                              size: 32,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              child: Text(
                                'No has creado ningún grupo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8E8EAB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _hasMore ? mList.length + 1 : mList.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, i) {
                          if (i == mList.length)
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(),
                            );
                          return _groupTile(mList[i]);
                        },
                      );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(NewGroupScreen.routeName);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
