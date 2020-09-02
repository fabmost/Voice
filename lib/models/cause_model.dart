import 'package:intl/intl.dart';

import 'content_model.dart';
import 'user_model.dart';
import 'resource_model.dart';
import '../mixins/text_mixin.dart';

class CauseModel extends ContentModel {
  final String description;
  final String by;
  final String info;
  final int goal;
  final String phone;
  final String web;
  final String account;
  final List<ResourceModel> resources;

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
    this.description,
    this.by,
    this.info,
    this.goal,
    this.phone,
    this.web,
    this.account,
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
            hasLiked: hasLiked,
            hasRegalup: hasRegalup,
            hasSaved: hasSaved);

  static CauseModel fromJson(Map content) {
    return CauseModel(
      id: content['id'],
      type: content['type'],
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      creator: content['user_regalup'] == null
          ? null
          : content['user_regalup']['user_name'],
      title: TextMixin.fixString(content['title']),
      description: TextMixin.fixString(content['description']),
      by: content['by'] ?? '',
      info: content['info'] ?? '',
      goal: content['goal'] == null ? 0 : int.parse(content['goal']),
      phone: content['phone'],
      web: content['web'],
      account: content['account'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime']),
      likes: content['likes'],
      regalups: content['regalups'],
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      resources: ResourceModel.listFromJson(content['resource']),
    );
  }
}
