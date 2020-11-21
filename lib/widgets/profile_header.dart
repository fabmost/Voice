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
          Stack(
            children: <Widget>[
              ProfileCover(user.stories),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: containerHeight.toDouble() - 70,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: user.icon == null
                          ? null
                          : user.icon.isEmpty
                              ? null
                              : () => _openImage(context, user.icon),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: user.icon == null
                            ? null
                            : user.icon.isEmpty
                                ? null
                                : CachedNetworkImageProvider(user.icon),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 92),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  '${user.name} ${user.lastName}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              InfluencerBadge(
                                  user.userName, user.certificate, 20)
                            ],
                          ),
                          Text(
                            '@${user.userName}',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (user.biography != null)
                            AutoSizeText(
                              user.biography,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
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
                if ((user.tiktok ?? '').isNotEmpty) const SizedBox(width: 8),
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
                if ((user.facebook ?? '').isNotEmpty) const SizedBox(width: 8),
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
                if ((user.instagram ?? '').isNotEmpty) const SizedBox(width: 8),
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
                if ((user.twitter ?? '').isNotEmpty) const SizedBox(width: 8),
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
                if ((user.youtube ?? '').isNotEmpty) const SizedBox(width: 8),
                if ((user.linkedin ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(user.linkedin),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(
                        GalupFont.linkedin,
                        color: Colors.white,
                        size: 32,
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
