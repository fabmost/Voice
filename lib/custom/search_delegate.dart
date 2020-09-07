import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../models/content_model.dart';
import '../models/poll_model.dart';
import '../models/challenge_model.dart';
import '../models/tip_model.dart';
import '../models/cause_model.dart';
import '../providers/user_provider.dart';
import '../providers/content_provider.dart';
import '../widgets/poll_tile.dart';
import '../widgets/challenge_tile.dart';
import '../widgets/tip_tile.dart';
import '../widgets/cause_tile.dart';
import '../widgets/influencer_badge.dart';
import '../screens/view_profile_screen.dart';

class CustomSearchDelegate extends SearchDelegate {
  String currentUser;

  Widget _pollWidget(PollModel content) {
    return PollTile(
      reference: 'home',
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
      title: content.title,
      description: content.description,
      votes: content.votes,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      hasVoted: content.hasVoted,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      answers: content.answers,
      resources: content.resources,
    );
  }

  Widget _challengeWidget(ChallengeModel content) {
    return ChallengeTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
      title: content.title,
      description: content.description,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      parameter: content.parameter,
      goal: content.goal,
      resources: content.resources,
    );
  }

  Widget _causeWidget(CauseModel content) {
    return CauseTile(
      id: content.id,
      certificate: content.certificate,
      title: content.title,
      date: content.createdAt,
      likes: content.likes,
      regalups: content.regalups,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      bank: content.account,
      description: content.description,
      web: content.web,
      phone: content.phone,
      resources: content.resources,
      info: content.info,
      userName: content.user.userName,
      userImage: content.user.icon,
      goal: content.goal,
    );
  }

  Widget _tipWidget(TipModel content) {
    return TipTile(
      id: content.id,
      date: content.createdAt,
      userName: content.user.userName,
      userImage: content.user.icon,
      certificate: content.certificate,
      title: content.title,
      description: content.description,
      likes: content.likes,
      comments: content.comments,
      regalups: content.regalups,
      rate: content.total,
      hasLiked: content.hasLiked,
      hasRegalup: content.hasRegalup,
      hasSaved: content.hasSaved,
      hasRated: content.hasRated,
      resources: content.resources,
    );
  }

  Widget _tagTile(context, doc) {
    return ListTile(
      onTap: () {
        query = doc['text'];
        showResults(context);
      },
      leading: CircleAvatar(
        child: Text('#'),
      ),
      title: Text(
        doc['text'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text('${doc['count']} objetos'),
    );
  }

  Widget _userTile(context, UserModel content) {
    if (content.userName == currentUser) {
      return Container();
    }
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(ViewProfileScreen.routeName,
            arguments: content.userName);
      },
      leading: CircleAvatar(
        backgroundImage:
            content.icon == null ? null : NetworkImage(content.icon),
      ),
      title: Row(
        children: <Widget>[
          Text(
            content.userName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          InfluencerBadge(content.userName, content.certificate, 16),
        ],
      ),
      //subtitle: Text(doc['user_name']),
    );
  }

  void _getCUrrentUser(context) {
    if (currentUser == null) {
      currentUser = Provider.of<UserProvider>(context, listen: false).getUser;
    }
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _getCUrrentUser(context);
    return FutureBuilder(
      future:
          Provider.of<ContentProvider>(context, listen: false).search(query, 0),
      builder: (ct, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data.length == 0) {
          return Center(
            child: Text('Sin resultados'),
          );
        }
        var results = snapshot.data;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            ContentModel result = results[index];
            switch (result.type) {
              case 'poll':
                return _pollWidget(result);
              case 'challenge':
                return _challengeWidget(result);
              case 'causes':
                return _causeWidget(result);
              case 'Tips':
                return _tipWidget(result);
              default:
                return SizedBox();
            }
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _getCUrrentUser(context);
    if (query.length < 3) {
      return Container();
    }

    return FutureBuilder(
      future: Provider.of<UserProvider>(context, listen: false)
          .getAutocomplete(query),
      builder: (ct, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map results = snapshot.data;
        List users = results['users'];
        List tags = results['hashtags'];
        if (users.isEmpty && tags.isEmpty) {
          return Center(
            child: Text('Sin resultados'),
          );
        }
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return _tagTile(context, tags[i]);
                },
                childCount: tags.length,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return _userTile(context, users[i]);
                },
                childCount: users.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
