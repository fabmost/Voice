import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'profile_cover.dart';
import 'user_followers.dart';
import 'influencer_badge.dart';
import '../custom/galup_font_icons.dart';
import '../models/user_model.dart';
import '../screens/poll_gallery_screen.dart';

class ProfileHeader extends StatelessWidget {
  final bool hasSocialMedia;
  final UserModel user;

  ProfileHeader({this.hasSocialMedia, this.user});

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _openImage(context, url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: 'profile',
          galleryItems: [url],
          initialIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = (screenWidth * 9) / 16;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            height: containerHeight + 60,
            child: Stack(
              children: <Widget>[
                ProfileCover(user.stories),
                Positioned(
                  left: 16,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: user.icon == null
                        ? null
                        : user.icon.isEmpty
                            ? null
                            : () => _openImage(context, user.icon),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: user.icon == null
                          ? null
                          : user.icon.isEmpty
                              ? null
                              : CachedNetworkImageProvider(user.icon),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${user.name} ${user.lastName}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      InfluencerBadge(user.userName, user.certificate, 20)
                    ],
                  ),
                  Text(
                    '@${user.userName}',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              if (user.biography != null)
                Expanded(
                  child: AutoSizeText(
                    user.biography,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
            ],
          ),
          SizedBox(height: 16),
          if (user.biography != null && user.biography.isNotEmpty)
            SizedBox(height: 16),
          if (hasSocialMedia)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if ((user.tiktok ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        _launchURL('https://www.tiktok.com/${user.tiktok}'),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        GalupFont.tik_tok,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                if ((user.facebook ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.facebook.com/${user.facebook.replaceAll('@', '')}'),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        GalupFont.facebook,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                if ((user.instagram ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.instagram.com/${user.instagram.replaceAll('@', '')}'),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        GalupFont.instagram,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                if ((user.twitter ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.twitter.com/${user.twitter.replaceAll('@', '')}'),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        GalupFont.twitter,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                if ((user.youtube ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        _launchURL('https://www.youtube.com/c/${user.youtube}'),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        GalupFont.youtube,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          if (hasSocialMedia) SizedBox(height: 16),
          UserFollowers(
            userName: user.userName,
            followers: user.followers,
            following: user.following,
            isFollowing: user.isFollowing,
          ),
        ],
      ),
    );
  }
}
