import 'package:after_layout/after_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';

import 'view_profile_screen.dart';
import '../providers/user_provider.dart';
import '../models/story_model.dart';
import '../models/resource_model.dart';
import '../models/user_model.dart';
import '../custom/custom_story_video.dart';

class HomeStoriesScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final String url;

  HomeStoriesScreen(this.stories, this.url);

  @override
  _StoriesScreenState createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<HomeStoriesScreen>
    with AfterLayoutMixin<HomeStoriesScreen> {
  final storyController = StoryController();
  List<StoryItem> storyItems = [];
  UserModel _currentUser;
  bool canUpdate = false;

  void _toProfile() {
    if (Provider.of<UserProvider>(context, listen: false).getUser !=
        _currentUser.userName) {
      storyController.pause();
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName,
              arguments: _currentUser.userName)
          .then((value) {
        storyController.play();
      });
    }
  }

  Widget _buildProfileView() {
    return GestureDetector(
      onTap: _toProfile,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: _currentUser.icon == null
                ? null
                : CachedNetworkImageProvider(_currentUser.icon),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentUser.userName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    canUpdate = true;
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.stories.forEach((item) {
      final ResourceModel story = item.story;
      if (widget.url == story.url) {
        _currentUser = item.user;
      }
      if (story.type == 'V') {
        storyItems.add(
          CustomStoryItem(
            story.url,
            controller: storyController,
            shown: widget.url != story.url,
          ),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
            controller: storyController,
            duration: Duration(seconds: 10),
            url: story.url,
            shown: widget.url != story.url,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            controller: storyController,
            repeat: false,
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            },
            onComplete: () {
              Navigator.pop(context);
            },
            onStoryShow: (storyItem) {
              int pos = storyItems.indexOf(storyItem);

              // the reason for doing setState only after the first
              // position is becuase by the first iteration, the layout
              // hasn't been laid yet, thus raising some exception
              // (each child need to be laid exactly once)
              if (canUpdate)
                setState(() {
                  _currentUser = widget.stories[pos].user;
                });
            },
            storyItems: storyItems,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 52,
              left: 16,
              right: 16,
            ),
            child: _buildProfileView(),
          )
        ],
      ),
    );
  }
}
