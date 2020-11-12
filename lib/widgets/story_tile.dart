import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/resource_model.dart';

class StoryTile extends StatelessWidget {
  final String userName;
  final ResourceModel story;
  final Function toStories;

  final Color color = Color(0xFFF8F8FF);

  StoryTile({this.userName, this.story, this.toStories});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => toStories(story.url),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
          image: story.type == 'V' && story.thumbnail == null
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(
                      story.type == 'V' ? story.thumbnail : story.url),
                  fit: BoxFit.fitHeight,
                ),
        ),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment(0.5, 0),
                end: Alignment(0.5, 1),
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.grey,
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                userName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
