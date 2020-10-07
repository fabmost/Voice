import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'poll_answer_model.dart';
import 'user_model.dart';
import 'certificate_model.dart';
import '../mixins/text_mixin.dart';

class PollModel extends ContentModel {
  final String body;
  final String description;
  final int votes;
  final bool hasVoted;
  final List<PollAnswerModel> answers;
  final List<ResourceModel> resources;
  final String company;
  final String promoUrl;
  final String message;
  final String prize;

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
    this.body,
    this.description,
    this.votes,
    this.hasVoted,
    this.answers,
    this.resources,
    this.company,
    this.promoUrl,
    this.message,
    this.prize,
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

  static PollModel fromJson(Map content) {
    String regalup = content['user_regalup'] == null
        ? null
        : content['user_regalup']['user_name'];
    CertificateModel certificate;
    if (regalup == null) {
      certificate = content['certificates'] == null
          ? null
          : content['certificates']['icon'] == null
              ? null
              : CertificateModel.fromJson(content['certificates']);
    } else {
      certificate = content['certificatesRegalup'] == null
          ? null
          : content['certificatesRegalup']['icon'] == null
              ? null
              : CertificateModel.fromJson(content['certificatesRegalup']);
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
      description: TextMixin.fixString(content['description']),
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
      resources: ResourceModel.listFromJson(content['resource']),
      company: content['company'],
      message: content['message'],
      prize: content['reward'],
      promoUrl: content['logo'],
    );
  }
}
