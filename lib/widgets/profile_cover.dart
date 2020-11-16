import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/resource_model.dart';
import '../screens/stories_screen.dart';

class ProfileCover extends StatelessWidget {
  final List<ResourceModel> histories;

  ProfileCover(this.histories);

  Widget _historyWidget(context, width, ResourceModel history) {
    return Container(
      width: width,
      color: Colors.grey,
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoriesScreen(histories, history.url),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: history.type == 'V' ? history.thumbnail : history.url,
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3;
    return Container(
      color: Colors.grey,
      height: width * 16 / 9,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            histories.map((e) => _historyWidget(context, width, e)).toList(),
      ),
    );
  }
}
