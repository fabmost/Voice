import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'user_model.dart';

class ChallengeModel extends ContentModel {
  final String body;
  final String description;
  final String parameter;
  final int goal;
  final List<ResourceModel> resources;
  final int comments;

  ChallengeModel({
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
    this.parameter,
    this.goal,
    this.resources,
    this.comments,
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

  static ChallengeModel fromJson(Map content) {
    return ChallengeModel(
      id: content['id'],
      type: 'challenge',
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      creator: content['user_regalup'] == null ? null :  content['user_regalup']['user_name'],
      title: content['body'],
      description: content['description'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime']),
      parameter: content['med_param'],
      goal: int.parse(content['goal']),
      likes: content['likes'],
      regalups: content['regalups'],
      comments: content['comments'],
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      resources: ResourceModel.listFromJson(content['resource']),
    );
  }
}
