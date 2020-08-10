import 'package:intl/intl.dart';

import 'user_model.dart';

class CommentModel {
  final String id;
  final DateTime createdAt;
  final UserModel user;
  final String body;
  final int likes;
  final int dislikes;
  final int comments;
  final bool hasLike;
  final bool hasDislike;

  CommentModel({
    this.id,
    this.createdAt,
    this.user,
    this.body,
    this.likes,
    this.dislikes,
    this.comments,
    this.hasLike,
    this.hasDislike,
  });

  static CommentModel fromJson(Map element) {
    return CommentModel(
      id: element['id'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(element['datetime']),
      user: UserModel(
        userName: element['user']['user_name'],
        icon: element['user']['icon'],
      ),
      body: element['body'],
      likes: element['likes'] ?? 0,
      dislikes: element['dislike'] ?? 0,
      comments: element['comments'] ?? 0,
      hasLike: element['is_likes'] ?? false,
      hasDislike: element['is_dislike'] ?? false,
    );
  }

  static List<CommentModel> listFromJson(List<dynamic> content) {
    List<CommentModel> mList = [];

    content.forEach((element) {
      mList.add(CommentModel(
        id: element['id'],
        createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(element['datetime']),
        user: UserModel(
          userName: element['user']['user_name'],
          icon: element['user']['icon'],
        ),
        body: element['body'],
        likes: element['likes'],
        dislikes: element['dislike'],
        comments: element['comments'] ?? 0,
        hasLike: element['is_likes'],
        hasDislike: element['is_dislike'],
      ));
    });

    return mList;
  }
}
