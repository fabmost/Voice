import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'user_icon.dart';
import 'user_profile_cover.dart';
import 'influencer_badge.dart';
import '../translations.dart';
import '../custom/galup_font_icons.dart';
import '../models/user_model.dart';
import '../screens/followers_screen.dart';
import '../screens/following_screen.dart';
import '../providers/user_provider.dart';

class UserProfileHeader extends StatelessWidget {
  final bool hasSocialMedia;

  UserProfileHeader({this.hasSocialMedia});

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toFollowers(context, userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersScreen(
          userName,
        ),
      ),
    );
  }

  void _toFollowing(context, userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowingScreen(
          userName,
        ),
      ),
    );
  }

  Widget _usersWidget(amount, type, action) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: action,
        child: Column(
          children: <Widget>[
            Text(
              '$amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(type),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerHeight = (screenWidth * 9) / 16;
    return Consumer<UserProvider>(builder: (context, provider, child) {
      UserModel user = provider.getUserModel;
      return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                UserProfileCover(user.stories),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: containerHeight.toDouble() - 50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        child: UserIcon(user.icon),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 72),
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
                                InfluencerBadge(
                                    user.userName, user.certificate, 20),
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
                  if ((user.facebook ?? '').isNotEmpty)
                    const SizedBox(width: 8),
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
                  if ((user.instagram ?? '').isNotEmpty)
                    const SizedBox(width: 8),
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
                      onTap: () => _launchURL(
                          'https://www.youtube.com/c/${user.youtube}'),
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
            Row(
              children: <Widget>[
                _usersWidget(
                  user.following,
                  Translations.of(context).text('label_following'),
                  () => _toFollowing(context, user.userName),
                ),
                Container(
                  width: 1,
                  color: Colors.grey,
                  height: 32,
                ),
                _usersWidget(
                  user.followers,
                  Translations.of(context).text('label_followers'),
                  () => _toFollowers(context, user.userName),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
