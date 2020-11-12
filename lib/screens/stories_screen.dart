import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

import '../models/resource_model.dart';

class StoriesScreen extends StatefulWidget {
  final List<ResourceModel> stories;
  final String url;

  StoriesScreen(this.stories, this.url);

  @override
  _StoriesScreenState createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final storyController = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.stories.forEach((story) {
      if (story.type == 'V') {
        storyItems.add(
          StoryItem.pageVideo(
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
      body: StoryView(
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
        storyItems: storyItems,
      ),
    );
  }
}
