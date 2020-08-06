import 'package:intl/intl.dart';

import 'content_model.dart';
import 'resource_model.dart';
import 'poll_answer_model.dart';
import 'user_model.dart';

class PollModel extends ContentModel {
  final String body;
  final int votes;
  final bool hasVoted;
  final List<PollAnswerModel> answers;
  final List<ResourceModel> resources;
  final int comments;

  PollModel({
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
    this.votes,
    this.hasVoted,
    this.answers,
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

  static PollModel fromJson(Map content) {
    return PollModel(
      id: content['id'],
      type: 'poll',
      user: UserModel(
        userName: content['user']['user_name'],
        icon: content['user']['icon'],
      ),
      title: content['body'],
      createdAt: DateFormat('yyyy-MM-DD HH:mm:ss').parse(content['datetime']),
      votes: content['votes'],
      likes: content['likes'],
      regalups: content['regalups'],
      comments: content['comments'],
      hasVoted: content['is_vote'],
      hasLiked: content['is_like'],
      hasRegalup: content['is_regalup'] ?? false,
      hasSaved: content['is_save'],
      resources: ResourceModel.listFromJson(content['resource']),
    );
  }
}
