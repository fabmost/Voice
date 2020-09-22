import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'user_model.dart';
import 'certificate_model.dart';
import '../mixins/text_mixin.dart';

class ChallengeModel extends ContentModel {
  final String description;
  final String parameter;
  final int goal;
  final List<ResourceModel> resources;

  ChallengeModel({
    id,
    type,
    user,
    creator,
    createdAt,
    title,
    likes,
    regalups,
    comments,
    hasLiked,
    hasRegalup,
    hasSaved,
    certificate,
    thumbnail,
    this.description,
    this.parameter,
    this.goal,
    this.resources,
  }) : super(
          id: id,
          type: type,
          user: user,
          creator: creator,
          title: title,
          createdAt: createdAt,
          likes: likes,
          regalups: regalups,
          comments: comments,
          hasLiked: hasLiked,
          hasRegalup: hasRegalup,
          hasSaved: hasSaved,
          certificate: certificate,
          thumbnail: thumbnail,
        );

  static ChallengeModel fromJson(Map content) {
    return ChallengeModel(
      id: content['id'],
      type: content['type'],
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      creator: content['user_regalup'] == null
          ? null
          : content['user_regalup']['user_name'],
      certificate: content['certificates'] == null
          ? null
          : content['certificates']['icon'] == null
              ? null
              : CertificateModel.fromJson(content['certificates']),
      title: TextMixin.fixString(content['body']),
      description: TextMixin.fixString(content['description']),
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime']),
      parameter: content['med_param'],
      goal: content['goal'] == null ? 0 : int.parse(content['goal']),
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
