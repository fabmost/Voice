import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'user_followers.dart';
import '../custom/galup_font_icons.dart';
import '../models/user_model.dart';

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
                Container(
                  width: double.infinity,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: Color(0xFFECECEC),
                    image: DecorationImage(
                        image: user.cover == null
                            ? null
                            : NetworkImage(user.cover),
                        fit: BoxFit.cover),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        user.icon == null ? null : NetworkImage(user.icon),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '${user.name} ${user.lastName}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: 8),
              //InfluencerBadge(document['influencer'] ?? '', 20),
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
          SizedBox(height: 16),
          if (user.biography != null && user.biography.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AutoSizeText(
                user.biography,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          if (user.biography != null && user.biography.isNotEmpty)
            SizedBox(height: 16),
          if (hasSocialMedia)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if ((user.tiktok ?? '').isNotEmpty)
                  GestureDetector(
                    onTap: () => _launchURL(
                        'https://www.tiktok.com/${user.tiktok.replaceAll('@', '')}'),
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
