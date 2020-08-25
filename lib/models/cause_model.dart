import 'package:intl/intl.dart';

import 'content_model.dart';

class CauseModel extends ContentModel {
  final String by;
  final String cause;
  final String info;

  CauseModel({
    id,
    type,
    user,
    creator,
    createdAt,
    title,
    likes,
    regalups,
    hasLiked,
    hasRegalup,
    hasSaved,
    this.by,
    this.cause,
    this.info,
  }) : super(
            id: id,
            type: type,
            user: user,
            creator: creator,
            title: title,
            createdAt: createdAt,
            likes: likes,
            regalups: regalups,
            hasLiked: hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: hasSaved);

  static CauseModel fromJson(Map content) {
    return CauseModel(
      id: content['id'],
      type: content['type'],
      title: content['body'],
      by: content['by'],
      info: content['info'],
      cause: content['cause'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime']),
      likes: content['likes'],
      regalups: content['regalups'],
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
    );
  }
}
