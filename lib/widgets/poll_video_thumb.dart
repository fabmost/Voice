import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../models/content_model.dart';

class PollVideoThumb extends StatelessWidget {
  final String videoUrl;
  final String type;
  final String id;

  PollVideoThumb({this.videoUrl, this.type, this.id});

  void _getThumbnail(context) {
    Provider.of<ContentProvider>(context, listen: false).setThumbnail(
      id: id,
      type: type,
      video: videoUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, value, child) {
        ContentModel mContent;
        switch (type) {
          case 'P':
            mContent = value.getPolls[id];
            break;
          case 'C':
            mContent = value.getChallenges[id];
            break;
          case 'CA':
            mContent = value.getCausesList[id];
            break;
          case 'TIP':
            mContent = value.getTips[id];
            break;
        }
        if (mContent == null) return Container();
        if (mContent.thumbnailUrl == null && mContent.thumbnail == null) {
          _getThumbnail(context);
          return Center(child: CircularProgressIndicator());
        }
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              mContent.thumbnailUrl != null
                  ? Image.network(mContent.thumbnailUrl)
                  : Image.memory(mContent.thumbnail),
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                  size: 32,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
