import 'package:intl/intl.dart';

import 'user_model.dart';
import 'certificate_model.dart';
import '../mixins/text_mixin.dart';

class CommentModel {
  final String id;
  final String parentId;
  final String parentType;
  final DateTime createdAt;
  final UserModel user;
  final String body;
  final int likes;
  final int dislikes;
  final int comments;
  final bool hasLike;
  final bool hasDislike;
  final CertificateModel certificate;

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
    this.certificate,
    this.parentId,
    this.parentType,
  });

  static CommentModel fromJson(Map element) {
    return CommentModel(
      parentId: element['parent_id'].toString(),
      parentType: element['parent_type'],
      id: element['id'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(element['datetime']),
      user: UserModel(
        userName: element['user']['user_name'],
        icon: element['user']['icon'],
      ),
      body: TextMixin.fixString(element['body']),
      likes: element['likes'] ?? 0,
      dislikes: element['dislike'] ?? 0,
      comments: element['comments'] ?? 0,
      hasLike: element['is_likes'] ?? false,
      hasDislike: element['is_dislike'] ?? false,
      certificate: element['certificates'] == null
          ? null
          : element['certificates']['icon'] == null
              ? null
              : CertificateModel.fromJson(element['certificates']),
    );
  }

/*
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
        certificate: element['certificates'] == null
            ? null
            : element['certificates']['icon'] == null
                ? null
                : CertificateModel.fromJson(element['certificates']),
        body: TextMixin.fixString(element['body']),
        likes: element['likes'],
        dislikes: element['dislike'],
        comments: element['comments'] ?? 0,
        hasLike: element['is_likes'],
        hasDislike: element['is_dislike'],
      ));
    });

    return mList;
  }
  */
}
