import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'poll_answer_model.dart';
import 'user_model.dart';
import 'group_model.dart';
import 'certificate_model.dart';
import '../mixins/text_mixin.dart';

class PollModel extends ContentModel {
  final String body;
  final String description;
  final int votes;
  final bool hasVoted;
  final List<PollAnswerModel> answers;
  final List<ResourceModel> resources;
  final String terms;
  final String promoUrl;
  final String message;
  final List<GroupModel> groups;
  final ResourceModel audio;
  final bool isSatisfaction;

  PollModel({
    id,
    type,
    user,
    creator,
    createdAt,
    title,
    likes,
    comments,
    regalups,
    hasLiked,
    hasRegalup,
    hasSaved,
    certificate,
    thumbnail,
    thumbnailUrl,
    this.body,
    this.description,
    this.votes,
    this.hasVoted,
    this.answers,
    this.resources,
    this.terms,
    this.promoUrl,
    this.message,
    this.groups,
    this.audio,
    this.isSatisfaction,
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
          thumbnailUrl: thumbnailUrl,
        );

  static PollModel fromJson(Map content) {
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

    return PollModel(
      id: content['id'],
      type: content['type'],
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      creator: regalup,
      certificate: certificate,
      title: TextMixin.fixString(content['body']),
      description: content['description'] == null
          ? ''
          : TextMixin.fixString(content['description']),
      createdAt:
          DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime'], true),
      votes: content['votes'],
      likes: content['likes'],
      regalups: content['regalups'],
      comments: content['comments'],
      hasVoted: content['is_vote'],
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      answers: PollAnswerModel.listFromJson(content['answer']),
      resources: resources,
      terms: content['terms'],
      message: content['message'],
      promoUrl: content['logo'],
      groups: content['groups'] == null
          ? null
          : GroupModel.listFromJson(content['groups']),
      audio: content['audio'] == null
          ? null
          : ResourceModel.objectFromJson(content['audio']),
      thumbnailUrl: thumb,
      isSatisfaction: content['isSatisfaction'],
    );
  }
}
