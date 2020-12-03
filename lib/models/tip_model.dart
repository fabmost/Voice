import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'user_model.dart';
import 'certificate_model.dart';
import '../mixins/text_mixin.dart';

class TipModel extends ContentModel {
  final String body;
  final String description;
  final List<ResourceModel> resources;
  final double total;
  final bool hasRated;

  TipModel(
      {id,
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
      thumbnailUrl,
      this.body,
      this.description,
      this.resources,
      this.total,
      this.hasRated})
      : super(
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
          thumbnailUrl: thumbnailUrl,
        );

  static TipModel fromJson(Map content) {
    String regalup = content['user_regalup'] == null
        ? null
        : content['user_regalup']['user_name'];
    CertificateModel certificate;
    certificate = content['certificates'] == null
        ? null
        : content['certificates']['icon'] == null
            ? null
            : CertificateModel.fromJson(content['certificates']);
    String thumb;
    List<ResourceModel> resources =
        ResourceModel.listFromJson(content['resource']);
    if (resources != null && resources.isNotEmpty) {
      if (resources[0].type == 'V') {
        thumb = resources[0].thumbnail;
      }
    }

    return TipModel(
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
      createdAt:
          DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime'], true),
      likes: content['likes'],
      regalups: content['regalups'],
      comments: content['comments'] ?? 0,
      total: double.parse(content['total'].toString()),
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      hasRated: content['is_value'],
      resources: resources,
      thumbnailUrl: thumb
    );
  }
}
