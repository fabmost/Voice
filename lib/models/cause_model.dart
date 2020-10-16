import 'package:intl/intl.dart';

import 'content_model.dart';
import 'user_model.dart';
import 'resource_model.dart';
import 'certificate_model.dart';
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
    certificate,
    thumbnail,
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
          hasSaved: hasSaved,
          certificate: certificate,
          thumbnail: thumbnail,
        );

  static CauseModel fromJson(Map content) {
    String regalup = content['user_regalup'] == null
        ? null
        : content['user_regalup']['user_name'];
    CertificateModel certificate;
    //if (regalup == null) {
    certificate = content['certificates'] == null
        ? null
        : content['certificates']['icon'] == null
            ? null
            : CertificateModel.fromJson(content['certificates']);
    /*
    } else {
      certificate = content['certificatesRegalup'] == null
          ? null
          : content['certificatesRegalup']['icon'] == null
              ? null
              : CertificateModel.fromJson(content['certificatesRegalup']);
    }
    */
    return CauseModel(
      id: content['id'],
      type: content['type'],
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      creator: regalup,
      certificate: certificate,
      title: TextMixin.fixString(content['title']),
      description: TextMixin.fixString(content['description']),
      by: content['by'] ?? '',
      info: content['info'] ?? '',
      goal: content['goal'] == null ? 0 : int.parse(content['goal']),
      phone: content['phone'],
      web: content['web'],
      account: content['account'],
      createdAt:
          DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime'], true),
      likes: content['likes'],
      regalups: content['regalups'],
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      resources: ResourceModel.listFromJson(content['resource']),
    );
  }
}
