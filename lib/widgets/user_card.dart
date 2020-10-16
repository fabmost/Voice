import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/view_profile_screen.dart';

class UserCard extends StatelessWidget {
  final String userName;
  final String icon;
  final bool isFollowing;

  final Color color = Color(0xFFF8F8FF);

  UserCard({this.userName, this.icon, this.isFollowing});

  void _toProfile(context) {
    if (Provider.of<UserProvider>(context, listen: false).getUser != userName) {
      Navigator.of(context)
          .pushNamed(ViewProfileScreen.routeName, arguments: userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _toProfile(context),
      child: Container(
        height: 220,
        width: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              width: 1,
              color: Theme.of(context).accentColor,
            ),
            color: color),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
                image: icon == null
                    ? null
                    : DecorationImage(
                        image: CachedNetworkImageProvider(icon),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  userName,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
