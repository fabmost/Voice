import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'user_model.dart';

class TipModel extends ContentModel {
  final String body;
  final String description;
  final List<ResourceModel> resources;
  final int comments;
  final double total;
  final bool hasRated;

  TipModel({
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
    this.body,
    this.description,
    this.resources,
    this.comments,
    this.total,
    this.hasRated
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

  static TipModel fromJson(Map content) {
    return TipModel(
      id: content['id'],
      type: content['type'],
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      creator: content['user_regalup'] == null ? null :  content['user_regalup']['user_name'],
      title: content['title'],
      description: content['description'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime']),
      likes: content['likes'],
      regalups: content['regalups'],
      comments: content['comments'] ?? 0,
      total: double.parse(content['total'].toString()),
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      hasRated: content['is_value'],
      resources: ResourceModel.listFromJson(content['resource']),
    );
  }
}
